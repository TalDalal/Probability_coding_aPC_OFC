function [outputStruct] = detect_PE_neurons_M_condition(allMiceData, bgPeriod, fgPeriod, trialsType, pValue, comapreToH_L)

c = 0;
minFRdiff = 2;
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green
outputStruct = [];

%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            if ~isempty( mouseData(recInd).data.targetTrials.B)
                
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    
                    if strcmpi(comapreToH_L, 'M_vs_H')
                        Atrials = mouseData(recInd).data.Atrials;
                        A_CS_plus_trials = mouseData(recInd).data.targetTrials.A;
                        A_CS_minus_trials = mouseData(recInd).data.tMinusTrials.A;
                        
                        Ctrials = mouseData(recInd).data.Btrials;
                        C_CS_plus_trials = mouseData(recInd).data.targetTrials.B;
                        C_CS_minus_trials = mouseData(recInd).data.tMinusTrials.B;
                        
                    elseif strcmpi(comapreToH_L, 'M_vs_L')
                        
                        Atrials = mouseData(recInd).data.Btrials;
                        A_CS_plus_trials = mouseData(recInd).data.targetTrials.B;
                        A_CS_minus_trials = mouseData(recInd).data.tMinusTrials.B;
                        
                        Ctrials = mouseData(recInd).data.Ctrials;
                        C_CS_plus_trials = mouseData(recInd).data.targetTrials.C;
                        C_CS_minus_trials = mouseData(recInd).data.tMinusTrials.C;
                    end
                elseif mouseData(recInd).data.probability.A < mouseData(recInd).data.probability.C
                    
                    if strcmpi(comapreToH_L, 'M_vs_H')
                        Atrials = mouseData(recInd).data.Btrials;
                        A_CS_plus_trials = mouseData(recInd).data.targetTrials.B;
                        A_CS_minus_trials = mouseData(recInd).data.tMinusTrials.B;
                        
                        Ctrials = mouseData(recInd).data.Ctrials;
                        C_CS_plus_trials = mouseData(recInd).data.targetTrials.C;
                        C_CS_minus_trials = mouseData(recInd).data.tMinusTrials.C;
                        
                    elseif strcmpi(comapreToH_L, 'M_vs_L')
                        
                        Atrials = mouseData(recInd).data.Atrials;
                        A_CS_plus_trials = mouseData(recInd).data.targetTrials.A;
                        A_CS_minus_trials = mouseData(recInd).data.tMinusTrials.A;
                        
                        Ctrials = mouseData(recInd).data.Btrials;
                        C_CS_plus_trials = mouseData(recInd).data.targetTrials.B;
                        C_CS_minus_trials = mouseData(recInd).data.tMinusTrials.B;
                    end 
                    
                end
                
                timeBins = mouseData(recInd).data.firingRateAnalysisBins;
                
                
                %Run across units per recording
                for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                    c = c + 1;
                    
                    
                    %Current trial X time firing rate mat
                    currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                    
                    baselineDuration = find(timeBins >= bgPeriod(1) & timeBins <= bgPeriod(2));
                    fgDuration = find(timeBins >= fgPeriod(1) & timeBins <= fgPeriod(2));
                    
                    %%
                    
                    
                    switch trialsType
                        case 'allTrials'
                            
                            
                            %A
                            fgFR_A = mean(currFRmat(Atrials,fgDuration),2);
                            % C
                            fgFR_C = mean(currFRmat(Ctrials,fgDuration),2);
                            
                            globalActivity = mean(currFRmat(:,fgDuration),2);
                            
                        case 'CS+'% CS + Odor
                            
                            %A
                            fgFR_A = mean(currFRmat(A_CS_plus_trials,fgDuration),2);
                            % C
                            fgFR_C = mean(currFRmat(C_CS_plus_trials,fgDuration),2);
                            
                            globalActivity = mean(currFRmat([A_CS_plus_trials C_CS_plus_trials],fgDuration),2);
                            
                            baselineActivity = mean(currFRmat([A_CS_plus_trials C_CS_plus_trials],baselineDuration),2);
                            
                        case 'CS-' % CS - Odor
                            
                            %A
                            fgFR_A = mean(currFRmat(A_CS_minus_trials,fgDuration),2);
                            % C
                            fgFR_C = mean(currFRmat(C_CS_minus_trials,fgDuration),2);
                            
                            globalActivity = mean(currFRmat([A_CS_minus_trials C_CS_minus_trials],fgDuration),2);
                            
                            baselineActivity = mean(currFRmat([A_CS_minus_trials C_CS_minus_trials],baselineDuration),2);
                    end
                    
                    
                    %--- Stat ----
                    
                    h_fr_A_vs_C = [];odor_response = [];
                    currModulatedActivity = 0;
                    % Test for odor response
                    [odor_response,~] = ttest(baselineActivity, globalActivity);
                    
                    if isequal(odor_response,1)
                        numOfRespondingNeurons(c) = 1;
                        [h_fr_A_vs_C] = ttest2(fgFR_A, fgFR_C, 'Alpha', pValue);
                        
                        if isequal(h_fr_A_vs_C,1)
                            currModulatedActivity = 1;
                            
                        end
                    end
                    
                    evokedFR_A = (mean(fgFR_A));
                    evokedFR_C = (mean(fgFR_C));
                    
                    A_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(Atrials);
                    A_CS_plus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(A_CS_plus_trials);
                    A_CS_minus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(A_CS_minus_trials);
                    
                    
                    C_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(Ctrials);
                    C_CS_plus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(C_CS_plus_trials);
                    C_CS_minus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(C_CS_minus_trials);
                    
                    
                    
                    %% ------ Assign the response flag by probability ------
                    
                    if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                        highFlag{c} = 'A';
                        
                        evokedFR_high(c) = evokedFR_A;
                        evokedFR_low(c) = evokedFR_C;
                        
                        highRaster{c} = A_raster;
                        lowRaster{c} = C_raster;
                        
                        
                        high_CS_plus_Raster{c} = A_CS_plus_raster;
                        high_CS_minus_Raster{c} = A_CS_minus_raster;
                        
                        low_CS_plus_Raster{c} = C_CS_plus_raster;
                        low_CS_minus_Raster{c} = C_CS_minus_raster;
                        
                        
                    else
                        highFlag{c} = 'C';
                        evokedFR_high(c) = evokedFR_C;
                        evokedFR_low(c) = evokedFR_A;
                        
                        highRaster{c} = C_raster;
                        lowRaster{c} = A_raster;
                        
                        high_CS_plus_Raster{c} = C_CS_plus_raster;
                        high_CS_minus_Raster{c} = C_CS_minus_raster;
                        
                        low_CS_plus_Raster{c} = A_CS_plus_raster;
                        low_CS_minus_Raster{c} = A_CS_minus_raster;
                        
                    end
                    
                    modulationMat(c) = currModulatedActivity;
                    
                    
                    
                end
            end
        end
        
    end
end

outputStruct.modulationMat = modulationMat;

outputStruct.evokedFR_high = evokedFR_high;
outputStruct.evokedFR_low = evokedFR_low;

outputStruct.highRaster = highRaster;
outputStruct.lowRaster = lowRaster;

outputStruct.high_CS_plus_Raster = high_CS_plus_Raster;
outputStruct.high_CS_minus_Raster = high_CS_minus_Raster;

outputStruct.low_CS_plus_Raster = low_CS_plus_Raster;
outputStruct.low_CS_minus_Raster = low_CS_minus_Raster;

outputStruct.numOfRespondingNeurons = numOfRespondingNeurons;



%%

