function [outputStruct] = detect_delay_modulated_neurons(allMiceData, bgPeriod, fgPeriod, trialsType, numSTDs, brainRegion)

if nargin < 6
    brainRegion = 'PC';
end

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
                c = c + 1;
                
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= bgPeriod(1) & timeBins < bgPeriod(2));
                fgDuration = find(timeBins >= fgPeriod(1) & timeBins < fgPeriod(2));
                
                %% ---------------------- A trials--------------------------
                
                switch trialsType
                    case 'allTrials'
                        Amat = currFRmat(Atrials,:);
                        
                        %Baseline
                        bgFR_A = mean(Amat(:,baselineDuration),2);
                        % fg period
                        fgFR_A = mean(Amat(:,fgDuration),2);
     
                        
                    case 'CS+'% CS + Odor
                        
                        %Baseline
                        bgFR_A = mean(currFRmat(A_CS_plus_trials,baselineDuration),2);
                        % fg period
                        fgFR_A = mean(currFRmat(A_CS_plus_trials,fgDuration),2);
                        
                    case 'CS-' % CS - Odor
                        
                        %Baseline
                        bgFR_A = mean(currFRmat(A_CS_minus_trials,baselineDuration),2);
                        % fg period
                        fgFR_A = mean(currFRmat(A_CS_minus_trials,fgDuration),2);
                        
                end
                %--- Stat ----
                currResponseTH_A = (mean(bgFR_A) + (numSTDs*(std(bgFR_A)./sqrt(length(bgFR_A)))));%mean+2SEM
                if mean(fgFR_A) > currResponseTH_A & (mean(fgFR_A) - currResponseTH_A) > minFRdiff
                    currModulatedActivity_A = 1;
%                     Z_evokedRamping_A = (mean(fgFR_A)-mean(bgFR_A))./std(bgFR_A);
                else
                    currModulatedActivity_A = 0;
%                     Z_evokedRamping_A = 0;
                    
                end
                Z_evokedRamping_A = (mean(fgFR_A)-mean(bgFR_A))./std(bgFR_A);
                A_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(Atrials);
                A_CS_plus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(A_CS_plus_trials);
                A_CS_minus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(A_CS_minus_trials);
                A_evoked_activity = fgFR_A - bgFR_A;

                %% ------- B--------
                if isfield(mouseData(recInd).data, 'Btrials')
                    M_raster{c} = mouseData(recInd).data.allRasterPlots(unitInd).data(Btrials);
                    
                    Bmat = currFRmat(Btrials,:);
                    
                    %Baseline
                    bgFR_M = mean(Bmat(:,baselineDuration),2);
                    % fg period
                    fgFR_M = mean(Bmat(:,fgDuration),2);
                    
                    Z_evokedRamping_M(c) = (mean(fgFR_M)-mean(bgFR_M))./std(bgFR_M);
                    
                    currResponseTH_A = (mean(bgFR_M) + (numSTDs*(std(bgFR_M)./sqrt(length(bgFR_M)))));%mean+2SEM
                    if mean(fgFR_M) > currResponseTH_A & (mean(fgFR_M) - currResponseTH_A) > minFRdiff
                        currModulatedActivity_M = 1;
                        %                     Z_evokedRamping_A = (mean(fgFR_A)-mean(bgFR_A))./std(bgFR_A);
                    else
                        currModulatedActivity_M = 0;
                        %                     Z_evokedRamping_A = 0;
                        
                    end
                else
                    M_raster{c} = [];
                    Z_evokedRamping_M(c) = inf;
                    currModulatedActivity_M = nan;
                end
      
                %% ----------------- C trials------------------------
                
                switch trialsType
                    case 'allTrials'
                        Cmat = currFRmat(Ctrials,:);
                        
                        %Baseline
                        bgFR_C = mean(Cmat(:,baselineDuration),2);
                        % fg period
                        fgFR_C = mean(Cmat(:,fgDuration),2);
  
                        
                    case 'CS+'% CS + Odor
                        %Baseline
                        bgFR_C = mean(currFRmat(C_CS_plus_trials,baselineDuration),2);
                        % fg period
                        fgFR_C = mean(currFRmat(C_CS_plus_trials,fgDuration),2);

                        
                    case 'CS-'% CS - Odor
                        %Baseline
                        bgFR_C = mean(currFRmat(C_CS_minus_trials,baselineDuration),2);
                        % fg period
                        fgFR_C = mean(currFRmat(C_CS_minus_trials,fgDuration),2);

                end
                
                %--- Stat ----
                currResponseTH_C = (mean(bgFR_C) + (numSTDs*(std(bgFR_C)./sqrt(length(bgFR_C)))));%mean+2SEM
                if mean(fgFR_C) > currResponseTH_C & (mean(fgFR_C) - currResponseTH_C) > minFRdiff
                    currModulatedActivity_C = 1;
