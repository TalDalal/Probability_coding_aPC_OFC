function [normalizedPSTH, t] = normalizePSTHfromRasterPlot(raster, smoothKernel, bgPeriod)

firstLastPSTHvalue = [-4 3];

[R,t] = mypsth(raster,smoothKernel, 'n') ;

%Compute the bins of the time vector
currTimeBin = round(median(diff(t)),3);

%Find the first index
%             if currTime_A(1) < firstLastPSTHvalue(1)
firstInd = find(t >= firstLastPSTHvalue(1),1);
finalPSTHlength = diff(firstLastPSTHvalue)/currTimeBin;

normalizedPSTH = [];
if t(1) < bgPeriod(2) & (firstInd + finalPSTHlength) < length(R)
    
    R = R(firstInd: firstInd + finalPSTHlength -1);
    t = t(firstInd: firstInd + finalPSTHlength -1);
    
    % normalize
    baseline_activity = R(find(t >= bgPeriod(1) & t < bgPeriod(2)));
    
    meanBaseline_High = mean(baseline_activity);
    meanBaseline_High(isnan(meanBaseline_High)) = 0;
    normalizedPSTH = R - meanBaseline_High;
end
