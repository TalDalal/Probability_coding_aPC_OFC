%%
allHighPSTHs = [pooledPSTHstructEXC(1).High_responding_exc ;pooledPSTHstructEXC(2).High_responding_exc];
allLowPSTHs = [pooledPSTHstructEXC(1).Low_responding_exc ;pooledPSTHstructEXC(2).Low_responding_exc];
timeVec = pooledPSTHstructEXC(1).psthTimeVecForPlot;

%%
labels = [zeros(1,size(allLowPSTHs,1)) ones(1,size(allHighPSTHs,1))];
data = [allLowPSTHs ; allHighPSTHs];
%%
iterNum = 100;
winSize = 10;
currBinSuccessRate = [];
for timePointInd = 1:length(timeVec)-winSize
    
    successCount = 0;
    currBinData = data(:,timePointInd:timePointInd + winSize -1);
    
    for ind = 1:iterNum
        
        r = randsample(size(currBinData,1), 1);
        
        currTestData = mean(currBinData(r,:));
        currTestLabel = labels(r);
        
        currTrainData = currBinData;
        currTrainData(r,:) = [];
        currTrainLabel = labels;
        currTrainLabel(r) = [];
        
        highCentroid = mean(mean(currTrainData(find(currTrainLabel==1),:)));
        lowCentroid = mean(mean(currTrainData(find(currTrainLabel==0),:)));
        
        
        high_Dist = sqrt(sum((currTestData - highCentroid) .^ 2));
        low_Dist = sqrt(sum((currTestData - lowCentroid) .^ 2));
        

        
        if low_Dist < high_Dist
            predictedLabel = 0;
        else
            predictedLabel = 1;
        end
        
        
        if predictedLabel == currTestLabel
            successCount = successCount + 1;
            
        end
        
        
        
    end
    
    currBinSuccessRate(timePointInd) = successCount / iterNum;
end
figure;
plot(timeVec(1:end-winSize), currBinSuccessRate)