function [finalSR, confusionMatrix] = linearBinaryDecoder(allNeuronsMatrix)

%The input matrix is trials X neurons

% Labels (High or low probaiblity)
labels = [zeros(1,size(allNeuronsMatrix,1)/2), ones(1,size(allNeuronsMatrix,1)/2)]';
%Shuffled
shuffLabels = randsample(labels, length(labels));
data = allNeuronsMatrix;


%Decode
[successRate, confusionMatrix] = leaveOneOut_cross_validation_high_or_low_odors(data, labels, 100);


%Shuffled
[successRateSHUFF, ~] = leaveOneOut_cross_validation_high_or_low_odors(data, shuffLabels, 100);



% sortedSRs = sort(allSRs);
% CI = [sortedSRs(0.025*length(allSRs)) sortedSRs(0.975*length(allSRs))]
finalSR = [successRate successRateSHUFF];