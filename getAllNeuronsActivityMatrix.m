function [allNeuronsActivityMat, timeBins, minNumTrials] = getAllNeuronsActivityMatrix(allMiceData,trialsType)

c = 0;
A_high_c = 0;
A_Low_c = 0;
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
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                
                %Probability flag
                
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    probFlag = 'odor_A_is_high';
                    A_high_c = A_high_c+1;
                else
                    probFlag = 'odor_C_is_high';
                    A_Low_c = A_Low_c+1;
                end
                

                switch trialsType
                    case 'allTrials'
                        
                        switch probFlag
                            case 'odor_A_is_high'
                                allNeuronsActivityMat(c).High = currFRmat(Atrials,:);
                                allNeuronsActivityMat(c).Low = currFRmat(Ctrials,:);
                            case 'odor_C_is_high'
                                allNeuronsActivityMat(c).High = currFRmat(Ctrials,:);
                                allNeuronsActivityMat(c).Low = currFRmat(Atrials,:);
                        end
                        
                        allNeuronsActivityMat(c).A = currFRmat(Atrials,:);
                        allNeuronsActivityMat(c).C = currFRmat(Ctrials,:);
                        
                        
                    case 'CS+'
                        % CS + Odor
                        switch probFlag
                            case 'odor_A_is_high'
                                allNeuronsActivityMat(c).High = currFRmat(A_CS_plus_trials,:);
                                allNeuronsActivityMat(c).Low = currFRmat(C_CS_plus_trials,:);
                            case 'odor_C_is_high'
                                allNeuronsActivityMat(c).High = currFRmat(C_CS_plus_trials,:);
                                allNeuronsActivityMat(c).Low = currFRmat(A_CS_plus_trials,:);
                        end
                        
                        allNeuronsActivityMat(c).A = currFRmat(A_CS_plus_trials,:);
                        allNeuronsActivityMat(c).C = currFRmat(C_CS_plus_trials,:);
                        
                    case 'CS-'
                        % CS - Odor
                        switch probFlag
                            case 'odor_A_is_high'
                                allNeuronsActivityMat(c).High = currFRmat(A_CS_minus_trials,:);
                                allNeuronsActivityMat(c).Low = currFRmat(C_CS_minus_trials,:);
                            case 'odor_C_is_high'
                                allNeuronsActivityMat(c).High = currFRmat(C_CS_minus_trials,:);
                                allNeuronsActivityMat(c).Low = currFRmat(A_CS_minus_trials,:);
                        end
                        
                        allNeuronsActivityMat(c).A = currFRmat(A_CS_minus_trials,:);
                        allNeuronsActivityMat(c).C = currFRmat(C_CS_minus_trials,:);
                        
                end
                
                minNumTrials(c) = min(size(allNeuronsActivityMat(c).High,1), size(allNeuronsActivityMat(c).Low,1));
            end
        end
    end
end