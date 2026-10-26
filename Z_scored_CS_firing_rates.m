function [activityMatrix] = Z_scored_CS_firing_rates(allMiceData, bgPeriod, fgPeriod, odorType)

c = 0;
activityMatrix = [];

%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
           
            CS_plus_trials = [mouseData(recInd).data.targetTrials.A  mouseData(recInd).data.targetTrials.C];
            CS_minus_trials = [mouseData(recInd).data.tMinusTrials.A mouseData(recInd).data.tMinusTrials.C];
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
            currSuccessRate = mean([mouseData(recInd).data.successRate.A mouseData(recInd).data.successRate.A]);

            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= bgPeriod(1) & timeBins <= bgPeriod(2));
                fgDuration = find(timeBins >= fgPeriod(1) & timeBins <= fgPeriod(2));
                
%%                      %CS+
                        odorDuration_fr_CSplus = mean(currFRmat(CS_plus_trials,fgDuration),2);
                        
                        baselineActivityfr_CSplus = mean(currFRmat(CS_plus_trials,baselineDuration),2);
                        

                         %CS-                       
                        odorDuration_fr_CSminus = mean(currFRmat(CS_minus_trials,fgDuration),2);
                        
                        baselineActivity_fr_CSminus = mean(currFRmat(CS_minus_trials,baselineDuration),2);
                
                
                %--- Stat ----
                                
                significantResponse = [];
                
                % Test for odor response
                if strcmpi(odorType, 'CS+')
                    [significantResponse,~] = ttest(odorDuration_fr_CSplus, baselineActivityfr_CSplus);
                elseif strcmpi(odorType, 'CS-')
                    [significantResponse,~] = ttest(odorDuration_fr_CSminus, baselineActivity_fr_CSminus);
                end
                
                if isequal(significantResponse,1) 
                    numOfRespondingNeurons(c) = 1;
                    
                    CS_plus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(CS_plus_trials);
                    CS_minus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(CS_minus_trials);
                    
                    % Compute evoked z-score
                    
                    if strcmpi(odorType, 'CS+')
                        [zCS] = computeZscorefromRaster(CS_plus_raster, bgPeriod, fgPeriod);
                    elseif strcmpi(odorType, 'CS-')
                        [zCS] = computeZscorefromRaster(CS_minus_raster, bgPeriod, fgPeriod);
                    end
                    
                    activityMatrix(end+1,:) = [zCS  currSuccessRate];
                end

               
                
                
                
                
            end
        end
    end
end

%% divide to naive and expert
 activityMatrix(isinf(activityMatrix),:) = [];

