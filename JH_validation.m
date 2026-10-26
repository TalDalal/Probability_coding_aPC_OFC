
%% JH validation of neural activity suppression.
clear;load('allSessions1.mat');
singleOrMUA = 'single';
[allRasterPlots] = generateRasterPlotsJHvalidation(allSessions1, singleOrMUA);

figure;
data = [];allPSTHs = [];
for unitInd = 1:10%size(allRasterPlots, 2)
    data(unitInd).times =  allRasterPlots{unitInd}.allSpikes./60;
    [r,t] = mypsth(data(unitInd), 1);
    
    firstVal = find(t > 0, 1);
    windowToNormalize = mean(r(find(t > 5 & t < 20)));
    r = r./windowToNormalize;
    allPSTHs(unitInd, :) = r(firstVal:firstVal+300);
    t = t(firstVal:firstVal+300);

    
end
mypsth(data, 1)
figure;
errorbar_patch(t,mean(allPSTHs), std(allPSTHs)./sqrt(size(allPSTHs,1)))
    

% analysisWinPre = [0 20].*60;
% analysisWinPost = [20 40].*60;
% 
% for neuronInd = 1:size(allRasterPlots,2)
%     currSpikes = allRasterPlots{neuronInd}.allSpikes;
%     pre(neuronInd) = length(find(currSpikes > analysisWinPre(1) & currSpikes < analysisWinPre(2)))./diff(analysisWinPre);
%     post(neuronInd) = length(find(currSpikes > analysisWinPost(1) & currSpikes < analysisWinPost(2)))./diff(analysisWinPost);
% end
% 
% figure;
% scatter(pre, post)
% xlim([0 15]);ylim([0 15])
%%
    function [allRasterPlots] = generateRasterPlotsJHvalidation(allSessions, singleOrMUA)
        
        if strcmpi(singleOrMUA, 'single')
            indx = 1;
        else
            indx= 2;
        end
        psthKernel = 0.07;
        xPatchVals = [0 allSessions{1}.expParams{indx}.odorDuration./1000 allSessions{1}.expParams{indx}.odorDuration./1000 0];
        yPatchVals = [0 0 50 50];
        
        odorTimes = allSessions{1}.expParams{1}.correctedOdorTimes;
        
        odor8Inds = (find(allSessions{1}.expParams{indx}.odorEventsId==8));
        odor14Inds = (find(allSessions{1}.expParams{indx}.odorEventsId==14));
        odor18Inds = (find(allSessions{1}.expParams{indx}.odorEventsId==18));
        allRasterPlots = [];
        analysisWin = 2;%sec around the odor onset
        for unitInd = 1:size(allSessions{1}.expParams{indx}.neuronSpikeTime,2)
            
            currSpikes = allSessions{1}.expParams{indx}.neuronSpikeTime{unitInd}.t;
            
            hold all;
            for trialInd = 1:size(odorTimes,2)
                data(trialInd).times = currSpikes(find(currSpikes > odorTimes(1,trialInd) - 2 & currSpikes < odorTimes(2,trialInd) +2)) - odorTimes(1,trialInd);
                
            end
            
            
            allRasterPlots{unitInd}.odors{1} = data(odor8Inds);
            allRasterPlots{unitInd}.odors{2} = data(odor14Inds);
            allRasterPlots{unitInd}.odors{3} = data(odor18Inds);
            allRasterPlots{unitInd}.allTrials = data;
            allRasterPlots{unitInd}.allSpikes = currSpikes;
%             figure;
%             data(1).times = currSpikes./60;
%             mypsth(data, 1);
%             
%             close;
            
%             %PLOT
%             figure;hold all
%             for odorInd = 1:length(unique(allSessions{1}.expParams{indx}.odorEventsId))
%                 currRaster = allRasterPlots{unitInd}.odors{odorInd};
%                 for trialInd = 1:size(currRaster,2)
%                     subplot(3,3,odorInd)
%                     scatter(currRaster(trialInd).times, ones(1,length(currRaster(trialInd).times)).*trialInd, 5, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
%                     hold on;
%                     
%                 end
%                 patch(xPatchVals, yPatchVals, [.5 .5 .5])
%                 %First half
%                 subplot(3,3,[odorInd + 3 odorInd + 6]);
%                 mypsth(currRaster(1:10),psthKernel);
%                 box off
%                 
%             end
%             
            
        end
    end


