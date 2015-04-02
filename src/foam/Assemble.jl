include("type_FoamPreprocess.jl")
using HDF5, JLD
type FOAM_Data <: Data_Type_Selector
  prefix :: ASCIIString
  var :: ASCIIString
end

OceanT_FOAM = FOAM_Data("/ocean/history.ocean.", "T");

function makereading(dim,p :: Foam_Data_Path, day :: Int64,
                     Data_by :: FOAM_Data = OceanT_FOAM,
                     layer_selector :: Layer_1st = SurfaceLayer)
  data_path = string(p.dir_input,Data_by.prefix, @sprintf("%07.7i",day),".nc");
  (start, count) = select_layer(dim, layer_selector);
  res = ncread(data_path, Data_by.var, start= start, count = count); 
  ncclose(data_path);
  return(res);
end


function makereading_all(p :: Foam_Data_Path,
                         Data_by :: FOAM_Data = OceanT_FOAM,
                         layer_selector :: Layer_1st = SurfaceLayer, 
                         months_selector :: Annual_Months = Months_each_Year
                         ; check_starter :: Bool = true, set_NaN :: Bool = true)
  first_day = p.start_on_month
  last_day = p.last_on_month - 360
  if (check_starter)
    first_day = (first_day+330); first_day = first_day - (first_day%360);
  end
  years_days = [first_day:360:last_day]

  data_path = string(p.dir_input, Data_by.prefix, @sprintf("%07.7i",first_day),".nc");
  dim = size(ncread(data_path,Data_by.var));
  sst = fill(NaN, (dim[1], dim[2],1, size(months_selector.seasonidx,2),length(years_days)) )
  sst_temp = fill(NaN, (dim[1],dim[2],1,12))
  for (index, value) in enumerate(years_days)
    for (imon,vmon) in enumerate(0:30:330)
      sst_temp[:,:,:,imon] = makereading(dim,p,vmon+value , Data_by,layer_selector)
    end
    sst[:,:,:,:,index] = select_months(sst_temp, months_selector);
  end
  if (set_NaN)
    sst[sst.> 1000] = NaN
    sst[sst.< -1000] = NaN
  end
  return (sst)
end
function make_rw(p :: Foam_Data_Path,
                         Data_by :: FOAM_Data = OceanT_FOAM,
                         layer_selector :: Layer_1st = SurfaceLayer, 
                         months_selector :: Annual_Months = Months_each_Year
                         ; check_starter :: Bool = true, set_NaN :: Bool = true)
  first_day = p.start_on_month
  last_day = p.last_on_month - 360
  if (check_starter)
    first_day = (first_day+330); first_day = first_day - (first_day%360);
  end
  years_days = [first_day:360:last_day]
  sst = makereading_all(p,Data_by, layer_selector, 
                        months_selector,check_starter = check_starter, set_NaN= set_NaN);
  sst = float64(squeeze(sst,3))

  data_path = string(p.dir_input, Data_by.prefix, @sprintf("%07.7i",first_day),".nc");
  lon = float64(ncread(data_path,"lon"));
  lat = float64(ncread(data_path,"lat"));
  outputfile = string(p.filename,".jld");
  if (isfile(outputfile))
    rm(outputfile)
  end
  save(outputfile,"lon", lon, "lat",lat,"time",years_days,"sst", sst);
end

#=   latdim = NetCDF.NcDim("lat",lat,lat_att) =#
#=   londim = NetCDF.NcDim("lon",lon,lon_att) =#
#=   timedim = NetCDF.NcDim("times", years_days,@Compat.Dict("Units"=>"Day")) =#
#=   permonth = size(months_selector.seasonidx,1) =#
#=   monthdim = NetCDF.NcDim("month", [1:size(months_selector.seasonidx,2)], =# 
#=                                     Dict{ASCIIString,ASCIIString}("Units"=>"$permonth months")) =#
#=   sst_att = Dict{ASCIIString,ASCIIString}("Units"=>"C"); =#
#=   sstVar = NetCDF.NcVar("sst", [londim,latdim,monthdim,years_days],sst_att, Float64) =#
#=   sstAVar = NetCDF.NcVar("sst_annual", [londim,latdim,years_days], sst_att, Float64) =#

#=   nc = NetCDF.create(p.filename, [sstVar,sstVar]); =#
#=   NetCDF.putVar(nc,"sst", sst); =#
#=   NetCDF.putVar(nc,"sst_annual", squeeze(mean(sst,3),1)); =#
#=   NetCDF.close(nc); =#


