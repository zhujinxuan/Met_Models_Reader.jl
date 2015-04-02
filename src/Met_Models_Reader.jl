module Met_Models_Reader
using NetCDF

lon_att= Dict{ASCIIString,ASCIIString}("long_name"=>"longitude","units"=>"degrees_east")
lat_att= Dict{ASCIIString,ASCIIString}("long_name"=>"latgitude","units"=>"degrees_north")
time_att=Dict{ASCIIString,ASCIIString}("long_name"=>"time","units"=>"Year")

# Identify Path
abstract Models_Data_Path

# For Select Layer and Moonths
include("Strategies.jl")

# Make Reading
abstract Data_Type_Selector
function makereading(dim,p :: Models_Data_Path, day :: Int64,
                     Data_by :: Data_Type_Selector, layer_selector :: layers_each_time )
  error("this doesn't serve for pure types");
end
function makereading_all(p :: Models_Data_Path, 
                         Data_by :: Data_Type_Selector, layer_selector :: layers_each_time,
                         months_selector :: time_each_annual;
                         check_starter :: Bool = true, set_NaN :: Bool = true)
  error("this function doesn't serve for pure types");
end

function make_rw(p :: Models_Data_Path, 
                         Data_by :: Data_Type_Selector, layer_selector :: layers_each_time,
                         months_selector :: time_each_annual;
                         check_starter :: Bool = true, set_NaN :: Bool = true)
  error("this function doesn't serve for pure types");
end
include("foam/Assemble.jl")

export makereading, makereading_all;
export make_rw;
end
