function [StopIndex,StopList] = SearchIndex(StopList,StopName)
  StopIndex=size(StopList,2)+1;  % if fails, returns index=end+1
  for i = 1:size(StopList,2)
    if strcmp(StopList{i},StopName)
      StopIndex = i;             % if fint it, recover the existing index
      break;
    end
  end
  StopList{StopIndex}= StopName; % if fails, build the next stop
end

