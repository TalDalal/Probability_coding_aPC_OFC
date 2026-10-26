function [high_mat, low_mat, t_A] = z_scored_neurons_matrix(allMiceData,bgPeriod, trialType, brainRegion)

c = 0;
psthKernel = 0.07;
firstOdorTimes = [-2 -1];
secondOdorTimes = [0 1];
numofSecondsToView = 5;
high_mat = [];low_mat = [];
high_peak_locs = [];low_peak_locs = [];
CS_activity_high = [];CS_activity_low = [];
numOfSamples = 400;
%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi(brainRegion ,mouseData(recInd).brainRegion)
            
            
            Atrials = mouseData(recInd).data.Atrials;
            A_CS_plus_trials = mouseData(recInd).data.targetTrials.A;
            A_CS_minus_trials = mouseData(recInd).data.tMinusTrials.A;
            
            Ctrials = mouseData(recInd).data.Ctrials;
            C_CS_plus_trials = mouseData(recInd).data.targetTrials.C;
            C_CS_minus_trials = mouseData(recInd).data.tMinusTrials.C;
            
            
            switch trialType
                case 'allTrials'
                    fgTrials_A = Atrials;
                    fgTrials_C = Ctrials;
                    
                case 'CS+'% CS + Odor
                    fgTrials_A = A_CS_plus_trials;
                    fgTrials_C = C_CS_plus_trials;
                    
                case 'CS-' % CS - Odor
                    fgTrials_A = A_CS_minus_trials;
                    fgTrials_C = C_CS_minus_trials;
                    
            end
            
            % Run over all units from the current session and compute the
            % auROC
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                
                c = c+1;
                
                currUnitBaseline = computeBaselineFiringRate(mouseData(recInd).data.allRasterPlots(unitInd).data, bgPeriod);
                %A odor
                rasterA = mouseData(recInd).data.allRasterPlots(unitInd).data(fgTrials_A);
%                 baselineFR_A = computeBaselineFiringRate(rasterA, bgPeriod);
                % z-score the psth
                [R_A,t_A] = mypsth(rasterA, psthKernel, 'n');
                Z_psth_A = (R_A - mean(currUnitBaseline))./std(currUnitBaseline);
               
                
                
                % C odor
                rasterC = mouseData(recInd).data.allRasterPlots(unitInd).data(fgTrials_C);
%                 baselineFR_C = computeBaselineFiringRate(rasterC, bgPeriod);
                % z-score the psth
                [R_C,t_C] = mypsth(rasterC, psthKernel, 'n');
                Z_psth_C = (R_C - mean(currUnitBaseline))./std(currUnitBaseline);
                
                
                
                
                if t_A(1) > bgPeriod(2) | t_C(1) > bgPeriod(2) | length(t_A) < numOfSamples | length(t_C) < numOfSamples
                    Z_psth_A = zeros(1,numOfSamples+1);
                    Z_psth_C = zeros(1,numOfSamples+1);
                    
                    high_mat(end+1, :) = Z_psth_A;%./max_H;
                    low_mat(end+1, :) = Z_psth_C;%./max_L;
                else
                % Cut the PSTHs
                startLoc = find(t_A > bgPeriod(2),1);
                locsToCut_A = startLoc:startLoc+numOfSamples;%ceil(numofSecondsToView/mean(diff(t_A)));
                Z_psth_A = Z_psth_A(locsToCut_A);
                t_A = t_A(locsToCut_A);
                
                startLoc = find(t_C > bgPeriod(2),1);
                locsToCut_C = startLoc:startLoc+numOfSamples;%ceil(numofSecondsToView/mean(diff(t_C)));
                Z_psth_C = Z_psth_C(locsToCut_C);
                t_C = t_C(locsToCut_C);
                
%                 if ~isequal(length(locsToCut_A), length(Z_psth_A)) | ~isequal(length(locsToCut_C), length(Z_psth_C))
%                     continue
%                 end
                
                % Assign by probability
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C

                    
                    max_H = max(Z_psth_A(find(t_A > firstOdorTimes(1) & t_A < secondOdorTimes(2)+1)));
                    max_L = max(Z_psth_C(find(t_C > firstOdorTimes(1) & t_C < secondOdorTimes(2)+1)));
                    high_peak_locs(end+1) = t_A(find(Z_psth_A == max_H));
                    low_peak_locs(end+1) = t_C(find(Z_psth_C == max_L));


                    
                    
                    
                    high_mat(end+1, :) = Z_psth_A;%./max_H;
                    low_mat(end+1, :) = Z_psth_C;%./max_L;

                else

                    
                    max_H = max(Z_psth_C(find(t_C > firstOdorTimes(1) & t_C < secondOdorTimes(2)+1)));
                    max_L = max(Z_psth_A(find(t_A > firstOdorTimes(1) & t_A < secondOdorTimes(2)+1)));
                    high_peak_locs(end+1) = t_C(find(Z_psth_C == max_H));
                    low_peak_locs(end+1) = t_A(find(Z_psth_A == max_L));


                    
                    
                    
                    high_mat(end+1, :) = Z_psth_C;
                    low_mat(end+1, :) = Z_psth_A;

                end
                
                
                end
            end
        end
    end
end
%% plot the matrices sorted by the peal latency

figure;
subplot(1,2,1)
plotPeakSortedMatrix(high_mat, t_A)
hold all
%first odor
plot([firstOdorTimes(1) firstOdorTimes(1)], [size(high_mat,1)  1], 'w--')
plot([firstOdorTimes(2) firstOdorTimes(2)], [size(high_mat,1)  1], 'w--')

