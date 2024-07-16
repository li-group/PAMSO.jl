using DataFrames
using CSV
using Statistics
using Clustering
using FileIO
using JuMP
root = pwd()

rootn = pwd()
plant = ["Plant"]
powergen = ["Solar panel","Wind Turbine"]
global component = [plant;powergen]
chemical = ["Cl2","H2","O2","NaCl","NaOH","Water"]
Location_tr = []
Location = []
Consumer_supplier = ["j1","j2","j3","j4","j5","j6","j7","j8","j9"]
modes = ["SC","OD","Shut"]

c_jp = Dict()
c_jp[("j5",)] = ["H2","Cl2"]
c_jp[("j2",)] = []
c_jp[("j3",)] = ["NaOH"]
c_jp[("j6",)] = ["NaOH"]
c_jp[("j1",)] = []
c_jp[("j4",)] = []
c_jp[("j7",)] = []
c_jp[("j8",)] = ["H2","Cl2"]
c_jp[("j9",)] = []

Consumer = ["j5","j3","j6","j8"]
Supplier = ["j2","j1","j4","j7","j9"]
Consumer_suppliercom = intersect(Consumer,Supplier)
Consumer_only = Consumer[(!in).(Consumer,Ref(Consumer_suppliercom))]
Supplier_only = Supplier[(!in).(Supplier,Ref(Consumer_suppliercom))]
c_jr = Dict()
rootn = pwd()
#=
c_jr[("j2",)] = ["NaCl","Water","O2"]
c_jr[("j1",)] = ["O2"]
c_jr[("j4",)] = ["NaCl","Water","O2"]
c_jr[("j7",)] = ["O2","NaCl","Water"]
=#

c_jr[("j2",)] = ["NaCl","Water","O2"]
c_jr[("j1",)] = ["O2"]
c_jr[("j4",)] = ["Water","O2"]
c_jr[("j7",)] = ["NaCl","Water","O2"]
c_jr[("j9",)] = ["NaCl","Water"]
n_rep = 5
d_m = [31,28,31,30,31,30,31,31,30,31,30,31]
n_loc_og = 200
n_u = 22
n_i = 3
n_ip = 1
#n_l = 10+5
n_m = 1
n_tm = 12
n_k = n_rep
n_s = 24
n_c1 = 6


sl_fac = 10
elec_fac = 1
N = 1

#max_wt = 150
#max_sp = 15
max_wt = 300
max_sp = 30
sp_prfac = 1
wt_prfac = 3
max_sp_pl = 500 #Ratio of maximum number of solar panels to plants in a location
max_wt_pl = 500 #Ratio of maximum number of solar panels to plants in a location
max_pl = 100 #maximum number of plants in a location in the final configuration
ir = 0.03
mw = Dict()
mw1 =  [71,2,32,58,40,18]
for i = 1:n_c1
    mw[(chemical[i],)] = mw1[i]
end
df_loc_path = joinpath(rootn,"data","Location200.csv")
files_plant = [joinpath(rootn,"data","plant.csv")]
files_power = [joinpath(rootn,"data","powergen.csv")]
files_storage = [joinpath(rootn,"data","storage.csv")]
files_l = [joinpath(rootn,"data","transmission.csv")]
df_parampath = joinpath(rootn,"data","datahalf.csv")
solar_folder = joinpath(rootn,"data","solar_new_data")
wind_folder = joinpath(rootn,"data","wind_new_data")
println(pwd())
years = [2011,2012,2013]
infl = [(2.07/100+1)*(1.46/100+1),(1.46/100+1),1]*(1+24.10/100)#Add values for all years in between first and last year
Dem = DataFrame(CSV.File(joinpath(rootn,"data","Demand.csv")))
D= Dict()

Dem_fac = 2
for i in 1:nrow(Dem)
   D[(Dem[i,:Chemical],Dem[i,:Consumer],Dem[i,:Month])] = Dem[i,:Demand]*Dem_fac
end
include(joinpath(rootn,"data","kmeansalg.jl"))
clus = FileIO.load(joinpath(rootn,"data","kmeanval200.jld2"),"clus")
ns = FileIO.load(joinpath(rootn,"data","kmeanave200.jld2"),"ns")

