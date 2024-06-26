using CSV
using DataFrames
using Dates
using Statistics
using Clustering
function cluskm(n_k,n_loc)
    #root = pwd()
    #cd(joinpath(root,"Generator-data"))
    #cd("./Generator-data 2")
    df = DataFrame(CSV.File(joinpath(rootn,"Examples",Example_folder,"price1.csv")))
    dp = filter(:Zone => ==("LZ_WEST"), df)
    n = nrow(dp)
    ind = []
    T = []
    V1 = []
    V2 = []
    V3 = []
    push!(T,Dates.DateTime(dp[1,"Date"],"m/d/y H:00"))
    push!(V1,Dates.day(T[1]))
    push!(V2,Dates.month(T[1]))
    push!(V3,Dates.year(T[1]))
    for i in 2:n
        #print(i)
        push!(T,Dates.DateTime(dp[i,"Date"],"m/d/y H:00"))
        push!(V1,Dates.day(T[i]))
        push!(V2,Dates.month(T[i]))
        push!(V3,Dates.year(T[i]))
        if(Dates.day(T[i])==29&&Dates.month(T[i])==2)
            push!(ind,i)
        end
    end
    dp[!,"Date_mod"] = T
    dp[!,"Day"] = V1
    dp[!,"Month"] = V2
    dp[!,"year"] = V3
    dp = delete!(dp, ind)
    gdf = groupby(dp, :Month)
    m = 1:12
    d_m = [31,28,31,30,31,30,31,31,30,31,30,31]
    data_clus = []
    p = 1
    Y = []
    Y1 = []
    Y2 = []
    Y3 = []
    normstat = []
    for i =DateTime(minimum(years),1,1,00):Dates.Hour(1):DateTime(maximum(years),12,31,23)
    if !(Dates.day(i)==29&&Dates.month(i)==2)
        push!(Y,i)
        push!(Y1,Dates.day(i))
        push!(Y2,Dates.month(i))
        push!(Y3,Dates.year(i))
    end
    end
   #lisloc = [48,49,35,36,40,29,30,31,34,10,2,99,25,84,78,37,26,92,93,94]
   lisloc = 1:n_loc
    i = 1
    X_s = []
    for y in years
        s1 = DataFrame(CSV.File(joinpath(solar_folder, "r"*string(lisloc[i])*"_"*string(y)*".csv")))
        X_s = vcat(X_s,s1[:,3])
        #println(size(X_s))
    end
    for i = 2:n_loc
        X_s1 = []
       for y in years
         s1 = DataFrame(CSV.File(joinpath(solar_folder, "r"*string(lisloc[i])*"_"*string(y)*".csv")))
         X_s1 = vcat(X_s1,s1[:,3])
       end
       println(size(X_s1))
       X_s = cat(X_s,X_s1,dims=2)
        
        #print(maximum(X_s))
    end
    i = 1
    X_w = []
    #s1 = DataFrame(CSV.File(joinpath(wind_folder, "r"*string(lisloc[i])*"_"*string(y)*".csv")))
    for y in years
        s1 = DataFrame(CSV.File(joinpath(wind_folder, "r"*string(lisloc[i])*"_"*string(y)*".csv")))
        X_w = vcat(X_w,s1[:,3])
    end
    for i = 2:n_loc
        #s1 = DataFrame(CSV.File(joinpath(wind_folder, "r"*string(lisloc[i])*"_2011.csv")))
        X_w1 = []
        for y in years
            s1 = DataFrame(CSV.File(joinpath(wind_folder, "r"*string(lisloc[i])*"_"*string(y)*".csv")))
            X_w1 = vcat(X_w1,s1[:,3])
        end
        X_w = cat(X_w,X_w1,dims=2)
    end
    print(size(X_s))
    print(size(X_w))
    
    for i in m
        X = []
        data = []
        gdf_y = groupby(gdf[i], :year)
        for k = 1:length(gdf_y)
        gdf_m = groupby(gdf_y[k], :Day)
        for j in 1:length(gdf_m)
        if(nrow(gdf_m[j])==24)
            s = gdf_m[j]
            #print(size((s[1,"Day"].==Y1).*(s[1,"Month"].==Y2)))
            ye = s[1,"year"]-(minimum(years)-1)
            #println(ye)
            p1 = reshape(s[:,"Price"]*infl[ye]*(10^(-3)),(1,24))
            ind = (s[1,"Day"].==Y1).*(s[1,"Month"].==Y2).*(s[1,"year"].==Y3)
            print(size(X_w[ind,:]))
            so  = reshape(X_s[ind,:],(1,24*n_loc))
            sw  = reshape(X_w[ind,:],(1,24*n_loc))
            x_d = cat(p1,so,sw,dims=2)
            #print(sum(ind))
            X = cat(X,x_d,dims=1)
            #print(size(x_d))
        end
        end
    end
        X = X.*(X.>=0)
        ns = [[Statistics.mean(X[:,1:24]),Statistics.std(X[:,1:24])] [Statistics.mean(X[:,25:24+n_loc*24]),Statistics.std(X[:,25:24+n_loc*24])] [Statistics.mean(X[:,25+n_loc*24:24+n_loc*24*2]),Statistics.std(X[:,25+n_loc*24:24+n_loc*24*2])]]
        push!(normstat,ns)
    println(Statistics.std(X_s))
        X[:,1:24] = (X[:,1:24].-ns[1,1])/(ns[2,1])
        X[:,25:24+n_loc*24] = (X[:,25:24+n_loc*24].-ns[1,2])/(ns[2,2])
        X[:,25+n_loc*24:24+n_loc*24*2] = (X[:,25+n_loc*24:24+n_loc*24*2].-ns[1,3])/(ns[2,3])
        X = transpose(X)
        clus = kmeans(X, n_k,display=:final,maxiter = 1000)
        push!(data_clus,clus)
    end
    cd(root)
    return data_clus,normstat
end
#clus,ns= cluskm(n_rep,n_loc_og)
cd(root)
using FileIO
#FileIO.save(joinpath(root,"Generator-data","kmeanval50.jld2"),"clus",clus)
#FileIO.save(joinpath(root,"Generator-data","kmeanave50.jld2"),"ns",ns)


