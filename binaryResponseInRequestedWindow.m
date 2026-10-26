function [outputStruct] = binaryResponseInRequestedWindow(bgWin, fgTimeWin, pValueTH, highOrLow, minFRdelta, trialsToUsed)
if nargin < 5
    minFRdelta = 0;
end
normFlag = 1;
plotFlag = 0;%plot the examples
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

responseMat = [];
FRmatFG = [];
c = 0;
psthKernel = 0.07;
PSTHstruct = [];
signifCounter = 0;
hitColor = [171,62,143]./255;%purple
CRColor = [0,169,137]./255;%green
missColor = [0,146,214]./255;%blue
FAColor = [255,206,11]./255;%yellow
identifiedRamping = [8 9 13 14 15 18 21 22 23 26 28 30 32 33 34  50 51 52 53 54 63 66 ...
    71 76 83 95 112 125 129 132 135 138 143 147  152 155 157 163 173 176 ...
    179 186 189 191 194  221 223 224 228 236 239 240 249 250 253 254];
matchVec = [];


%%
allHitAtrials = [];allHitCtrials = [];allMissAtrials = [];allMissCtrials = [];
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
    relativeSessionNum = [];
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            ISI = mouseData(recInd).data.ISIbetweenOdors./1000;
            odorDuration = mouseData(recInd).data.odor_duration./1000;
            Atrials = mouseData(recInd).data.Atrials;
            Ctrials = mouseData(recInd).data.Ctrials;
            
            targetTrialsA = [mouseData(recInd).data.trialOutcome.hit.A ...
                mouseData(recInd).data.trialOutcome.miss.A];
            
            targetTrialsC = [mouseData(recInd).data.trialOutcome.hit.C ...
                mouseData(recInd).data.trialOutcome.miss.C];
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                
                %% Compare the firing rate in the requested window
                c = c + 1;
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                %                 FRmatFG(c,:) = nan(1,2);
                
                
                % A trials
                if strcmpi(trialsToUsed, 'allTrials')
                    Amat = currFRmat(Atrials,:);
                elseif strcmpi(trialsToUsed, 'Target')
                    Amat = currFRmat(targetTrialsA,:);
                end
                
                %Baseline
                bgFR = mean(Amat(:,find(timeBins >= bgWin(1) & timeBins < bgWin(2))),2);
                
                FGperiodFR = mean(Amat(:,find(timeBins >= fgTimeWin(1) & timeBins < fgTimeWin(2))),2);
                
                evokedFR_A = FGperiodFR - mean(bgFR);
                
                z_evoked_A = evokedFR_A./std(bgFR);
                
                
                
                %STAT
                if strcmpi(highOrLow, 'high')
                    [bgFgPvalA] = signrank(bgFR, FGperiodFR, 'tail', 'left');
                elseif strcmpi(highOrLow, 'low')
                    [bgFgPvalA] = signrank(bgFR, FGperiodFR, 'tail', 'right');
                end
                
                FGperiodFR = [];bgFR = [];
                
                % C trials
                if strcmpi(trialsToUsed, 'allTrials')
                    Cmat = currFRmat(Ctrials,:);
                elseif strcmpi(trialsToUsed, 'Target')
                    Cmat = currFRmat(targetTrialsC,:);
                end
                
                
                %Baseline
                bgFR = mean(Cmat(:,find(timeBins >= bgWin(1) & timeBins < bgWin(2))),2);
                
                
                FGperiodFR = mean(Cmat(:,find(timeBins >= fgTimeWin(1) & timeBins < fgTimeWin(2))),2);
                
                evokedFR_C = FGperiodFR - mean(bgFR);
                
                z_evoked_C = evokedFR_C./std(bgFR);
                
                
                %STAT
                if strcmpi(highOrLow, 'high')
                    [bgFgPvalC] = signrank(bgFR, FGperiodFR, 'tail', 'left');
                elseif strcmpi(highOrLow, 'low')
                    [bgFgPvalC] = signrank(bgFR, FGperiodFR, 'tail', 'right');
                end
                
                bgFR = [];FGperiodFR = [];
                
                
                % Assign the response into the matrix
                responseMat(c,:) = zeros(1,2);
                if bgFgPvalA < pValueTH
                    responseMat(c,1) = 1;
                    
                end
                
                if bgFgPvalC < pValueTH
                    responseMat(c,2) = 1;
                end
                
                %% If the FR difference is significant, save the PSTH
                
                %                 if (bgFgPvalA < pValueTH | bgFgPvalC < pValueTH) & (minFRdelta < mean(evokedFR_A) | minFRdelta < mean(evokedFR_C))
                %& sum(c == identifiedRamping) %& ...
                if sum(c == identifiedRamping)
                    
                    %Counter for the significant units
                    signifCounter = signifCounter + 1;
                    
                    %Assign the mean evoked FR
                    FRmatFG(signifCounter,:) = [mean(evokedFR_A) mean(evokedFR_C)];
                    
                    FRmatFG_Z(signifCounter,:) = [mean(z_evoked_A) mean(z_evoked_C)];
                    
                    %Comapre between the evoked FR in the A and C condition
                    if length(evokedFR_A)==length(evokedFR_C)
                        [~,p_A_C] = ttest(evokedFR_A, evokedFR_C);
                        stat_A_C(signifCounter) = p_A_C;
                    end
                    
                    
                    % Save the firing rate matrices
                    signifFiringRates(signifCounter).frMat.A = Amat;
                    signifFiringRates(signifCounter).frMat.C = Cmat;
                    signifFiringRates(signifCounter).time = timeBins;
                    
                    matchVec(end+1) = sum(c == identifiedRamping);
                    
                    neuronID{signifCounter} = ['M' num2str(miceInd+1) '; ' mouseData(recInd).date{1} '; ' mouseData(recInd).data.NeuralData.Spikes{unitInd}.tetrode(1:end-4)];
                    
                    relativeSessionNum(end+1) = mouseData(recInd).sessionNum./max([mouseData(:).sessionNum]);
                    
                    
                    %----------A------------
                    % All trials
                    rasterA = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.Atrials);
                    % divided by outcome
                    hit_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.A);
                    CR_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.A);
                    miss_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.A);
                    FA_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.A);
                    
                    if strcmpi(trialsToUsed, 'allTrials')
                        outcomeRaster_A = [hit_A CR_A miss_A FA_A];
                        % Create a corresponding color vector
                        colorVec_A =[repmat({hitColor}, 1,length(hit_A)) ...
                            repmat({CRColor}, 1,length(CR_A)) ...
                            repmat({missColor}, 1,length(miss_A)) ...
                            repmat({FAColor}, 1,length(FA_A))];
                        
                    elseif strcmpi(trialsToUsed, 'Target')
                        outcomeRaster_A = [hit_A miss_A];
                        % Create a corresponding color vector
                        colorVec_A =[repmat({hitColor}, 1,length(hit_A)) ...
                            repmat({missColor}, 1,length(miss_A))];
                    end
                    
                    % All trials PSTH
                    [R,t] = mypsth(rasterA, psthKernel, 'n');
                    % Save the  PSTH
                    if normFlag == 1
                        baselinePSTH = R(find(t < -ISI-odorDuration));
                        R = (R - mean(baselinePSTH));%./std(baselinePSTH);
                    end
                    PSTHstruct(signifCounter).allTrials.A = [t;R];
                    R = [];t = [];baselinePSTH = [];
                    
                    %Hit trials PSTH
                    allHitAtrials = [allHitAtrials hit_A CR_A];
                    %Miss trials PSTH
                    allMissAtrials = [allMissAtrials miss_A FA_A];
                    
                    
                    
                    
                    
                    %----------C------------
                    rasterC = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.Ctrials);
                    hit_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.C);
                    CR_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.C);
                    miss_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.C);
                    FA_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.C);
                    
                    if strcmpi(trialsToUsed, 'allTrials')
                        outcomeRaster_C = [hit_C CR_C miss_C FA_C];
                        
                        colorVec_C =[repmat({hitColor}, 1,length(hit_C)) ...
                            repmat({CRColor}, 1,length(CR_C)) ...
                            repmat({missColor}, 1,length(miss_C)) ...
                            repmat({FAColor}, 1,length(FA_C))];
                        
                    elseif strcmpi(trialsToUsed, 'Target')
                        outcomeRaster_C = [hit_C miss_C];
                        
                        colorVec_C =[repmat({hitColor}, 1,length(hit_C)) ...
                            repmat({missColor}, 1,length(miss_C))];
                    end
                    
                    
                    
                    [R,t] = mypsth(rasterC, psthKernel, 'n');
                    
                    % Save the  PSTH
                    if normFlag == 1
                        baselinePSTH = R(find(t < -ISI-odorDuration));
                        R = (R - mean(baselinePSTH));%./std(baselinePSTH);
                    end
                    % All trials PSTH
                    PSTHstruct(signifCounter).allTrials.C = [t;R];
                    
                    %Hit trials PSTH
                    allHitCtrials = [allHitCtrials hit_C CR_C];
                    %Miss trials PSTH
                    allMissCtrials = [allMissCtrials miss_C FA_C];
                    
                    
                    %% ---------------PLOT-----------------
                    firstOdorXpatch = [-ISI-odorDuration -ISI -ISI -ISI-odorDuration];
                    secondOdorXpatch = [0 odorDuration odorDuration 0];
                    yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
                    patchFaceAlpha = 0.1;
                    
                    Acolor = [0,169,137]./255;%green
                    Ccolor = [171,62,143]./255;%purple;
                    patchColor = 'k';
                    rasterMarkerSize = 5;
                    if plotFlag
                        
                        
                        
                        figure;
                        subplot(4,1,1)
                        hold all;
                        patch(firstOdorXpatch, yPatch.*length(outcomeRaster_A),patchColor, 'FaceAlpha', patchFaceAlpha)
                        patch(secondOdorXpatch, yPatch.*length(outcomeRaster_A),patchColor, 'FaceAlpha', patchFaceAlpha)
                        for ind = 1:length(outcomeRaster_A)
                            scatter(outcomeRaster_A(ind).times, ind.*ones(1,length(outcomeRaster_A(ind).times)),rasterMarkerSize, ...
                                'MarkerFaceColor',Acolor, 'MarkerEdgeColor', 'none');
                        end
                        %Color the tile
                        %                         title(['A: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', hitColor) '} Hit', ...
                        %                             ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', CRColor) '} CR', ...
                        %                             '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', missColor) '} Miss', ...
                        %                             ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', FAColor) '} FA'])
                        hold off;
                        set(gca, 'fontSize', 12);
                        ylabel('Trial #');
                        ylim([0 max(length(rasterA), length(rasterC))+1])
                        xlim([-3 3])
                        
                        subplot(4,1,2)
                        hold all;
                        patch(firstOdorXpatch, yPatch.*length(outcomeRaster_C),patchColor, 'FaceAlpha', patchFaceAlpha)
                        patch(secondOdorXpatch, yPatch.*length(outcomeRaster_C),patchColor, 'FaceAlpha', patchFaceAlpha)
                        for ind = 1:length(outcomeRaster_C)
                            scatter(outcomeRaster_C(ind).times, ind.*ones(1,length(outcomeRaster_C(ind).times)),rasterMarkerSize, ...
                                'MarkerFaceColor',Ccolor, 'MarkerEdgeColor', 'none');
                        end
                        %Color the tile
                        %                         title(['C: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', hitColor) '} Hit', ...
                        %                             ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', CRColor) '} CR', ...
                        %                             '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', missColor) '} Miss', ...
                        %                             ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', FAColor) '} FA'])
                        hold off;
                        set(gca, 'fontSize', 12);
                        ylabel('Trial #')
                        ylim([0 max(length(rasterA), length(rasterC))+1])
                        xlim([-3 3])
                        
                        subplot(4,1,3:4)
                        hold all;
                        patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                        patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                        
                        mypsth(outcomeRaster_A, psthKernel, Acolor);hold on;
                        mypsth(outcomeRaster_C, psthKernel, Ccolor);
                        hold off;
                        set(gca, 'fontSize', 12);box off;
                        ylabel('Firing rate (Hz)');xlabel('Time (sec)')
                        set(gcf, 'Renderer', 'painters')
                        xlim([-3 3])
                        
                        [FRmatFG(signifCounter,1) FRmatFG(signifCounter,2);bgFgPvalA bgFgPvalC]
                        %                         p_A_C
                        [signifCounter c]
                        %                         if matchVec(end)==0
                        %                             disp('stop')
                        %                         end
                        ['M' num2str(miceInd+1) '; ' mouseData(recInd).date{1} '; ' mouseData(recInd).data.NeuralData.Spikes{unitInd}.tetrode(1:end-4)]
                        
                        close;
                        
                    end
                end
                
                
                
            end
        end
    end
    
    outputStruct.relativeSessionNum(miceInd).relSessNum = relativeSessionNum;
