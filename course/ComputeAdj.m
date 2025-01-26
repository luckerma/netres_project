function [Adj,wAdj]=ComputeAdj(ROUTES,TravelLinkTime)
  Stoplist={};
  sizeAdj=ComputeSizeAdj(ROUTES);
  Adj = zeros(sizeAdj,sizeAdj); wAdj= zeros(sizeAdj);
  for itinerary = 1:size(ROUTES,2)
    [LastStopIdx,Stoplist] = SearchIndex(Stoplist,ROUTES{itinerary}{1});
    for Stop = 2:size(ROUTES{itinerary},2)
      [StopIdx,Stoplist] = SearchIndex(Stoplist,ROUTES{itinerary}{Stop});
      Adj(LastStopIdx,StopIdx) = 1;
      wAdj(LastStopIdx,StopIdx) = TravelLinkTime{itinerary}{Stop-1};
      LastStopIdx=StopIdx;
    end
  end
end