w = Dict()
for i = 1:n_tm
    ck = clus[i]
    for j = 1:n_k
        w[(j,i)] = ck.wcounts[j]*d_m[i]/sum(ck.wcounts)
    end
end

Ce = Dict()
P_og = Dict()
t_s = 1:24
for t = 1:n_tm
  ck = clus[t]
  cen = ck.centers
  ns1 = ns[t]
  for k= 1:n_k
    for h = 1:n_s

      Ce[(t,k,h)] = cen[h,k]*ns1[2,1]+ns1[1,1]
      for q in 1:n_loc_og
        P_og[(component[2],"r"*string(q),t,k,h)] = cen[24+(q-1)*24+h,k]*ns1[2,2]+ns1[1,2]
        if (P_og[(component[2],"r"*string(q),t,k,h)]<=1)
          P_og[(component[2],"r"*string(q),t,k,h)] = 0
        end
        P_og[(component[3],"r"*string(q),t,k,h)] = cen[24+n_loc_og*24+(q-1)*24+h,k]*ns1[2,3]+ns1[1,3]
        if (P_og[(component[3],"r"*string(q),t,k,h)]<=1)
          P_og[(component[3],"r"*string(q),t,k,h)] = 0
        end
        P_og[(component[3],"r"*string(q),t,k,h)] = P_og[(component[3],"r"*string(q),t,k,h)]
      end
    end
  end
end

df_loc = DataFrame(CSV.File(df_loc_path))
function cladd()
  P1 = []
  for i in 1:n_loc_og
    P2 = []
    for t in 1:n_tm
      for k in 1:n_k
        for h in 1:24
          push!(P2,P_og[("Solar panel",df_loc[i,"Location"],t,k,h)])
        end
      end
    end
    for t in 1:n_tm
      for k in 1:n_k
        for h in 1:24
          push!(P2,P_og[("Wind Turbine",df_loc[i,"Location"],t,k,h)])
        end
      end
    end
    push!(P2,df_loc[i,"Latitude"])
    push!(P2,df_loc[i,"Longitude"])
   P2 = reshape(P2,(n_rep*n_s*n_tm*length(powergen)+2,1))
   if(i==1)
     P1 = P2
   else
      P1 = hcat(P1,P2)
    end
  end
  size(P1)
  return P1
end
Xmod = cladd()
Xmod = convert(Array{Float64,2},Xmod)

#print(Ce)

function p_check()
  P = P_og
  P_val = Dict()
for q in 1:n_loc_og
  a = 0
  b = 0
  for t = 1:n_tm
    for k = 1:n_k
      for h =1:n_s
        a = a+P[("Solar panel","r"*string(q),t,k,h)]*w[(k,t)]*Ce[(t,k,h)]
      end
    end 
    b = b+sum(P[("Solar panel","r"*string(q),t,k,h)]*w[(k,t)] for h in 1:24 for k in 1:n_k)*sum(Ce[(t,k,h)]*w[(k,t)] for h in 1:24 for k in 1:n_k)/(24*d_m[t])
  end
  #println(a/(155566.476))
  #println(b/(155566.476))
   P_val[("Solar panel","r"*string(q))] = a/b
  #println(P_val)
end

for q in 1:n_loc_og
  a = 0
  b = 0
  for t = 1:n_tm
    for k = 1:n_k
      for h =1:n_s
        a = a+P[("Wind Turbine","r"*string(q),t,k,h)]*w[(k,t)]*Ce[(t,k,h)]
      end
    end 
    b = b+sum(P[("Wind Turbine","r"*string(q),t,k,h)]*w[(k,t)] for h in 1:24 for k in 1:n_k)*sum(Ce[(t,k,h)]*w[(k,t)] for h in 1:24 for k in 1:n_k)/(24*d_m[t])
  end
  #println(a/(155566.476))
  #println(b/(155566.476))
   P_val[("Wind Turbine","r"*string(q))] = a/b
  #println(P_val)
end
return P_val
end
P_val =p_check()

cd(root)
