
normFlag = 1;
plotFlag = 1;%plot the examples
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

responseMat = [];
FRmatFG = [];
c = 0;psthKernel = 0.07;PSTHstruct = [];
signifCounter = 0;
hitColor = [235, 238, 91]./255;
CRColor = [172, 129, 64]./255;
missColor = [99, 66, 49]./255;
FAColor = [63, 42, 37]./255;

CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];


%%
allHitAtrials = [];allHitCtrials = [];allMissAtrials = [];allMissCtrials = [];
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
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
                
                
                %Counter for the significant units
                signifCounter = signifCounter + 1;
                
                %----------A------------
                % All trials
                rasterA = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.Atrials);
                % divided by outcome
                hit_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.A);
                CR_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.A);
                miss_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.A);
                FA_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.A);
                
                
                outcomeRaster_A_AllTrials = [hit_A  miss_A CR_A FA_A];
                % Create a corresponding color vector
                colorVec_A_AllTrials =[repmat({hitColor}, 1,length(hit_A)) ...
                    repmat({missColor}, 1,length(miss_A)) ...
                    repmat({CRColor}, 1,length(CR_A)) ...
                    repmat({FAColor}, 1,length(FA_A))];
                
                outcomeRaster_A_Target = [hit_A miss_A];
                % Create a corresponding color vector
                colorVec_A_Target =[repmat({hitColor}, 1,length(hit_A)) ...
                    repmat({missColor}, 1,length(miss_A))];
                
                outcomeRaster_A_nonTarget = [CR_A FA_A];
                % Create a corresponding color vector
                colorVec_A_nonTarget =[repmat({CRColor}, 1,length(CR_A)) ...
                    repmat({FAColor}, 1,length(FA_A))];
                
                
                
                
                
                %----------C------------
                rasterC = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.Ctrials);
                hit_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.C);
                CR_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.C);
                miss_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.C);
                FA_C = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.C);
                
                
                outcomeRaster_C_AllTrials = [hit_C miss_C CR_C FA_C];
                
                colorVec_C_AllTrials =[repmat({hitColor}, 1,length(hit_C)) ...
                    repmat({missColor}, 1,length(miss_C)) ...
                    repmat({CRColor}, 1,length(CR_C)) ...
                    repmat({FAColor}, 1,length(FA_C))];
                
                
                outcomeRaster_C_Target = [hit_C miss_C];
                
                colorVec_C_Target =[repmat({hitColor}, 1,length(hit_C)) ...
                    repmat({missColor}, 1,length(miss_C))];
                
                
                outcomeRaster_C_nonTarget = [CR_C FA_C];
                
                colorVec_C_nonTarget =[repmat({CRColor}, 1,length(CR_C)) ...
                    repmat({FAColor}, 1,length(FA_C))];
                
                
                
                
                %% ---------------PLOT-----------------
                firstOdorXpatch = [-ISI-odorDuration -ISI -ISI -ISI-odorDuration];
                secondOdorXpatch = [0 odorDuration odorDuration 0];
                yPatch = [0 0 1 1];% this vector will be multiply by the length of the rasterplot in each condition.
                patchFaceAlpha = 0.1;
                
%                 Acolor = 'r';
%                 Ccolor = 'm';
                patchColor = 'k';
                rasterMarkerSize = 3;
                
                rampPlotXLIM = [-3 3];
                targetPlotXLIM = [-3 3];
                    
