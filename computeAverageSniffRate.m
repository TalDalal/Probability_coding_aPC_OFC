function [] = computeAverageSniffRate(allMiceData, timeRange)

lowSniffMat = [];highSniffMat = [];highSniffMatCSplus = [];lowSniffMatCSplus = [];
highSniffMatCSminus = [];lowSniffMatminus = [];


highColor = [0,169,137]./255;%green
lowColor = [171,62,143]./255;%purple
patchColor = [190, 190, 190]./255;

firstOdorOnset = -2;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
minMaxPatch = [-4 6];
sniffPSTHkernel = .1;


for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    
    for recInd = 1:size(mouseData,2)
        
        % Exclude pretraining sessions
        if mouseData(recInd).sessionNum < 0
            continue;
        end
        
        % Check the probability
        if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
            %Alltrials
            highSniff = mouseData(recInd).data.sniffPSTHs.A;
            lowSniff = mouseData(recInd).data.sniffPSTHs.C;
            
            % High CS+\-
            highSniffRatsterCSplus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.targetTrials.A);
            highSniffRatsterCSminus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.tMinusTrials.A);
            
            %Low CS+\-
            lowSniffRatsterCSplus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.targetTrials.C);
            lowSniffRatsterCSminus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.tMinusTrials.C);
        else
            %Alltrials
            highSniff = mouseData(recInd).data.sniffPSTHs.C;
            lowSniff = mouseData(recInd).data.sniffPSTHs.A;
            
            % High CS+\-
            highSniffRatsterCSplus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.targetTrials.C);
            highSniffRatsterCSminus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.tMinusTrials.C);
            
            %Low CS+\-
            lowSniffRatsterCSplus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.targetTrials.A);
            lowSniffRatsterCSminus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.tMinusTrials.A);
        end
        
        if isempty(highSniff) | isempty(lowSniff)
            continue;
        end
        
        
        if highSniff(2,1) < timeRange(1) & lowSniff(2,1) < timeRange(1)
            
            %-----------------------High
            
            %^^^^^^^^^ All trials sniff rate ^^^^^
            [currSniffHigh, binSize] = zScoreSniffPSTH(highSniff(1,:), highSniff(2,:), timeRange, firstOdorOnset);
            
            %^^^^^^^^ CS+^^^^^^^^^^
            [RhighCSPlus,thighCSPlus] = mypsth(highSniffRatsterCSplus, sniffPSTHkernel, 'n');
            currSniffHighCSplus = zScoreSniffPSTH(RhighCSPlus, thighCSPlus, timeRange, firstOdorOnset);
            
            %^^^^^^^^ CS-^^^^^^^^^^
            [RhighCSminus,thighCSminus] = mypsth(highSniffRatsterCSminus, sniffPSTHkernel, 'n');
            currSniffHighCSminus = zScoreSniffPSTH(RhighCSminus, thighCSminus, timeRange, firstOdorOnset);
            
            %-----------------------Low
            
            %^^^^^^^^^ All trials sniff rate ^^^^^
            currSniffLow = zScoreSniffPSTH(lowSniff(1,:), lowSniff(2,:), timeRange, firstOdorOnset);
            
            %^^^^^^^^ CS+^^^^^^^^^^
            [RlowCSPlus,tlowCSPlus] = mypsth(lowSniffRatsterCSplus, sniffPSTHkernel, 'n');
            currSniffLowCSplus = zScoreSniffPSTH(RlowCSPlus, tlowCSPlus, timeRange, firstOdorOnset);
            
            %^^^^^^^^ CS-^^^^^^^^^^
            [RlowCSminus,tlowCSminus] = mypsth(lowSniffRatsterCSminus, sniffPSTHkernel, 'n');
            currSniffLowCSminus = zScoreSniffPSTH(RlowCSminus, tlowCSminus, timeRange, firstOdorOnset);
            
            
            % Save the data to a matrix
            %All trials
            if ~isempty(currSniffHigh)
                highSniffMat(end+1,:) = currSniffHigh;
            end
            if ~isempty(currSniffLow)
                lowSniffMat(end+1,:) = currSniffLow;
            end
            %CS+
            if ~isempty(currSniffHighCSplus)
                highSniffMatCSplus(end+1,:) = currSniffHighCSplus;
            end
            if ~isempty(currSniffLowCSplus)
                lowSniffMatCSplus(end+1,:) = currSniffLowCSplus;
            end
            %CS-
            if ~isempty(currSniffHighCSminus)
                highSniffMatCSminus(end+1,:) = currSniffHighCSminus;
            end
            if ~isempty(currSniffLowCSminus)
                lowSniffMatminus(end+1,:) = currSniffLowCSminus;
            end
        end
        
    end
end
%%
figure;
subplot(1,3,1)
%Odor markers
patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

errorbar_patch(-3:binSize:3, mean(highSniffMat), std(highSniffMat)./sqrt(size(highSniffMat,1)), highColor)
hold on;
errorbar_patch(-3:binSize:3, mean(lowSniffMat), std(lowSniffMat)./sqrt(size(lowSniffMat,1)), lowColor)
set(gca, 'FontSize', 18);box off;xlabel('Time (S)');ylabel('Sniff rate (Z-score)')
xlim([timeRange(1) .2])


%--------CS+------------
subplot(1,3,2)
patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

errorbar_patch(-3:binSize:3, mean(highSniffMatCSplus), std(highSniffMatCSplus)./sqrt(size(highSniffMatCSplus,1)), highColor)
hold on;
errorbar_patch(-3:binSize:3, mean(lowSniffMatCSplus), std(lowSniffMatCSplus)./sqrt(size(lowSniffMatCSplus,1)), lowColor)
set(gca, 'FontSize', 18);box off;xlabel('Time (S)');
title('CS+');xlim([-.5 timeRange(2)])

%--------CS- ------------
subplot(1,3,3)
patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPatch(1) minMaxPatch(1) minMaxPatch(2) minMaxPatch(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

errorbar_patch(-3:binSize:3, mean(highSniffMatCSminus), std(highSniffMatCSminus)./sqrt(size(highSniffMatCSminus,1)), highColor)
hold on;
errorbar_patch(-3:binSize:3, mean(lowSniffMatminus), std(lowSniffMatminus)./sqrt(size(lowSniffMatminus,1)), lowColor)
set(gca, 'FontSize', 18);box off;xlabel('Time (S)');
title('CS-');xlim([-.5 timeRange(2)])




end
function [currSniffRate, binSize] = zScoreSniffPSTH(sniffPSTH, timeVec, timeRange, firstOdorOnset)
currSniffRate = [];
if timeVec(1) < timeRange(1) & timeVec(end) > timeRange(2)
    
    %Bin size
    binSize = median(diff(timeVec));
    
    % Compute the number of bins in the PSTH
    numOfTimeBins = round(diff(timeRange)/binSize);
    startingBin = find(timeVec >= timeRange(1),1);
    bgPeriod = find(find(timeVec < firstOdorOnset));
    
    %Curr PSTH
    currSniffRate = sniffPSTH(1, startingBin:startingBin + numOfTimeBins-1);
    %Z-score
    currSniffRate = (currSniffRate - mean(sniffPSTH(1, bgPeriod)))./std(sniffPSTH(1, bgPeriod));
end
end

