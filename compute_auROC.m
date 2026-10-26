function [auROC, timeBins] = compute_auROC(params, frMat, bgWin, fgTrials, winSize)

plotFlag = 0;
% Create the time bins and the firing for condition A
timeBins = params.firingRateAnalysisBins(1:end-1);
binSize = mean(diff(timeBins));
winSize = winSize/binSize/1000;% how namy bins to sum
fgFiringRates = frMat(fgTrials,:);

% Basline firing rate distribution
bgLocs = find(timeBins >= bgWin(1) & timeBins < bgWin(2));
bgDist = frMat(:,bgLocs);
bgDist = bgDist(:);

auROC = [];
%bgLocs(end)+1:length(timeBins);
for binInd = 1:length(timeBins)-winSize
    currBinFR = mean(fgFiringRates(:,int16(binInd:binInd+winSize-1))');
    % for binInd = 1:length(timeBins)
    %     currBinFR = AfiringRates(:,binInd);
    
    TPR = [];FPR = [];auc = 0;c = 0;
    for frTH = 0:1:max(currBinFR(:))
        c = c + 1;
        %Compute TPR and FPR
        TPR(end+1) = length(find(currBinFR >= frTH))./length(currBinFR);
        FPR(end+1) = length(find(bgDist >= frTH))./length(bgDist);
        
        if c > 1
            auc = auc + (-(FPR(end)- FPR(end-1))*(TPR(end)+TPR(end-1))/2);
        end
        
    end
    
    auROC(end+1) = auc;
    
end
timeBins = timeBins(1:end-winSize);
if plotFlag
    figure;
    plot(timeBins, auROC)
end

%for null cases
nullBins = find(auROC==0);
if ~isempty(nullBins)
    auROC(nullBins) = median(auROC);
end






