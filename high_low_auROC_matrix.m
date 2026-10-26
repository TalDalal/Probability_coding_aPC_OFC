function [allAuROCtraces_high, allAuROCtraces_low, ROCvalsPeriodToSort_high, timeBins_A, originalPSTH] = high_low_auROC_matrix(allMiceData,bgPeriod,auROCWinSize, periodToSort, trialType)

c = 0;
allAuROCtraces_high = [];
allAuROCtraces_low = [];
ROCvalsPeriodToSort_high = [];
ROCvalsPeriodToSort_low = [];
psthKernel = 0.05;
firstOdorTimes = [-2 -1];
secondOdorTimes = [0 1];
%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            
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
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                %Compute the ROC for A trials
                [auROC_A, timeBins_A] = compute_auROC(mouseData(recInd).data, currFRmat, bgPeriod, fgTrials_A, auROCWinSize);
                
                %Compute the ROC for C trials
                [auROC_C, timeBins_C] = compute_auROC(mouseData(recInd).data, currFRmat, bgPeriod, fgTrials_C, auROCWinSize);
                
                % Assign by probability
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C

                    %High
                    allAuROCtraces_high(end+1,:) = auROC_A;
                    ROCvalsPeriodToSort_high(end+1) = mean(auROC_A(find(timeBins_A >= periodToSort(1) & timeBins_A < periodToSort(2))));
                    auROC_A = [];
                    
                    %Low
                    allAuROCtraces_low(end+1,:) = auROC_C;
                    ROCvalsPeriodToSort_low(end+1) = mean(auROC_C(find(timeBins_C >= periodToSort(1) & timeBins_C < periodToSort(2))));
                    auROC_C = [];
                    
                    % Save the original PSTH
                    rasterA = mouseData(recInd).data.allRasterPlots(unitInd).data(fgTrials_A);
                    [R,t] = mypsth(rasterA, psthKernel, 'n');
                    originalPSTH(c).high = [t;R];
                    
                    rasterC = mouseData(recInd).data.allRasterPlots(unitInd).data(fgTrials_C);
                    [R,t] = mypsth(rasterC, psthKernel, 'n');
                    originalPSTH(c).low = [t;R];
                else
                    %High
                    allAuROCtraces_high(end+1,:) = auROC_C;
                    ROCvalsPeriodToSort_high(end+1) = mean(auROC_C(find(timeBins_C >= periodToSort(1) & timeBins_C < periodToSort(2))));
                    auROC_C = [];
                    
                    %Low
                    allAuROCtraces_low(end+1,:) = auROC_A;
                    ROCvalsPeriodToSort_low(end+1) = mean(auROC_A(find(timeBins_A >= periodToSort(1) & timeBins_A < periodToSort(2))));
                    auROC_C = [];
                    
                    % Save the original PSTH
                    rasterA = mouseData(recInd).data.allRasterPlots(unitInd).data(fgTrials_A);
                    [R,t] = mypsth(rasterA, psthKernel, 'n');
                    originalPSTH(c).low = [t;R];
                    
                    rasterC = mouseData(recInd).data.allRasterPlots(unitInd).data(fgTrials_C);
                    [R,t] = mypsth(rasterC, psthKernel, 'n');
                    originalPSTH(c).high = [t;R]; 
                end
                
                
                
            end
        end
    end
end
%% plot the matrices sorted by the firing rate in the 'periodToSort' window.

%Sort the auROC responses
[~,locs] = sort(ROCvalsPeriodToSort_high, 'descend');

figure;
subplot(1,2,1)
imagesc(timeBins_A,1:length(allAuROCtraces_high), allAuROCtraces_high(locs,:))
caxis([0.2 1])
hold all
%first odor
plot([firstOdorTimes(1) firstOdorTimes(1)], [size(allAuROCtraces_high,1)  1], 'k--')
plot([firstOdorTimes(2) firstOdorTimes(2)], [size(allAuROCtraces_high,1)  1], 'k--')

%second odor 
plot([secondOdorTimes(1) secondOdorTimes(1)], [size(allAuROCtraces_high,1)  1], 'k--')
plot([secondOdorTimes(2) secondOdorTimes(2)], [size(allAuROCtraces_high,1)  1], 'k--')

set(gca, 'FontSize', 15);box off;
xlabel('Time (sec)');ylabel('Neurons')
title('High auROC')
% xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
colormap('bone')


subplot(1,2,2)
imagesc(timeBins_A,1:length(allAuROCtraces_low), allAuROCtraces_low(locs,:))
caxis([0.2 1])
hold all
%first odor
plot([firstOdorTimes(1) firstOdorTimes(1)], [size(allAuROCtraces_low,1)  1], 'k--')
plot([firstOdorTimes(2) firstOdorTimes(2)], [size(allAuROCtraces_low,1)  1], 'k--')

%second odor 
plot([secondOdorTimes(1) secondOdorTimes(1)], [size(allAuROCtraces_low,1)  1], 'k--')
plot([secondOdorTimes(2) secondOdorTimes(2)], [size(allAuROCtraces_low,1)  1], 'k--')

set(gca, 'FontSize', 15);box off;
xlabel('Time (sec)');ylabel('Neurons')
title('Low auROC')
% xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
colormap('bone')
ylabel('')
set(gca, 'YTickLabel', '')
colorbar


