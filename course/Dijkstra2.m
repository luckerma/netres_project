function [Weights, Paths] = Dijkstra2(Adj, Origin)
  Weights = Inf(1,size(Adj,2));Weights(Origin) = 0;
  N = size(Adj,1); NodeList = 1:N;
  Previous = zeros(1,N); Previous(Origin) = -1;
  while size(NodeList,2) > 0
    [lightestNode, NodeList] = SearchLightNode(NodeList, Weights);
    if Weights(lightestNode) == Inf,Weight = Inf; break; endif
    for NeighborIdx = 1:size(NodeList,2)
      Neighbor = NodeList(NeighborIdx);
      if Adj(lightestNode, Neighbor) ~= 0
        [Weights,Previous]=RefreshWeight(Weights,Previous,...
           lightestNode,Neighbor,Adj(lightestNode,Neighbor));
  endif,endfor,endwhile

  paths = [];
  for i = 1:N
    if Previous(i)==0, Paths(i,1) = 0;
    else Paths(i,1)=i;
      LastNodeAdded = i; Idx = 1;
      while LastNodeAdded ~= Origin,
        LastNodeAdded = Previous(LastNodeAdded);
        Idx = Idx + 1;
        Paths(i,Idx) = LastNodeAdded;
endwhile,endif,endfor,endfunction

