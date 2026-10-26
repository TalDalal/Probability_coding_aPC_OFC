function [outputStruct] = detectPEneurons(bgWin, fgTimeWin, pValueTH, minFRdelta, plotFlag)
if nargin < 4
    minFRdelta = 0;
end
normFlag = 1;
% plotFlag = 1;%plot the examples
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

responseMat = [];
FRmatFG = [];
c = 0;
psthKernel = 0.07;
PSTHstruct = [];
signifCounter = 0;

identifiedRamping = [8 9 13 14 15 18 21 22 23 26 28 30 32 33 34  50 51 52 53 54 63 66 ...
                    71 76 83 95 112 125 129 132 135 138 143 147  152 155 157 163 173 176 ...
                    179 186 189 191 194  221 223 224 228 236 239 240 249 250 253 254];


%% Run over all neurons

for miceInd = 1:size(allMiceData,2)% Across mice
    
    mouseData = allMiceData(miceInd).allRecs;
    relativeSessionNum = [];
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            ISI = mouseData(recInd).data.ISIbetweenOdors./1000;
            odorDuration = mouseData(recInd).data.odor_duration./1000;
            
            % trials indices
            Atrials = mouseData(recInd).data.Atrials;
            Ctrials = mouseData(recInd).data.Ctrials;
            
            %CS+
            targetTrialsA = [mouseData(recInd).data.trialOutcome.hit.A ...
                mouseData(recInd).data.trialOutcome.miss.A];
            
            targetTrialsC = [mouseData(recInd).data.trialOutcome.hit.C ...
                mouseData(recInd).data.trialOutcome.miss.C];
            
            %CS-
            nonTargetTrialsA = [mouseData(recInd).data.trialOutcome.CR.A ...
                mouseData(recInd).data.trialOutcome.FA.A];
            
            nonTargetTrialsC = [mouseData(recInd).data.trialOutcome.CR.C ...
                mouseData(recInd).data.trialOutcome.FA.C];
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                
                
                c = c + 1;
                
                %% Compare the firing rate in the requested window
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                %% A trials - Target odor (CS+)
                Amat_Target = currFRmat(targetTrialsA,:);
                
                bgFR_target = mean(Amat_Target(:,find(timeBins >= bgWin(1) & timeBins < bgWin(2))),2);
                
                FGperiodFR_target = mean(Amat_Target(:,find(timeBins >= fgTimeWin(1) & timeBins < fgTimeWin(2))),2);
                
                evokedFR_A_target = FGperiodFR_target - mean(bgFR_target);
                
                
                % A trials -  non Target odor (CS-)
                Amat_nonTarget = currFRmat(nonTargetTrialsA,:);
                
                bgFR_nonTarget = mean(Amat_nonTarget(:,find(timeBins >= bgWin(1) & timeBins < bgWin(2))),2);
                
                FGperiodFR_nonTarget = mean(Amat_nonTarget(:,find(timeBins >= fgTimeWin(1) & timeBins < fgTimeWin(2))),2);
                
                evokedFR_A_nonTarget = FGperiodFR_nonTarget - mean(bgFR_nonTarget);
                
                
                
                %STAT
                %Test if the response is different than baseline
                [h_bgFgPvalA_Target, ~] = ttest(bgFR_target, FGperiodFR_target, 'Alpha', pValueTH);
                
                % If the evoked delta is too small, does not considered as
                % a response
                if abs(mean(evokedFR_A_target)) < minFRdelta
                    h_bgFgPvalA_Target = 0;
                end
                
                [h_bgFgPvalA_nonTarget, ~] = ttest(bgFR_nonTarget, FGperiodFR_nonTarget, 'Alpha', pValueTH);
                
                % If the evoked delta is too small, does not considered as
                % a response
                if abs(mean(evokedFR_A_nonTarget)) < minFRdelta
                    h_bgFgPvalA_nonTarget = 0;
                end
                
                % Check if there was a response to the odor 
                CS_plus_binaryVec_A(c) = h_bgFgPvalA_Target;
                CS_minus_binaryVec_A(c) = h_bgFgPvalA_nonTarget;
                
                bgFR_target = [];FGperiodFR_target = [];bgFR_nonTarget = [];FGperiodFR_nonTarget = [];
                
                
                
                %% ---------- C trials
                
                % C trials - Target odor (CS+)
                Cmat_Target = currFRmat(targetTrialsC,:);
                
                bgFR_target = mean(Cmat_Target(:,find(timeBins >= bgWin(1) & timeBins < bgWin(2))),2);
                
                
                FGperiodFR_target = mean(Cmat_Target(:,find(timeBins >= fgTimeWin(1) & timeBins < fgTimeWin(2))),2);
                
                evokedFR_C_target = FGperiodFR_target - mean(bgFR_target);
                
                
                % C trials - non Target odor (CS-)
                Cmat_nonTarget = currFRmat(nonTargetTrialsC,:);
                
                bgFR_nonTarget = mean(Cmat_nonTarget(:,find(timeBins >= bgWin(1) & timeBins < bgWin(2))),2);
                
                FGperiodFR_nonTarget = mean(Cmat_nonTarget(:,find(timeBins >= fgTimeWin(1) & timeBins < fgTimeWin(2))),2);
                
                evokedFR_C_nonTarget = FGperiodFR_nonTarget - mean(bgFR_nonTarget);
                
                
                %STAT
                %Test if the response is different than baseline
                [h_bgFgPvalC_Target, ~] = ttest(bgFR_target, FGperiodFR_target, 'Alpha', pValueTH);
                
                % If the evoked delta is too small, does not considered as
                % a response
                if abs(mean(evokedFR_C_target)) < minFRdelta
                    h_bgFgPvalC_Target = 0;
                end
                
                [h_bgFgPvalC_nonTarget, ~] = ttest(bgFR_nonTarget, FGperiodFR_nonTarget, 'Alpha', pValueTH);
                
                % If the evoked delta is too small, does not considered as
                % a response
                if abs(mean(evokedFR_C_nonTarget)) < minFRdelta
                    h_bgFgPvalC_nonTarget = 0;
                end
                
                bgFR_target = [];FGperiodFR_target = [];bgFR_nonTarget = [];FGperiodFR_nonTarget = [];
                
                % Check if there was a response to the odor - C
                CS_plus_binaryVec_C(c) = h_bgFgPvalC_Target;
                CS_minus_binaryVec_C(c) = h_bgFgPvalC_nonTarget;
                
                
                %% Check if there is a significant difference in the evoked response for A and C
                
                %CS+
                [h_pA_C_difference_target,pA_C_difference_target] = ttest2(evokedFR_A_target, evokedFR_C_target);
                if abs(mean(evokedFR_A_target)) < minFRdelta | abs(mean(evokedFR_C_target)) < minFRdelta
                    h_pA_C_difference_target = 0;
                end
                %Avoid nans
                targetBinaryFlags_target = [h_bgFgPvalA_Target h_bgFgPvalC_Target h_pA_C_difference_target];
                targetBinaryFlags_target(isnan(targetBinaryFlags_target)) = 0;
                
                %Assign
                responseVec_target(c,:) = [(targetBinaryFlags_target(1) | targetBinaryFlags_target(2)) targetBinaryFlags_target(3)];
                
                
                %CS-
                [h_pA_C_difference_nonTarget,pA_C_difference_nonTarget] = ttest2(evokedFR_A_nonTarget, evokedFR_C_nonTarget);
                if abs(mean(evokedFR_A_nonTarget)) < minFRdelta | abs(mean(evokedFR_C_nonTarget)) < minFRdelta
                    h_pA_C_difference_nonTarget = 0;
                end
                
                %Avoid nans
                targetBinaryFlags_nonTarget = [h_bgFgPvalA_nonTarget h_bgFgPvalC_nonTarget h_pA_C_difference_nonTarget];
                targetBinaryFlags_nonTarget(isnan(targetBinaryFlags_nonTarget)) = 0;
                
                %Assign
                responseVec_nonTarget(c,:) = [(targetBinaryFlags_nonTarget(1) | targetBinaryFlags_nonTarget(2)) targetBinaryFlags_nonTarget(3)];
                
                %Assign the mean evoked FR
                FRmatFG_target(c,:) = [mean(evokedFR_A_target) mean(evokedFR_C_target)];
                FRmatFG_nonTarget(c,:) = [mean(evokedFR_A_nonTarget) mean(evokedFR_C_nonTarget)];
                
                %% If the FR difference is significant, save the PSTH
                
                %                 if (bgFgPvalA < pValueTH | bgFgPvalC < pValueTH) & (abs(mean(evokedFR_A_target)) > minFRdelta | abs(mean(evokedFR_C)) > minFRdelta) ...
                %                         %&(pA_C_difference < pValueTH)
                %                   if responseVec_target(c,2) | responseVec_nonTarget(c,2)
                
                %Counter for the significant units
                %                 signifCounter = signifCounter + 1;
                
                
                %
                %
                %                     neuronID{signifCounter} = ['M' num2str(miceInd+1) '; ' mouseData(recInd).date{1} '; ' mouseData(recInd).data.NeuralData.Spikes{unitInd}.tetrode(1:end-4)];
                %
                %                     relativeSessionNum(end+1) = mouseData(recInd).sessionNum./max([mouseData(:).sessionNum]);
                if strcmpi(plotFlag, 'plot') & (responseVec_nonTarget(c,2) | responseVec_target(c,2))
                    
                    %----------A------------
                    % All trials
                    rasterA = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.Atrials);
                    
                    % divided by outcome
                    hit_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.A);
                    CR_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.A);
                    miss_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.A);
                    FA_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.A);
                    
                    targetRaster_A = [hit_A miss_A];
                    nonTargetRaster_A = [CR_A FA_A];
                    
                    %----------C------------
                    rasterC = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.Ctrials);
                    
                    hit_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.C);
                    CR_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.C);
                    miss_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.C);
                    FA_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.C);
                    
                    targetRaster_C = [hit_C miss_C];
                    nonTargetRaster_C = [CR_C FA_C];
                    
                    %% ---------------PLOT-----------------
                    firstOdorXpatch = [-ISI-odorDuration -ISI -ISI -ISI-odorDuration];
                    secondOdorXpatch = [0 odorDuration odorDuration 0];
                    yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
                    patchFaceAlpha = 0.1;
                    
                    Acolor = [0,169,137]./255;%green
                    Ccolor = [171,62,143]./255;%purple;
                    patchColor = 'k';
                    rasterMarkerSize = 5;
                    
                    maxYlimTarget = max(size(targetRaster_A,2), size(targetRaster_C,2));
                    
                    
                    
                    figure;
                    %-------------- TARGET ODOR-------
                    subplot(4,2,1)
                    hold all;
                    patch(firstOdorXpatch, yPatch.*maxYlimTarget,patchColor, 'FaceAlpha', patchFaceAlpha)
                    patch(secondOdorXpatch, yPatch.*maxYlimTarget,patchColor, 'FaceAlpha', patchFaceAlpha)
                    for ind = 1:length(targetRaster_A)
                        scatter(targetRaster_A(ind).times, ind.*ones(1,length(targetRaster_A(ind).times)),rasterMarkerSize, ...
                            'MarkerFaceColor',Acolor, 'MarkerEdgeColor', 'none');
                    end
                    
                    hold off;
                    set(gca, 'fontSize', 12);
                    ylabel('Trial #');
                    ylim([0 maxYlimTarget])
                    xlim([-ISI-odorDuration-1 odorDuration+2])
                    title('CS+')
                    
                    subplot(4,2,3)
                    hold all;
                    patch(firstOdorXpatch, yPatch.*maxYlimTarget,patchColor, 'FaceAlpha', patchFaceAlpha)
                    patch(secondOdorXpatch, yPatch.*maxYlimTarget,patchColor, 'FaceAlpha', patchFaceAlpha)
                    for ind = 1:length(targetRaster_C)
                        scatter(targetRaster_C(ind).times, ind.*ones(1,length(targetRaster_C(ind).times)),rasterMarkerSize, ...
                            'MarkerFaceColor',Ccolor, 'MarkerEdgeColor', 'none');
                    end
                    
                    hold off;
                    set(gca, 'fontSize', 12);
                    ylabel('Trial #')
                    ylim([0 maxYlimTarget])
                    xlim([-ISI-odorDuration-1 odorDuration+2])
                    
                    subplot(4,2,[5,7])
                    hold all;
                    patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                    patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                    
                    mypsth(targetRaster_A, psthKernel, Acolor);hold on;
                    mypsth(targetRaster_C, psthKernel, Ccolor);
                    hold off;
                    set(gca, 'fontSize', 12);box off;
                    ylabel('Firing rate (Hz)');xlabel('Time (sec)')
                    set(gcf, 'Renderer', 'painters')
                    xlim([-ISI-odorDuration-1 odorDuration+2])
                    
                    %------------ Non-TARGET ODOR
                    maxYlimNonTarget = max(size(nonTargetRaster_A,2), size(nonTargetRaster_C,2));
                    subplot(4,2,2)
                    hold all;
                    patch(firstOdorXpatch, yPatch.*maxYlimNonTarget,patchColor, 'FaceAlpha', patchFaceAlpha)
                    patch(secondOdorXpatch, yPatch.*maxYlimNonTarget,patchColor, 'FaceAlpha', patchFaceAlpha)
                    for ind = 1:length(nonTargetRaster_A)
                        scatter(nonTargetRaster_A(ind).times, ind.*ones(1,length(nonTargetRaster_A(ind).times)),rasterMarkerSize, ...
                            'MarkerFaceColor',Acolor, 'MarkerEdgeColor', 'none');
                    end
                    
                    hold off;
                    set(gca, 'fontSize', 12);
                    ylabel('Trial #');
                    ylim([0 maxYlimNonTarget])
                    xlim([-ISI-odorDuration-1 odorDuration+2])
                    title('CS-')
                    
                    subplot(4,2,4)
                    hold all;
                    patch(firstOdorXpatch, yPatch.*maxYlimNonTarget,patchColor, 'FaceAlpha', patchFaceAlpha)
                    patch(secondOdorXpatch, yPatch.*maxYlimNonTarget,patchColor, 'FaceAlpha', patchFaceAlpha)
                    for ind = 1:length(nonTargetRaster_C)
                        scatter(nonTargetRaster_C(ind).times, ind.*ones(1,length(nonTargetRaster_C(ind).times)),rasterMarkerSize, ...
                            'MarkerFaceColor',Ccolor, 'MarkerEdgeColor', 'none');
                    end
                    
                    hold off;
                    set(gca, 'fontSize', 12);
                    ylabel('Trial #')
                    ylim([0 maxYlimNonTarget])
                    xlim([-ISI-odorDuration-1 odorDuration+2])
                    
                    subplot(4,2,[6,8])
                    hold all;
                    patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                    patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                    
                    mypsth(nonTargetRaster_A, psthKernel, Acolor);hold on;
                    mypsth(nonTargetRaster_C, psthKernel, Ccolor);
                    hold off;
                    set(gca, 'fontSize', 12);box off;
                    ylabel('Firing rate (Hz)');xlabel('Time (sec)')
                    set(gcf, 'Renderer', 'painters')
                    xlim([-ISI-odorDuration-1 odorDuration+2])
                    
                    
                    round( [FRmatFG_target(c,:) pA_C_difference_target],3)
                    
                    round([FRmatFG_nonTarget(c,:) pA_C_difference_nonTarget], 3)
                    
                    
                    close;
                    
                    
                end
                
                
                
            end
        end
    end
    
    outputStruct.relativeSessionNum(miceInd).relSessNum = relativeSessionNum;
