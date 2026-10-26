function [SE] = binoDistSE(prob, N)
SE = sqrt(prob.*(1-prob)./N);