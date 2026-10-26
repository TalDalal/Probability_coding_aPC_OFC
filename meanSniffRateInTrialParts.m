function [] = meanSniffRateInTrialParts(allMiceData,fgTimeWindow, baselinePeriod)
highColor = [0,169,137]./255;%green
lowColor = [171,62,143]./255;%purple

c = 0;


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
            highRaster_all = mouseData(recInd).data.SniffRaster.A;
            lowRaster_all = mouseData(recInd).data.SniffRaster.C;
            
            % High CS+\-
            highSniffRatsterCSplus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.targetTrials.A);
            highSniffRatsterCSminus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.tMinusTrials.A);
            
            %Low CS+\-
            lowSniffRatsterCSplus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.targetTrials.C);
            lowSniffRatsterCSminus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.tMinusTrials.C);
        else
            %Alltrials
            highRaster_all = mouseData(recInd).data.SniffRaster.C;
            lowRaster_all = mouseData(recInd).data.SniffRaster.A;
            
            % High CS+\-
            highSniffRatsterCSplus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.targetTrials.C);
            highSniffRatsterCSminus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.tMinusTrials.C);
            
            %Low CS+\-
            lowSniffRatsterCSplus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.targetTrials.A);
            lowSniffRatsterCSminus = mouseData(recInd).data.SniffRaster.allTrials(mouseData(recInd).data.tMinusTrials.A);
        end
        
        if isempty(highRaster_all) | isempty(lowRaster_all)
            continue;
        end
        c = c+1;
        %Predicitng odors
        predictingOdorsSniffRate(c,1) = compute_Z_sniff_rate(highRaster_all, baselinePeriod, fgTimeWindow(1,:));
        predictingOdorsSniffRate(c,2) = compute_Z_sniff_rate(lowRaster_all, baselinePeriod, fgTimeWindow(1,:));
        %Delay
        delaySniffRate(c,1) = compute_Z_sniff_rate(highRaster_all, baselinePeriod, fgTimeWindow(2,:));
        delaySniffRate(c,2) = compute_Z_sniff_rate(lowRaster_all, baselinePeriod, fgTimeWindow(2,:));
        %CS+ odor
        csPlusSniffRate(c,1) = compute_Z_sniff_rate(highSniffRatsterCSplus, baselinePeriod, fgTimeWindow(3,:));
        csPlusSniffRate(c,2) = compute_Z_sniff_rate(lowSniffRatsterCSplus, baselinePeriod, fgTimeWindow(3,:));
        %CS- odor
        csMinusSniffRate(c,1) = compute_Z_sniff_rate(highSniffRatsterCSminus, baselinePeriod, fgTimeWindow(3,:));
        csMinusSniffRate(c,2) = compute_Z_sniff_rate(lowSniffRatsterCSminus, baselinePeriod, fgTimeWindow(3,:));

    end
end
delaySniffRate(find(delaySniffRate==0)) = nan;
predictingOdorsSniffRate(find(predictingOdorsSniffRate==0)) = nan;
csPlusSniffRate(find(csPlusSniffRate==0)) = nan;
csMinusSniffRate(find(csMinusSniffRate==0)) = nan;
figure;
[~,pDelay] = ttest(delaySniffRate(:,1), delaySniffRate(:,2));
barwitherr(nanstd(delaySniffRate)./sqrt(size(delaySniffRate,1)), nanmean(delaySniffRate))
set(gca, 'FontSize', 18);box off;
ylabel('Z-score'); set(gca, 'XTickLabel', {'High', 'Low'})
title(['P = ' num2str(pDelay)])

end

function Z_Rate = compute_Z_sniff_rate(data, baselinePeriod, fgPeriod)
    % Ensure baselinePeriod and fgPeriod are 2-element vectors
    if length(baselinePeriod) ~= 2 || length(fgPeriod) ~= 2
        error('Both baselinePeriod and fgPeriod must be 2-element vectors specifying the start and end of the period in seconds.');
    end

    % Calculate the durations of the baseline and fg periods
    baselineDuration = abs(diff(baselinePeriod));
    fgDuration = abs(diff(fgPeriod));

    % Initialize evoked firing rate vector
    numTrials = length(data);
    evokedFR = zeros(numTrials, 2);

    % Loop through each trial
    for i = 1:numTrials
        % Extract spike times for the current trial
        spikeTimes = data(i).times;

        % Count spikes within the baseline period
        numBaselineSpikes = sum(spikeTimes >= baselinePeriod(1) & spikeTimes <= baselinePeriod(2));

        % Count spikes within the fg period
        numFgSpikes = sum(spikeTimes >= fgPeriod(1) & spikeTimes <= fgPeriod(2));

        % Compute firing rates
        baselineFR = numBaselineSpikes / baselineDuration;
        fgFR = numFgSpikes / fgDuration;

        % Compute evoked firing rate
        evokedFR(i,:) = [fgFR  baselineFR];
    end
    Z_Rate = mean(evokedFR(:,1) - evokedFR(:,2))./std(evokedFR(:,2));
    if isinf(Z_Rate) | isnan(Z_Rate)
        Z_Rate = 0;
    end
end