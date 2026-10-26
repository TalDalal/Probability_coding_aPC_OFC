clear;clc
%Load the data
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

identifiedRamping = [8 9 13 14 15 18 21 22  26 28 30 32 33 34  50 51 52 53 54 63 66 ...
    71 76 83 95  132 143  155 157 163 173 176 ...
    179 189 191 194  221 223 224 228 239 240 249 250 253 254];
CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
%%
c = 0;
psthCounter = 0;

allCorrectTrials_A = [];allIncorrectTrials_A = [];
allCorrectTrials_C = [];allIncorrectTrials_C = [];
correctActivityMat_A = [];incorrectActivityMat_A = [];
correctActivityMat_C = [];incorrectActivityMat_C = [];
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
                    hit_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.A);
                    CR_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.A);
                    miss_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.A);
                    FA_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.A);
                    
                    %Hit trials PSTH
                    allCorrectTrials_A = [allCorrectTrials_A hit_A CR_A];
                    %Miss trials PSTH
                    allIncorrectTrials_A = [allIncorrectTrials_A miss_A FA_A];
                    
%                     
                    correctActivityMat_A = [correctActivityMat_A ;mouseData(recInd).data.firingRates(unitInd). ... 
                        firingRateByBIn([mouseData(recInd).data.trialOutcome.hit.A mouseData(recInd).data.trialOutcome.CR.A],:)];
                        
                    incorrectActivityMat_A = [incorrectActivityMat_A ;mouseData(recInd).data.firingRates(unitInd). ...
                        firingRateByBIn([mouseData(recInd).data.trialOutcome.miss.A mouseData(recInd).data.trialOutcome.FA.A],:)];
                    

                    
                    %----------C------------
                    hit_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.C);
                    CR_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.C);
                    miss_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.C);
                    FA_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.C);
                    
                    %Hit trials PSTH
                    allCorrectTrials_C = [allCorrectTrials_C hit_C CR_C];
                    %Miss trials PSTH
                    allIncorrectTrials_C = [allIncorrectTrials_C miss_C FA_C];
                    
                    
                    correctActivityMat_C = [correctActivityMat_C ;mouseData(recInd).data.firingRates(unitInd). ...
                        firingRateByBIn([mouseData(recInd).data.trialOutcome.hit.C mouseData(recInd).data.trialOutcome.CR.C],:)];
                        
                    incorrectActivityMat_C = [incorrectActivityMat_C ;mouseData(recInd).data.firingRates(unitInd). ...
                        firingRateByBIn([mouseData(recInd).data.trialOutcome.miss.C mouseData(recInd).data.trialOutcome.FA.C],:)];
                    

                end
            end
        end
        
    end
end
%% Plot the z-scored activity fro the activity matrix

%------------A------------
baslineCorrect_A = mean(correctActivityMat_A(:,find(mouseData(recInd).data.firingRateAnalysisBins < -ISI-odorDuration)),2);
baslineIncorrect_A = mean(incorrectActivityMat_A(:,find(mouseData(recInd).data.firingRateAnalysisBins < -ISI-odorDuration)),2);

zActivity_correct_A = (correctActivityMat_A - baslineCorrect_A)./std(baslineCorrect_A);
zActivity_incorrect_A = (incorrectActivityMat_A - baslineIncorrect_A)./std(baslineIncorrect_A);


%------------C------------
baslineCorrect_C = mean(correctActivityMat_C(:,find(mouseData(recInd).data.firingRateAnalysisBins < -ISI-odorDuration)),2);
baslineIncorrect_C = mean(incorrectActivityMat_C(:,find(mouseData(recInd).data.firingRateAnalysisBins < -ISI-odorDuration)),2);

zActivity_correct_C = (correctActivityMat_C - baslineCorrect_C)./std(baslineCorrect_C);
zActivity_incorrect_C = (incorrectActivityMat_C - baslineIncorrect_C)./std(baslineIncorrect_C);

figure;
subplot(1,2,1)
errorbar_patch(mouseData(recInd).data.firingRateAnalysisBins(1:end-1), mean(zActivity_correct_A), std(zActivity_correct_A)./sqrt(size(zActivity_correct_A,1)), AColor)
hold on;
errorbar_patch(mouseData(recInd).data.firingRateAnalysisBins(1:end-1), mean(zActivity_incorrect_A), std(zActivity_incorrect_A)./sqrt(size(zActivity_incorrect_A,1)), AColor, '--')
xlim([-3 0])

