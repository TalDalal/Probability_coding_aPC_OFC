function [] = plotPSTHmatrixOfRampingNeurons
%Load the data
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

% identifiedRamping = [8 9 13 14 15 18 21 22 23 26 28 30 32 33 34  50 51 52 53 54 63 66 ...
%     71 76 83 95 112 125 129 132 135 138 143 147  152 155 157 163 173 176 ...
%     179 186 189 191 194  221 223 224 228 236 239 240 249 250 253 254];

identifiedRamping = [8 9 13 14 15 18 21 22  26 28 30 32 33 34  50 51 52 53 54 63 66 ...
    71 76 83 95  132 143  155 157 163 173 176 ...
    179 189 191 194  221 223 224 228 239 240 249 250 253 254];
%%
c = 0;
psthKernel = 0.07;
zScoreFlag = 1;
PSTHstruct = [];
psthCounter = 0;
plotFlag = 0;
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            ISI = mouseData(recInd).data.ISIbetweenOdors./1000;
            odorDuration = mouseData(recInd).data.odor_duration./1000;
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                
                %% Compare the firing rate in the requested window
                c = c + 1;
                if sum(c == identifiedRamping)
                    
                    psthCounter = psthCounter + 1;
                    
                    
                    %----------A------------
                    % All trials
                    Atrials = mouseData(recInd).data.Atrials;
                    rasterA = mouseData(recInd).data.allRasterPlots(unitInd).data(Atrials);
                    
                    binsTime = mouseData(recInd).data.firingRateAnalysisBins;
                    baseliePeriod = find(binsTime < -ISI-odorDuration);
                    baselineFR_A = mean(mouseData(recInd).data.firingRates(unitInd).firingRateByBIn(Atrials,baseliePeriod),2);
                    
                    % All trials PSTH
                    [R,t] = mypsth(rasterA, psthKernel, 'n');
                    % Save the  PSTH
                    if zScoreFlag == 1
                        R = (R - mean(baselineFR_A))./std(baselineFR_A);
                    end
                    PSTHstruct(psthCounter).allTrials.A = [t;R];
                    
                    if plotFlag
                        figure;
                        plot(t, R); hold on;
                    end
                    R = [];t = [];baselineFR_A = [];

                    %----------C------------
                    Ctrials = mouseData(recInd).data.Ctrials;
                    rasterC = mouseData(recInd).data.allRasterPlots(unitInd).data(Ctrials);
                    baselineFR_C = mean(mouseData(recInd).data.firingRates(unitInd).firingRateByBIn(Ctrials,baseliePeriod),2);

                    [R,t] = mypsth(rasterC, psthKernel, 'n');
                    
                    % Save the  PSTH
                    if zScoreFlag == 1
                        R = (R - mean(baselineFR_C))./std(baselineFR_C);
                    end
                    % All trials PSTH
                    PSTHstruct(psthCounter).allTrials.C = [t;R];
                    
                    if plotFlag
                        plot(t, R);
                        close;
                    end

                    R = [];t = [];baselineFR_C = [];
                    

                    
                end
            end
        end
        
    end
end


%% Plot the PSTHs of all trials
requestedTimeWin = [-2.3 0];
deltaT = requestedTimeWin(2)-requestedTimeWin(1);

maxTimeWin = [-1 0];