%                 if signifCounter < 70
%                     continue
%                 end
                figure;
                %% %%%% Raster plot of all trials
                subplot(3,3,1)
                hold all;
                patch(firstOdorXpatch, yPatch.*length(outcomeRaster_A_AllTrials),patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                patch(secondOdorXpatch, yPatch.*length(outcomeRaster_A_AllTrials),patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                for ind = 1:length(outcomeRaster_A_AllTrials)
                    scatter(outcomeRaster_A_AllTrials(ind).times, ind.*ones(1,length(outcomeRaster_A_AllTrials(ind).times)),rasterMarkerSize, ...
                        'MarkerFaceColor',AColor, 'MarkerEdgeColor', 'none');
                end
                %Color the tile
                title(['A: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', hitColor) '} Hit', ...
                    ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', CRColor) '} CR', ...
                    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', missColor) '} Miss', ...
                    ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', FAColor) '} FA'])
                hold off;
                set(gca, 'fontSize', 12);
                ylabel('Trial #');
                ylim([0 max(length(rasterA), length(rasterC))+1])
                xlim(rampPlotXLIM)
                
                subplot(3,3,4)
                hold all;
                patch(firstOdorXpatch, yPatch.*length(outcomeRaster_C_AllTrials),patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch.*length(outcomeRaster_C_AllTrials),patchColor, 'FaceAlpha', patchFaceAlpha)
                for ind = 1:length(outcomeRaster_C_AllTrials)
                    scatter(outcomeRaster_C_AllTrials(ind).times, ind.*ones(1,length(outcomeRaster_C_AllTrials(ind).times)),rasterMarkerSize, ...
                        'MarkerFaceColor',CColor, 'MarkerEdgeColor', 'none');
                end
                %Color the tile
                title(['C: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', hitColor) '} Hit', ...
                    ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', CRColor) '} CR', ...
                    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', missColor) '} Miss', ...
                    ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', FAColor) '} FA'])
                hold off;
                set(gca, 'fontSize', 12);
                ylabel('Trial #')
                ylim([0 max(length(rasterA), length(rasterC))+1])
                xlim(rampPlotXLIM)
                
                subplot(3,3,7)
                hold all;
                patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                
                mypsth(outcomeRaster_A_AllTrials, psthKernel, AColor);hold on;
                mypsth(outcomeRaster_C_AllTrials, psthKernel, CColor);
                hold off;
                set(gca, 'fontSize', 12);box off;
                ylabel('Firing rate (Hz)');xlabel('Time (sec)')
                set(gcf, 'Renderer', 'painters')
                xlim(rampPlotXLIM)
                legend('A', '', 'C')
                
                %% Target trials
                subplot(3,3,2)
                hold all;
                patch(firstOdorXpatch, yPatch.*length(outcomeRaster_A_Target),patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch.*length(outcomeRaster_A_Target),patchColor, 'FaceAlpha', patchFaceAlpha)
                for ind = 1:length(outcomeRaster_A_Target)
                    scatter(outcomeRaster_A_Target(ind).times, ind.*ones(1,length(outcomeRaster_A_Target(ind).times)),rasterMarkerSize, ...
                        'MarkerFaceColor',AColor, 'MarkerEdgeColor', 'none');
                end
                %Color the tile
                title(['T+ presentation: A: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', hitColor) '} Hit', ...
                    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', missColor) '} Miss'])
                hold off;
                set(gca, 'fontSize', 12);
                ylabel('Trial #');
                ylim([0 max(size(outcomeRaster_A_Target,2), size(outcomeRaster_C_Target,2))+1])
                xlim(targetPlotXLIM)
                
                subplot(3,3,5)
                hold all;
                patch(firstOdorXpatch, yPatch.*length(outcomeRaster_C_Target),patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch.*length(outcomeRaster_C_Target),patchColor, 'FaceAlpha', patchFaceAlpha)
                for ind = 1:length(outcomeRaster_C_Target)
                    scatter(outcomeRaster_C_Target(ind).times, ind.*ones(1,length(outcomeRaster_C_Target(ind).times)),rasterMarkerSize, ...
                        'MarkerFaceColor',CColor, 'MarkerEdgeColor', 'none');
                end
                %Color the title
                title(['T+ presentation: C: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', hitColor) '} Hit', ...
                    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', missColor) '} Miss'])
                hold off;
                set(gca, 'fontSize', 12);
                ylabel('Trial #')
                ylim([0 max(size(outcomeRaster_A_Target,2), size(outcomeRaster_C_Target,2))+1])
                xlim(targetPlotXLIM)
                
                subplot(3,3,8)
                hold all;
                patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                
                mypsth(outcomeRaster_A_Target, psthKernel, AColor);hold on;
                mypsth(outcomeRaster_C_Target, psthKernel, CColor);
                hold off;
                set(gca, 'fontSize', 12);box off;
                ylabel('Firing rate (Hz)');xlabel('Time (sec)')
                set(gcf, 'Renderer', 'painters')
                xlim(targetPlotXLIM)
                title(['M' num2str(miceInd+1) '; ' mouseData(recInd).date{1} '; ' mouseData(recInd).data.NeuralData.Spikes{unitInd}.tetrode(1:end-4)]) 
                %% non-Target trials
                subplot(3,3,3)
                hold all;
                patch(firstOdorXpatch, yPatch.*length(outcomeRaster_A_nonTarget),patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch.*length(outcomeRaster_A_nonTarget),patchColor, 'FaceAlpha', patchFaceAlpha)
                for ind = 1:length(outcomeRaster_A_nonTarget)
                    scatter(outcomeRaster_A_nonTarget(ind).times, ind.*ones(1,length(outcomeRaster_A_nonTarget(ind).times)),rasterMarkerSize, ...
                        'MarkerFaceColor',colorVec_A_nonTarget{ind}, 'MarkerEdgeColor', 'none');
                end
                %Color the tile
                title(['T- presentation: A: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', CRColor) '} CR', ...
                    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', FAColor) '} FA'])
                hold off;
                set(gca, 'fontSize', 12);
                ylabel('Trial #');
                ylim([0 max(size(outcomeRaster_A_nonTarget,2), size(outcomeRaster_C_nonTarget,2))+1])
                xlim(targetPlotXLIM)
                
                subplot(3,3,6)
                hold all;
                patch(firstOdorXpatch, yPatch.*length(outcomeRaster_C_nonTarget),patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch.*length(outcomeRaster_C_nonTarget),patchColor, 'FaceAlpha', patchFaceAlpha)
                for ind = 1:length(outcomeRaster_C_nonTarget)
                    scatter(outcomeRaster_C_nonTarget(ind).times, ind.*ones(1,length(outcomeRaster_C_nonTarget(ind).times)),rasterMarkerSize, ...
                        'MarkerFaceColor',colorVec_C_nonTarget{ind}, 'MarkerEdgeColor', 'none');
                end
                %Color the title
                title(['T- presentation: C: \color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', CRColor) '} CR', ...
                    '\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', FAColor) '} FA'])
                hold off;
                set(gca, 'fontSize', 12);
                ylabel('Trial #')
                ylim([0 max(size(outcomeRaster_A_Target,2), size(outcomeRaster_C_Target,2))+1])
                xlim(targetPlotXLIM)
                
                subplot(3,3,9)
                hold all;
                patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                
                mypsth(outcomeRaster_A_nonTarget, psthKernel, AColor);hold on;
                mypsth(outcomeRaster_C_nonTarget, psthKernel, CColor);
                hold off;
                set(gca, 'fontSize', 12);box off;
                ylabel('Firing rate (Hz)');xlabel('Time (sec)')
                set(gcf, 'Renderer', 'painters')
                xlim(targetPlotXLIM)
                

                
                signifCounter
                ['M' num2str(miceInd+1) '; ' mouseData(recInd).date{1} '; ' mouseData(recInd).data.NeuralData.Spikes{unitInd}.tetrode(1:end-4)]
