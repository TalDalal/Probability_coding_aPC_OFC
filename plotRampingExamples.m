clear;clc

identifiedRamping = [8 9 13 14 15 18 21 22  26 28 30 32 33 34  50 51 52 53 54 63 66 ...
    71 76 83 95  132 143  155 157 163 173 176 ...
    179 189 191 194  221 223 224 228 239 240 249 250 253 254];



patchColor = [190, 190, 190]./255;
cueOdorsTimeWin = [-2 -1];
csOdorsTimeWin = [0 1];
psthKernel = 0.07;
rasterMarkerSize = 5;
minMaxPlot = [0 20];
fontSize = 18;
plotXlim = [-2.5 .5];


%% Get the success rates across mice and recordings
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number
c = 0;
%Run across mice
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            

            Atrials = mouseData(recInd).data.Atrials;
            Ctrials = mouseData(recInd).data.Ctrials;

            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                if sum(c == identifiedRamping)
                    
                    
                    if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                        CColor = [171,62,143]./255;%purple
                        AColor = [0,169,137]./255;%green
                    else
                        AColor = [171,62,143]./255;%purple
                        CColor = [0,169,137]./255;%green
                    end
                    
                    
                    %----------A------------
                    % All trials
                    rasterA = mouseData(recInd).data.allRasterPlots(unitInd).data(Atrials);
                    rasterC = mouseData(recInd).data.allRasterPlots(unitInd).data(Ctrials);
                    
                    figure;
                    % RASTER - A
                    subplot(4,1,1)
                    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[0 0 length(rasterA) length(rasterA)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')                    
                    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[0 0 length(rasterA) length(rasterA)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                    hold all;
                    for ind = 1:length(rasterA)
                        scatter(rasterA(ind).times, ind.*ones(1,length(rasterA(ind).times)),rasterMarkerSize, ...
                            'MarkerFaceColor',AColor, 'MarkerEdgeColor', 'none');
                    end
                    set(gcf, 'Renderer', 'painters');
                    set(gca, 'FontSize', fontSize);box off;
                    xlim(plotXlim);
                    set(gca, 'XTick', '');set(gca, 'YTick', '')
                    set(gca,'XColor', 'none','YColor','none');
                    ylim([0 length(rasterA)])

                    
                    %RASTER - C
                    subplot(4,1,2)
                    
                    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[0 0 length(rasterC) length(rasterC)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[0 0 length(rasterC) length(rasterC)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                    hold all;
                    for ind = 1:length(rasterC)
                        scatter(rasterC(ind).times, ind.*ones(1,length(rasterC(ind).times)),rasterMarkerSize, ...
                            'MarkerFaceColor',CColor, 'MarkerEdgeColor', 'none');
                    end
                    set(gcf, 'Renderer', 'painters');
                    set(gca, 'FontSize', fontSize);box off;
                    xlim(plotXlim);
                    set(gca, 'XTick', '');set(gca, 'YTick', '')
                    set(gca,'XColor', 'none','YColor','none')
                    ylim([0 length(rasterC)])
                    
                    % PSTHs
                    subplot(4,1,3:4)
                    patch([cueOdorsTimeWin(1) cueOdorsTimeWin(2) cueOdorsTimeWin(2) cueOdorsTimeWin(1)],[minMaxPlot(1) minMaxPlot(1) minMaxPlot(2) minMaxPlot(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')                    
                    patch([csOdorsTimeWin(1) csOdorsTimeWin(2) csOdorsTimeWin(2) csOdorsTimeWin(1)],[minMaxPlot(1) minMaxPlot(1) minMaxPlot(2) minMaxPlot(2)],patchColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                    hold all;
                    mypsth(rasterA, psthKernel, AColor);hold on;
                    mypsth(rasterC, psthKernel, CColor);
                    
                    set(gcf, 'Renderer', 'painters');
                    set(gca, 'FontSize', fontSize);box off;
                    xlim(plotXlim);xlabel('Time from CS (S)')
                    ylabel('Firing rate (Hz)')
                    
                    close
                end
                
            end
        end
    end
end

