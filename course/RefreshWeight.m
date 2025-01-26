function [Weights, Previous] = RefreshWeight(Weights, Previous, Source, Target, Dist)
  if Weights(Source) + Dist < Weights(Target)
    Weights(Target) = Weights(Source) + Dist;
    Previous(Target) = Source; endif, endfunction

