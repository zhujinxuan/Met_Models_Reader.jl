abstract time_each_annual 
abstract layers_each_time

type Layer_1st <: layers_each_time
  start :: Array{Int64,1}
  count :: Array{Int64,1}
end

SurfaceLayer = Layer_1st([1,1,0,1], [0,0,1,1])

function select_layer( dim , L :: layers_each_time)
  error("No function for a pure abstract layers_each_time")
end

function select_layer ( dim , L :: Layer_1st )
  idices = find(L.start .<=0 )
  start = copy(L.start)
  for jdx in idices
    start[jdx] = start[jdx]+dim[jdx]
  end

  idices = find(L.count .<=0 )
  count = copy(L.count)
  for jdx in idices
    count[jdx] = count[jdx]+dim[jdx]
  end
  return (start, count)
end
export select_layer, SurfaceLayer, Layer_1st, layers_each_time


#= abstract time_each_annual =# 

function select_months( y , T :: time_each_annual)
  error("No function for a pure abstract time_each_annual")
end

type Annual_Months <: time_each_annual
  seasonidx :: Array{Int64,2}
end


function select_months( y  , T :: Annual_Months)
  y1 = y[:,:,:,T.seasonidx[:]]
  y2 = reshape(y1, (
                    size(y1,1),size(y1,2),size(y1,3),
                    size(T.seasonidx,1),size(T.seasonidx,2)))
  return(squeeze(mean(y2,4),4))
end
Seasons_each_Year = Annual_Months(reshape([1:12],3,4))
Year_each_Year = Annual_Months(reshape([1:12],12,1))
Months_each_Year = Annual_Months(reshape([1:12],1,12))

export time_each_annual, select_months
export Annual_Months
export Seasons_each_Year, Year_each_Year, Months_each_Year

