function [lightestNode, NodeList] = SearchLightNode(NodeList, weights)
  lightestNode = NodeList(1); lightestNodeIndex = 1;
  for i = 2:size(NodeList,2)
    possibleNode = NodeList(i);
    if weights(possibleNode) < weights(lightestNode)
      lightestNode = possibleNode;
      lightestNodeIndex = i;
    endif
  endfor
  NodeList(lightestNodeIndex) = [];
endfunction

