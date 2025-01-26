function [sizeAdj StopList] = ComputeSizeAdj(ROUTES);
  StopList = {};
  for itinerary = 1:size(ROUTES,2)
    for stop = 1:size(ROUTES{itinerary},2)
      [~,StopList] = SearchIndex(StopList,ROUTES{itinerary}{stop});
    end
  end
  sizeAdj=size(StopList,2);
end

