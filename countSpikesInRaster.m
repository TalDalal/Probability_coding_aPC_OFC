function [currRaster, numOfSpikes, noSpikesTrials] = countSpikesInRaster(currRaster, minimalSpikesPerTrial, countSpikesFlag)
numOfSpikes = [];noSpikesTrials = [];
for trialInd = 1:size(currRaster,2)
    %We require at least XX spikes per baseline + trial
    if length(currRaster(trialInd).times) < minimalSpikesPerTrial
        noSpikesTrials(end+1) = trialInd;
    end
    if countSpikesFlag
        numOfSpikes = [numOfSpikes length(currRaster(trialInd).times)];
    end
end
numOfSpikes = sum(numOfSpikes);
if ~isempty(noSpikesTrials)
    currRaster(noSpikesTrials) = [];
end