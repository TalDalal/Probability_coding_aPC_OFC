function [zScoredEvokedResponse] = computeZscorefromRaster(inputRaster, bgWin, fgWin)

evokedFR = nan(length(inputRaster), 2);

for ind = 1:length(inputRaster)
    % baseline firing rate
    bgFR = sum(inputRaster(ind).times >= bgWin(1) & inputRaster(ind).times < bgWin(2)) ./ diff(bgWin);
    
    % foreground (evoked) firing rate
    fgFR = sum(inputRaster(ind).times >= fgWin(1) & inputRaster(ind).times < fgWin(2)) ./ diff(fgWin);
    
    evokedFR(ind,:) = [fgFR bgFR];
end

% --- use difference across trials ---
diffFR = evokedFR(:,1) - evokedFR(:,2);

% remove NaNs if any
diffFR = diffFR(~isnan(diffFR));

% compute std safely
sigma = std(diffFR);

% protect against tiny or zero std
sigma = max(sigma, 1e-6);

% final z-score
zScoredEvokedResponse = mean(diffFR) ./ sigma;

end