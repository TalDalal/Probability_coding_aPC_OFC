function [dataMatrix] = createBinaryVectorsFromSessionsData(params, saveFlag)

%H or L
H_L_vec = zeros(1,length(params.trialsIndex))
H_L_vec(find(abs(params.trialsIndex)==1)) = 1;

%CS+ or -
CS_plus_minus = zeros(1,length(params.trialsIndex));
CS_plus_minus(find(params.trialsIndex > 0)) = 1;

firstLickLatency = params.firstLickLatency.all;

dataMatrix = table(H_L_vec, CS_plus_minus, firstLickLatency)

if saveFlag
save(params.fullFileName, 'dataMatrix')
end