end
outcomeRasterStruct.hit.A = allHitAtrials;
outcomeRasterStruct.miss.A = allMissAtrials;
outcomeRasterStruct.hit.C = allHitCtrials;
outcomeRasterStruct.miss.C = allMissCtrials;

outputStruct.responseMat = [];
outputStruct.FRmatFG = FRmatFG;
outputStruct.FRmatFG_Z = FRmatFG_Z;
outputStruct.PSTHstruct = PSTHstruct;
outputStruct.outcomeRasterStruct = outcomeRasterStruct;
outputStruct.signifFiringRates = signifFiringRates;
outputStruct.neuronID = neuronID;
outputStruct.stat_A_C = stat_A_C;
outputStruct.outcomeRasters = outcomeRasterStruct;

%% Sort the predicting odor responses by classes.
noResponse = find(sum(responseMat,2) == 0);
A_Response = find(responseMat(:,1) > 0 & responseMat(:,2) == 0);
C_Response = find(responseMat(:,1) == 0 & responseMat(:,2) > 0);
both_Response = find(responseMat(:,1) > 0 & responseMat(:,2) > 0);

sortedIndsPredOdor = [noResponse;A_Response;C_Response;both_Response];



%% Plot the binary mat
figure;
imagesc(responseMat(sortedIndsPredOdor,:))
colormap(linspecer)
title(['Response flag in the window of ' num2str(fgTimeWin(1)) ' to ' num2str(fgTimeWin(2))])
hcb = colorbar;
hcb.Title.String = "Binary";
set(gca, 'XTickLabel', {'A (75%)', 'C(25%)'});
set(gca, 'FontSize', 14');box off;
ylabel('Neurons')


%% Plot the PSTHs of all trials
requestedTimeWin = [-4 0.2];
deltaT = requestedTimeWin(2)-requestedTimeWin(1);

for psthInd = 1:size(PSTHstruct,2)
    currTimeVec =[];firstInd = [];indToPlot = [];
    % --------A---------
    % The current time vec
    currTimeVec = PSTHstruct(psthInd).allTrials.A(1,:);
    % Compute the bin size of the PSTH
    psthBinSize = floor((currTimeVec(end)-currTimeVec(1))*1000./(length(currTimeVec)));
    % Find the relevant indices
    firstInd = find(currTimeVec >= requestedTimeWin(1),1);
    indToPlot = [firstInd : firstInd + deltaT*1000./psthBinSize-1];
    
    currPSTH_A = PSTHstruct(psthInd).allTrials.A(2,indToPlot);
    currPSTHMax_A = max(currPSTH_A(find(currTimeVec >= fgTimeWin(1) & currTimeVec < fgTimeWin(2))));
    
    PSTHmatA(psthInd,:) = currPSTH_A./currPSTHMax_A;
    currTimeVec =[];firstInd = [];indToPlot = [];
    
    % --------C---------
    % The current time vec
    currTimeVec = PSTHstruct(psthInd).allTrials.C(1,:);
    % Compute the bin size of the PSTH
    psthBinSize = floor((currTimeVec(end)-currTimeVec(1))*1000./(length(currTimeVec)));
    % Find the relevant indices
    firstInd = find(currTimeVec >= requestedTimeWin(1),1);
    indToPlot = [firstInd : firstInd + deltaT*1000./psthBinSize-1];
    
    
    currPSTH_C = PSTHstruct(psthInd).allTrials.C(2,indToPlot);
    currPSTHMax_C = max(currPSTH_C(find(currTimeVec >= fgTimeWin(1) & currTimeVec < fgTimeWin(2))));
    PSTHmatC(psthInd,:) = currPSTH_C./currPSTHMax_C;
    
    
    
end

figure;
subplot(1,2,1)
imagesc(currTimeVec(indToPlot),1:size(PSTHmatA,1),PSTHmatA)

subplot(1,2,2)
imagesc(currTimeVec(indToPlot),1:size(PSTHmatC,1),PSTHmatC)


figure;
hold all;
patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
errorbar_patch(currTimeVec(indToPlot), nanmean(PSTHmatA), nanstd(PSTHmatA)./sqrt(size(PSTHmatA,1)), Acolor);
errorbar_patch(currTimeVec(indToPlot), nanmean(PSTHmatC), nanstd(PSTHmatC)./sqrt(size(PSTHmatC,1)), Ccolor);
xlabel('Time  relative to target (sec)');
set(gca, 'FontSize', 14');box off;
ylabel('Firing rate (Hz)')
title(['N = ' num2str(size(PSTHmatA,1))])
set(gcf, 'Renderer', 'painters')

%% Plot the PSTHs divided to trial outcome

figure;
hold all;
patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
subplot(1,2,1)
%Hit
[R, t, E] = mypsth(allHitAtrials, psthKernel,'n');
baselinePSTH = R(find(t < -ISI-odorDuration));
R = (R - mean(baselinePSTH));%./std(baselinePSTH);
errorbar_patch(t, R, E, hitColor)
hold on;
%Miss
[R, t, E] = mypsth(allMissAtrials, psthKernel,'n');
baselinePSTH = R(find(t < -ISI-odorDuration));
R = (R - mean(baselinePSTH));%./std(baselinePSTH);
errorbar_patch(t, R, E, missColor)
xlabel('Time  relative to target (sec)');
set(gca, 'FontSize', 14');box off;
ylabel('Firing rate (Hz)')
title(['A: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', hitColor) '} Correct (N = ' num2str(size(allHitAtrials,2)) ' )', ...
    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', missColor) '} Error (N = ' num2str(size(allMissAtrials,2)) ' )'])
xlim([-3 0])

subplot(1,2,2)
%Hit
[R, t, E] = mypsth(allHitCtrials, psthKernel,'n');
baselinePSTH = R(find(t < -ISI-odorDuration));
R = (R - mean(baselinePSTH));%./std(baselinePSTH);
errorbar_patch(t, R, E, hitColor)
hold on;
%Miss
[R, t, E] = mypsth(allMissCtrials, psthKernel,'n');
baselinePSTH = R(find(t < -ISI-odorDuration));
R = (R - mean(baselinePSTH));%./std(baselinePSTH);
errorbar_patch(t, R, E, missColor)
xlabel('Time  relative to target (sec)');
set(gca, 'FontSize', 14');box off;
ylabel('Firing rate (Hz)')
title(['C: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', hitColor) '} Correct (N = ' num2str(size(allHitCtrials,2)) ' )', ...
    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', missColor) '} Error (N = ' num2str(size(allMissCtrials,2)) ' )'])
hold off;
set(gcf, 'Renderer', 'painters')
xlim([-3 0])

figure;
scatter(outputStruct.FRmatFG_Z(:,2), outputStruct.FRmatFG_Z(:,1), 25, [4,2,115]./255, 'filled', 'MarkerEdgeColor',[4,2,115]./255 );
axisLim = [-1 5];
hold on;plot(axisLim, axisLim, 'k--')
xlim(axisLim);
set(gca, 'FontSize', 14');box off;
xlabel('Low (25%) (Z-score)');
ylabel('High (75%) (Z-score)');