%                     Z_evokedRamping_C = (mean(fgFR_C)-mean(bgFR_C))./std(bgFR_C);
%                     
                else
                    currModulatedActivity_C = 0;
%                     Z_evokedRamping_C = 0;
                    
                end
                Z_evokedRamping_C = (mean(fgFR_C)-mean(bgFR_C))./std(bgFR_C);
                C_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(Ctrials);
                C_CS_plus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(C_CS_plus_trials);
                C_CS_minus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(C_CS_minus_trials);
                C_evoked_activity = fgFR_C - bgFR_C;

                
                
                %% ------ Assign the response flag by probability ------
                responseMat_High(c) = nan;responseMat_Low(c) = nan;
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    highFlag{c} = 'A';
%                     highCount = highCount + 1;
                    responseMat_High(c) = currModulatedActivity_A;
                    responseMat_Low(c) = currModulatedActivity_C;
                    responseMat_M(c) = currModulatedActivity_M;
                    
                    Z_evokedRamping_High_vec(c) = Z_evokedRamping_A;
                    Z_evokedRamping_Low_vec(c) = Z_evokedRamping_C;
                    
                    highRaster{c} = A_raster;
                    lowRaster{c} = C_raster;
                    
                    
                    high_CS_plus_Raster{c} = A_CS_plus_raster;
                    high_CS_minus_Raster{c} = A_CS_minus_raster;
                    
                    low_CS_plus_Raster{c} = C_CS_plus_raster;
                    low_CS_minus_Raster{c} = C_CS_minus_raster;
                    
                    high_evoked_activity{c} = A_evoked_activity;
                    low_evoked_activity{c} = C_evoked_activity;
                    
                
                else
                    highFlag{c} = 'C';
%                     lowCount = lowCount + 1;
                    responseMat_High(c) = currModulatedActivity_C;
                    responseMat_Low(c) = currModulatedActivity_A;
                    responseMat_M(c) = currModulatedActivity_M;
                    
                    Z_evokedRamping_High_vec(c) = Z_evokedRamping_C;
                    Z_evokedRamping_Low_vec(c) = Z_evokedRamping_A;
                    
                    highRaster{c} = C_raster;
                    lowRaster{c} = A_raster;
                    
                    high_CS_plus_Raster{c} = C_CS_plus_raster;
                    high_CS_minus_Raster{c} = C_CS_minus_raster;
                    
                    low_CS_plus_Raster{c} = A_CS_plus_raster;
                    low_CS_minus_Raster{c} = A_CS_minus_raster;
                    
                    high_evoked_activity{c} = A_evoked_activity;
                    low_evoked_activity{c} = C_evoked_activity;
                    
                end
                
                
                
            end
        end
    end
end
outputStruct.high_Low_Flag = highFlag;
outputStruct.responseMat_High = responseMat_High;
outputStruct.responseMat_Low = responseMat_Low;
outputStruct.responseMat_M = responseMat_M;

outputStruct.Z_evokedRamping_High_vec = Z_evokedRamping_High_vec;
outputStruct.Z_evokedRamping_Low_vec = Z_evokedRamping_Low_vec;
outputStruct.Z_evokedRamping_M = Z_evokedRamping_M;

outputStruct.highRaster = highRaster;
outputStruct.lowRaster = lowRaster;
outputStruct.M_raster = M_raster;

outputStruct.high_CS_plus_Raster = high_CS_plus_Raster;
outputStruct.high_CS_minus_Raster = high_CS_minus_Raster;

outputStruct.low_CS_plus_Raster = low_CS_plus_Raster;
outputStruct.low_CS_minus_Raster = low_CS_minus_Raster;

outputStruct.high_evoked_activity = high_evoked_activity;
outputStruct.low_evoked_activity = low_evoked_activity;



%%

