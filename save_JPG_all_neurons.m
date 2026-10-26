function [] = save_JPG_all_neurons(allMiceData,brainRegion, targetFolder)

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
            
            Atrials = mouseData(recInd).data.Atrials;
            A_CS_plus_trials = mouseData(recInd).data.targetTrials.A;
            A_CS_minus_trials = mouseData(recInd).data.tMinusTrials.A;
            
            if isfield(mouseData(recInd).data, 'Btrials')
                Btrials = mouseData(recInd).data.Btrials;
            end
            
            Ctrials = mouseData(recInd).data.Ctrials;
            C_CS_plus_trials = mouseData(recInd).data.targetTrials.C;
            C_CS_minus_trials = mouseData(recInd).data.tMinusTrials.C;
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            

            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                
                currRaster = allMiceData(miceInd).allRecs(recInd).data.allRasterPlots(unitInd).data;
                TT_info = ['M' num2str(miceInd) '_'  mouseData(recInd).date{1} '_' allMiceData(miceInd).allRecs(recInd).data.allRasterPlots(unitInd).data(1).info];
                
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    plot_two_rasters_and_their_psths(currRaster(Atrials), currRaster(Ctrials), highProbColor, lowProbColor)
                else
                    plot_two_rasters_and_their_psths(currRaster(Ctrials), currRaster(Atrials), highProbColor, lowProbColor)
                end
                %Save
                figPath = fullfile(targetFolder, [TT_info, '.fig']);
                jpgPath = fullfile(targetFolder, [TT_info, '.jpg']);
                savefig(figPath); 
                saveas(gcf, jpgPath); 
                close all;
            end
        end
    end
end
                    