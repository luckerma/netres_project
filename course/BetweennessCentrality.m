function BC = BetweennessCentrality(Adj)
BC = zeros(size(Adj,1),1);
for i = 1:size(Adj,1),
  for c = 1:size(Adj,1), if c~=i,
    [Dij Path] = Dijkstra2(Adj,i);
    BC(c) =BC(c)+length(find(Path(:,2:end-1)==c));
endif,endfor,endfor,endfunction