end
respondingWithDifferenceInds_Target = find(responseVec_target(:,2)==1 & responseVec_target(:,1)==1);
respondingWithNoDifferenceInds_Target = find(responseVec_target(:,2)==0 & responseVec_target(:,1)==1);
figure;
subplot(1,2,1)
pie([length(respondingWithDifferenceInds_Target), length(respondingWithNoDifferenceInds_Target)])
colormap bone
title('CS+')


respondingWithDifferenceInds_nonTarget = find(responseVec_nonTarget(:,2)==1 & responseVec_nonTarget(:,1)==1);
respondingWithNoDifferenceInds_nonTarget = find(responseVec_nonTarget(:,2)==0 & responseVec_nonTarget(:,1)==1);

subplot(1,2,2)
pie([length(respondingWithDifferenceInds_nonTarget), length(respondingWithNoDifferenceInds_nonTarget)])
colormap bone
title('CS-')

subplot(1,3,3)
venn([length(respondingWithDifferenceInds_Target), length(respondingWithDifferenceInds_nonTarget)], ...
    length(intersect(respondingWithDifferenceInds_Target,respondingWithDifferenceInds_nonTarget)), ...
    'FaceColor',{[240,227,147]./255,[134,146,99]./2555},'FaceAlpha',{0.7,0.4},'EdgeColor','black')
set(gca, 'XTick', '')
set(gca, 'YTick', '')

% Ramping vs PE
figure;
venn([length([respondingWithDifferenceInds_Target]), length(identifiedRamping)], ...
    length(intersect([respondingWithDifferenceInds_Target]', identifiedRamping)), ...
    'FaceColor',{[231,42,118]./255,[235,92,63]./255},'FaceAlpha',{0.7,0.7})
set(gca, 'XTick', '')
set(gca, 'YTick', '')






