function [evokedFR] = computeEvokedFRfromRaster(inputRaster, bgWin, fgWin)
evokedFR = nan(1,size(inputRaster,2));
for ind = 1:size(inputRaster,2)
    %baseline firing rate
    bgFR = length(find(inputRaster(ind).times >= bgWin(1) & inputRaster(ind).times < bgWin(2)))./diff(bgWin);
    %fg firing rate
    fgFR = length(find(inputRaster(ind).times >= fgWin(1) & inputRaster(ind).times < fgWin(2)))./diff(fgWin);
    
    evokedFR(ind) = fgFR-bgFR;
end