subplot(1,2,2)
errorbar_patch(mouseData(recInd).data.firingRateAnalysisBins(1:end-1), mean(zActivity_correct_C), std(zActivity_correct_C)./sqrt(size(zActivity_correct_C,1)), CColor)
hold on;
errorbar_patch(mouseData(recInd).data.firingRateAnalysisBins(1:end-1), mean(zActivity_incorrect_C), std(zActivity_incorrect_C)./sqrt(size(zActivity_incorrect_C,1)), CColor, '--')
xlim([-3 0])


%--- Decode the trial outcome
% labels = [ones(size(zActivity_correct_C,1), 1);zeros(size(zActivity_incorrect_C,1), 1)];
% for bindInd = 1:40
%     data = [mean(zActivity_correct_C(:,bindInd:bindInd+2),2) ; mean(zActivity_incorrect_C(:,bindInd:bindInd+2),2)];
%     [successRate, ~] = leaveOneOut_cross_validation_high_or_low_odors(data, labels, 1000);
%     allSRs(bindInd) = successRate;
% end
% figure;
% plot(smooth(allSRs))
%% ---------------PLOT-----------------
firstOdorXpatch = [-ISI-odorDuration -ISI -ISI -ISI-odorDuration];
secondOdorXpatch = [0 odorDuration odorDuration 0];
yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
patchFaceAlpha = 0.1;
patchColor = 'k';
incorrectColor = [255,205,116]./255;
correctColor =[155,41,72]./255;
psthKernel = 0.07;

fig = figure;

%-----A---------
subplot(1,2,1)
hold all;
patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
%Correct
[R, t, E] = mypsth(allCorrectTrials_A, psthKernel,'n');
baselinePSTH = R(find(t < -ISI-odorDuration));
R = (R - mean(baselinePSTH))./std(baselinePSTH);
errorbar_patch(t, R, E, correctColor)
hold on;
%Incorrect
[R, t, E] = mypsth(allIncorrectTrials_A, psthKernel,'n');
baselinePSTH = R(find(t < -ISI-odorDuration));
R = (R - mean(baselinePSTH))./std(baselinePSTH);
errorbar_patch(t, R, E, incorrectColor)
% xlabel('Time  relative to target (sec)');
set(gca, 'FontSize', 14');box off;
% ylabel('Firing rate (Hz)')
title(['A: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', correctColor) '} Correct (N = ' num2str(size(allCorrectTrials_A,2)) ' )', ...
    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', incorrectColor) '} Error (N = ' num2str(size(allIncorrectTrials_A,2)) ' )'])
xlim([-3 0])

%-----C---------
subplot(1,2,2)
hold all;
patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
%Correct
[R, t, E] = mypsth(allCorrectTrials_C, psthKernel,'n');
baselinePSTH = R(find(t < -ISI-odorDuration));
R = (R - mean(baselinePSTH))./std(baselinePSTH);
errorbar_patch(t, R, E, correctColor)
hold on;
%Incorrect
[R, t, E] = mypsth(allIncorrectTrials_C, psthKernel,'n');
baselinePSTH = R(find(t < -ISI-odorDuration));
R = (R - mean(baselinePSTH))./std(baselinePSTH);
errorbar_patch(t, R, E, incorrectColor)
% xlabel('Time  relative to CS (S)');
set(gca, 'FontSize', 14');box off;
% ylabel('Firing rate (Hz)')
title(['C: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', correctColor) '} Correct (N = ' num2str(size(allCorrectTrials_C,2)) ' )', ...
    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', incorrectColor) '} Error (N = ' num2str(size(allIncorrectTrials_C,2)) ' )'])
xlim([-3 0])


han=axes(fig,'visible','off');
han.Title.Visible='on';
han.XLabel.Visible='on';
set(gca, 'FontSize', 15);
han.YLabel.Visible='on';
ylabel(han,'Firing rate (Hz)');
xlabel(han,'Time relative to CS (S)');
