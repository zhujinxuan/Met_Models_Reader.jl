type Foam_Data_Path <: Models_Data_Path
  dir_input                ::    ASCIIString
  filename                 ::    ASCIIString 
  start_on_month           ::    Int64
  last_on_month            ::    Int64
end

function AFoamProblem (   ;dir_input :: ASCIIString = "/home/3Tstorage/foam/run_sd1/storage/", 
                           filename :: ASCIIString = "data/control_sd1.nc",
                           first_day :: Int64 = 0, last_day :: Int64 = 0)
  return Foam_Data_Path(dir_input,filename, first_day , last_day );
end

export Foam_Data_Path
export AFoamProblem