%                 close;
                
                figure;
                subplot(4,1,1)
                hold all;
                patch(firstOdorXpatch, yPatch.*length(outcomeRaster_A_AllTrials),patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch.*length(outcomeRaster_A_AllTrials),patchColor, 'FaceAlpha', patchFaceAlpha)
                for ind = 1:length(outcomeRaster_A_AllTrials)
                    scatter(outcomeRaster_A_AllTrials(ind).times, ind.*ones(1,length(outcomeRaster_A_AllTrials(ind).times)),rasterMarkerSize, ...
                        'MarkerFaceColor',AColor, 'MarkerEdgeColor', 'none');
                end
                %Color the tile
                hold off;
                set(gca, 'fontSize', 12);
                ylabel('Trial #');
                ylim([0 max(length(rasterA), length(rasterC))+1])
                xlim(rampPlotXLIM);set(gca, 'XTickLabel', '')
                
                subplot(4,1,2)
                hold all;
                patch(firstOdorXpatch, yPatch.*length(outcomeRaster_C_AllTrials),patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch.*length(outcomeRaster_C_AllTrials),patchColor, 'FaceAlpha', patchFaceAlpha)
                for ind = 1:length(outcomeRaster_C_AllTrials)
                    scatter(outcomeRaster_C_AllTrials(ind).times, ind.*ones(1,length(outcomeRaster_C_AllTrials(ind).times)),rasterMarkerSize, ...
                        'MarkerFaceColor',CColor, 'MarkerEdgeColor', 'none');
                end
                %Color the tile
                hold off;
                set(gca, 'fontSize', 12);
                ylabel('Trial #')
                ylim([0 max(length(rasterA), length(rasterC))+1])
                xlim(rampPlotXLIM);set(gca, 'XTickLabel', '')
                
                subplot(4,1,3:4)
                hold all;
                patch(firstOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                patch(secondOdorXpatch, yPatch,patchColor, 'FaceAlpha', patchFaceAlpha)
                
                mypsth(outcomeRaster_A_AllTrials, psthKernel, AColor);hold on;
                mypsth(outcomeRaster_C_AllTrials, psthKernel, CColor);
                hold off;
                set(gca, 'fontSize', 12);box off;
                ylabel('Firing rate (Hz)');xlabel('Time (sec)')
                set(gcf, 'Renderer', 'painters')
                xlim(rampPlotXLIM)
%                 legend('A', '', 'C')
                set(gcf, 'Renderer', 'painters');
                close all;
            end
            
            
            
        end
    end
end

