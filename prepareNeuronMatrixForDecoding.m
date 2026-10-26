function [allNeuronsMatrix] = prepareNeuronMatrixForDecoding()
%% Find the indices of the responding neurons, and the evoked activity per trial for each neuron
[neuronIndices, allTrialsActivity] = plotPSTHduringCSodor([-4 -2], [0 1], 0.01, 'CS+');
close all;
% neuronsIDforDecoder = unique([neuronIndices.high_exc ; neuronIndices.high_inh ; neuronIndices.low_exc ; neuronIndices.low_inh]);
neuronsIDforDecoder = unique([neuronIndices.high_exc ; neuronIndices.high_inh ]);
%% Find the minimal number of trials across all neurons for the decoder.
for trialsInd = 1:size(allTrialsActivity,2)
    minVal(trialsInd) = min(length(allTrialsActivity(trialsInd).A), length(allTrialsActivity(trialsInd).C)   );

end
minNumTrials = min(minVal);
%% Build the trials X neurons matrix, with randed  N trials
allNeuronsMatrix = nan(minNumTrials*2, length(neuronsIDforDecoder));

for idInd = 1:length(neuronsIDforDecoder)
    
    currID = neuronsIDforDecoder(idInd);
    
    randInds = randsample(minVal(currID), minNumTrials);
    
    allNeuronsMatrix(:,idInd) = [allTrialsActivity(currID).A(randInds);allTrialsActivity(currID).C(randInds)];
end
