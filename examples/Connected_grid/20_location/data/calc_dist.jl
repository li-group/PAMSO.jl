function cal_dist(df_loc) #FUnction to calculate distance between locations in dataframe with Latitude and Langitude known
	dist = Dict()
	for i = 1:nrow(df_loc)
		for j = i+1:nrow(df_loc)
			
			if !(df_loc[i,"Longitude"] isa Number)
				lon1 = parse(Float64, lstrip(df_loc[i,"Longitude"]))
			else
				lon1 = df_loc[i,"Longitude"]
			end
			if !(df_loc[j,"Longitude"] isa Number)
				lon2 = parse(Float64, lstrip(df_loc[j,"Longitude"]))
			else
					lon2 = df_loc[j,"Longitude"]
			end
            
            if !(df_loc[i,"Latitude"] isa Number)
				
				lat1 = parse(Float64, lstrip(df_loc[i,"Latitude"]))
			else
				lat1 = df_loc[i,"Latitude"]
			end
			if !(df_loc[j,"Latitude"] isa Number)
				
				lat2 = parse(Float64, lstrip(df_loc[j,"Latitude"]))
			else
				lat2 = df_loc[j,"Latitude"]
			end
			lon1 = deg2rad(lon1)
			lon2 = deg2rad(lon2)
			lat1 = deg2rad(lat1)
			lat2 = deg2rad(lat2)
			dlon = lon2 - lon1
			dlat = lat2 - lat1
			a = (sin(dlat / 2))^2 + cos(lat1) * cos(lat2) * (sin(dlon / 2))^2

			cs = 2 * asin(sqrt(a))

			# Radius of earth in kilometers. Use 3956 for miles
			r = 6371
			dist[(df_loc[i,"Location"],df_loc[j,"Location"])] = cs * r
			dist[(df_loc[j,"Location"],df_loc[i,"Location"])] = cs * r
		end
	end
	return dist
end
df_locn = DataFrame(CSV.File(df_loc_path))
dis1 = cal_dist(df_locn)