%second odor 
plot([secondOdorTimes(1) secondOdorTimes(1)], [size(high_mat,1)  1], 'w--')
plot([secondOdorTimes(2) secondOdorTimes(2)], [size(high_mat,1)  1], 'w--')
title('H')
set(gca, 'FontSize', 18);box off;
xlabel('Time (sec)');ylabel('Neurons')

subplot(1,2,2)
plotPeakSortedMatrix(low_mat, t_A)
hold all
%first odor
plot([firstOdorTimes(1) firstOdorTimes(1)], [size(high_mat,1)  1], 'w--')
plot([firstOdorTimes(2) firstOdorTimes(2)], [size(high_mat,1)  1], 'w--')

%second odor 
plot([secondOdorTimes(1) secondOdorTimes(1)], [size(high_mat,1)  1], 'w--')
plot([secondOdorTimes(2) secondOdorTimes(2)], [size(high_mat,1)  1], 'w--')
title('L');set(gca, 'FontSize', 18);box off;
colormap(slanCM('magma'))

% % timeVec = 
% %Sort the auROC responses
% % [~,locs_H] = sort(CS_activity_high, 'descend');
% % 
% % [~,locs_H] = sort(high_peak_locs, 'ascend');
% % [~,locs_L] = sort(low_peak_locs, 'ascend');
% [taskModulationMat] = taskModulatedNeurons(allMiceData, 0.01, [-2 -1; -.33 0 ; 0 1], [-4 -3]);
% [sorted_binary, sort_order] = sort_binary_matrix(taskModulationMat); 
% sorted_H = high_mat(flipud(sort_order), :); 
% sorted_L = low_mat(flipud(sort_order), :); 
% 
% 
% 
% figure;
% subplot(1,2,1)
% imagesc(t_A,1:size(sorted_H,1), sorted_H)
% caxis([-3 3])
% hold all
% %first odor
% plot([firstOdorTimes(1) firstOdorTimes(1)], [size(high_mat,1)  1], 'w--')
% plot([firstOdorTimes(2) firstOdorTimes(2)], [size(high_mat,1)  1], 'w--')
% 
% %second odor 
% plot([secondOdorTimes(1) secondOdorTimes(1)], [size(high_mat,1)  1], 'w--')
% plot([secondOdorTimes(2) secondOdorTimes(2)], [size(high_mat,1)  1], 'w--')
% 
% set(gca, 'FontSize', 18);box off;
% xlabel('Time (sec)');ylabel('Neurons')
% title('H')
% % crameri oslo
% % colormap bone
% 
% 
% subplot(1,2,2)
% imagesc(t_A,1:size(sorted_L,1), sorted_L)
% caxis([-3 3])
% hold all
% %first odor
% plot([firstOdorTimes(1) firstOdorTimes(1)], [size(high_mat,1)  1], 'w--')
% plot([firstOdorTimes(2) firstOdorTimes(2)], [size(high_mat,1)  1], 'w--')
% 
% %second odor 
% plot([secondOdorTimes(1) secondOdorTimes(1)], [size(high_mat,1)  1], 'w--')
% plot([secondOdorTimes(2) secondOdorTimes(2)], [size(high_mat,1)  1], 'w--')
% 
% set(gca, 'FontSize', 18);box off;
% xlabel('Time (sec)');ylabel('Neurons')
% title('L')
% % crameri oslo
% % colormap bone
end

function [] = plotPeakSortedMatrix(high_mat, t_A)
zTH = 1;excMat = [];inhMat = [];firstPeak = [];firstPeak_inh = [];noResponseMat = [];

for ind = 1:size(high_mat,1)
    trialTimeInds = find(t_A >= -2 & t_A < 2);
    currPeakLoc = find(high_mat(ind,trialTimeInds) > zTH,1);
    
    if ~isempty(currPeakLoc)
        firstPeak(end+1) = t_A(currPeakLoc);
        excMat(end+1,:) = high_mat(ind,:);
    else
        currPeakLoc = find(high_mat(ind,trialTimeInds) < -zTH/2,1);
        if isempty(currPeakLoc)
            noResponseMat(end+1,:) = high_mat(ind,:);
        else
            firstPeak_inh(end+1) = t_A(currPeakLoc);
            inhMat(end+1,:) = high_mat(ind,:);
        end
    end
end
[~,peakTimeSort] = sort(firstPeak);
[~,peakTimeSort_inh] = sort(firstPeak_inh);

% figure;
imagesc(t_A,1:size(high_mat,1), [excMat(peakTimeSort,:) ; inhMat(peakTimeSort_inh,:) ; noResponseMat])
caxis([-1 3])

end



function baselineFR = computeBaselineFiringRate(data, baselinePeriod)
    % Ensure baselinePeriod is a 2-element vector
    if length(baselinePeriod) ~= 2
        error('baselinePeriod must be a 2-element vector specifying the start and end of the period in seconds.');
    end
    
    % Calculate the duration of the baseline period
    baselineDuration = abs(diff(baselinePeriod));
    
    % Initialize baseline firing rate vector
    numTrials = length(data);
    baselineFR = zeros(1, numTrials);
    
    % Loop through each trial
    for i = 1:numTrials
        % Extract spike times for the current trial
        spikeTimes = data(i).times;
        
        % Count spikes within the baseline period
        numSpikes = sum(spikeTimes >= baselinePeriod(1) & spikeTimes <= baselinePeriod(2));
        
        % Compute firing rate for the baseline period
        baselineFR(i) = numSpikes / baselineDuration;
    end
end


