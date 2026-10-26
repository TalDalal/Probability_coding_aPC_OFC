%% Load the data
clear;clc
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

%% Get the activity matrix per neuron
[allNeuronsActivityMat, timeBins, minNumTrials] = getAllNeuronsActivityMatrix(allMiceData,'CS+');
timeBins = timeBins(1:end-1);
minNumTrials = min(minNumTrials);
%% Decoder
timeJump = mean(diff(timeBins));
decodingTimeFrame = [-1 2];
decoderTimeBins = find(timeBins >= decodingTimeFrame(1) & timeBins < decodingTimeFrame(end));

baselineTimeFrame = [-4 -2];
baselineInds = find(timeBins >= baselineTimeFrame(1) & timeBins < baselineTimeFrame(end));


winSize = .5;%Sec
winSizeIndex = round((winSize/timeJump));

%Number of bootstrap reps.
bootstrapIterNum = 30;

for timeBinInd = 1:length(decoderTimeBins)-winSizeIndex
    
    allSRsCurrTimeBin = nan(1,bootstrapIterNum);allSRsCurrTimeBinSHUFF = allSRsCurrTimeBin;
    
    for bootInd = 1:bootstrapIterNum
        
        allNeuronsMatrix = nan(minNumTrials*2, length(allNeuronsActivityMat));
        
        for neuronInd = 1:length(allNeuronsActivityMat)
            
            highMat = allNeuronsActivityMat(neuronInd).A;
            
            randtrialsHigh = randsample(size(highMat,1),minNumTrials, 'true');
            
            currIterHighMat = highMat(randtrialsHigh, decoderTimeBins(timeBinInd:timeBinInd + winSizeIndex-1));
            currIterHighMat_BG = highMat(randtrialsHigh, baselineInds);
            
            evokedFRHigh = mean(currIterHighMat,2) - mean(currIterHighMat_BG,2);
            
            
            
            lowMat = allNeuronsActivityMat(neuronInd).C;
            randtrialsLow = randsample(size(lowMat,1),minNumTrials, 'true');
            currIterLowMat = highMat(randtrialsLow, decoderTimeBins(timeBinInd:timeBinInd + winSizeIndex-1));
            currIterLowMat_BG = lowMat(randtrialsLow, baselineInds);
            
            evokedFRLow = mean(currIterLowMat,2) - mean(currIterLowMat_BG,2);
            
            allNeuronsMatrix(:,neuronInd) = [evokedFRHigh ; evokedFRLow];
        end
        
        [finalSR] = linearBinaryDecoder(allNeuronsMatrix);
        
        allSRsCurrTimeBin(bootInd) = mean(finalSR(1));
        allSRsCurrTimeBinSHUFF(bootInd) = mean(finalSR(2));
    end
    allSRsAllTimeBin(:,timeBinInd) =  [mean(allSRsCurrTimeBin) ; std(allSRsCurrTimeBin)];
    allSRsAllTimeBinSHUFF(:,timeBinInd) =  [mean(allSRsCurrTimeBinSHUFF) ; std(allSRsCurrTimeBinSHUFF)];
end
figure;
plot(timeBins(decoderTimeBins(1:end-winSizeIndex)), allSRsAllTimeBin(1,:))
hold on;
plot(timeBins(decoderTimeBins(1:end-winSizeIndex)), allSRsAllTimeBinSHUFF(1,:))