for psthInd = 1:size(PSTHstruct,2)
    currTimeVec =[];firstInd = [];indToPlot = [];
    % --------A---------
    % The current time vec
    currTimeVec = PSTHstruct(psthInd).allTrials.A(1,:);
    
    % Compute the bin size of the PSTH
    psthBinSize = floor((currTimeVec(end)-currTimeVec(1))*1000./(length(currTimeVec)));
    
    % Find the relevant indices
    firstInd = find(currTimeVec >= requestedTimeWin(1),1);
    indToPlot = [firstInd : firstInd + deltaT*1000./psthBinSize-1];
    
    %Cut the psth and time vec in the requested timeWin
    currPSTH_A = PSTHstruct(psthInd).allTrials.A(2,indToPlot);
    currTimeToPlot = currTimeVec(indToPlot);
    PSTHmatA(psthInd,:) = currPSTH_A;
    
    %Find the max time
    currTimeToPlotShort = currTimeToPlot(find(currTimeToPlot >= maxTimeWin(1) & currTimeToPlot < maxTimeWin(2)));
    currPSTH_A_Short = currPSTH_A(find(currTimeToPlot >= maxTimeWin(1) & currTimeToPlot < maxTimeWin(2)));
    allPSTHMax_A(psthInd) = currTimeToPlotShort(find(currPSTH_A_Short==max(currPSTH_A_Short)));

    currTimeVec =[];firstInd = [];indToPlot = [];currTimeToPlot = [];
    
    % --------C---------
    % The current time vec
    currTimeVec = PSTHstruct(psthInd).allTrials.C(1,:);
    
    % Compute the bin size of the PSTH
    psthBinSize = floor((currTimeVec(end)-currTimeVec(1))*1000./(length(currTimeVec)));
    
    % Find the relevant indices
    firstInd = find(currTimeVec >= requestedTimeWin(1),1);
    indToPlot = [firstInd : firstInd + deltaT*1000./psthBinSize-1];
    
    %Cut the psth and time vec in the requested timeWin
    currPSTH_C = PSTHstruct(psthInd).allTrials.C(2,indToPlot);
    currTimeToPlot = currTimeVec(indToPlot);
    
    PSTHmatC(psthInd,:) = currPSTH_C;
    
    %Find the max time
        %Find the max time
    currTimeToPlotShort = currTimeToPlot(find(currTimeToPlot >= maxTimeWin(1) & currTimeToPlot < maxTimeWin(2)));
    currPSTH_A_Short = currPSTH_C(find(currTimeToPlot >= maxTimeWin(1) & currTimeToPlot < maxTimeWin(2)));
    allPSTHMax_C(psthInd) = currTimeToPlotShort(find(currPSTH_A_Short==max(currPSTH_A_Short)));
    


end
%Sort by max latency
% [~,maxLocs_A] = sort(allPSTHMax_A);
% sortPSTHmat_A = PSTHmatA(maxLocs_A,:);
% sortPSTHmat_C = PSTHmatC(maxLocs_A,:);

[~,maxLocs_A] = sort(allPSTHMax_A);
sortPSTHmat_A = PSTHmatA(maxLocs_A,:);
sortPSTHmat_C = PSTHmatC(maxLocs_A,:);

figure;
subplot(1,2,1)
imagesc(currTimeVec(indToPlot),1:size(sortPSTHmat_A,1),sortPSTHmat_A)
crameri acton
colorbar

subplot(1,2,2)
imagesc(currTimeVec(indToPlot),1:size(sortPSTHmat_C,1),sortPSTHmat_C)
colorbar
crameri acton


%------Average PSTH
firstOdorXpatch = [-ISI-odorDuration -ISI -ISI -ISI-odorDuration];
secondOdorXpatch = [0 odorDuration odorDuration 0];
yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
patchFaceAlpha = 0.2;
patchColor = [190, 190, 190]./255;
Acolor = [0,169,137]./255;%green
Ccolor = [171,62,143]./255;%purple;
figure;
hold all;
patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha, 'EdgeColor', 'none')
patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha, 'EdgeColor', 'none')
errorbar_patch(currTimeVec(indToPlot), nanmean(sortPSTHmat_A), nanstd(sortPSTHmat_A)./sqrt(size(sortPSTHmat_A,1)), Acolor);
errorbar_patch(currTimeVec(indToPlot), nanmean(sortPSTHmat_C), nanstd(sortPSTHmat_C)./sqrt(size(sortPSTHmat_C,1)), Ccolor);
xlabel('Time relative to CS (S)');
set(gca, 'FontSize', 14');box off;
ylabel('Z-score')
title(['N = ' num2str(size(sortPSTHmat_A,1))])
set(gcf, 'Renderer', 'painters')
xlim(requestedTimeWin)
% 
