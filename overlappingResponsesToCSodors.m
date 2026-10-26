function [] = overlappingResponsesToCSodors(allMiceData, pValueTH, analysisTimeWin)

% Compute the binary response matrix for each odor
% col1: H, col2: L, col3: CS+, col4: CS-
[taskResponsiveNeuronsMat] = computeBinaryResponseMatrix(allMiceData, pValueTH, analysisTimeWin);
taskResponsiveNeuronsMat =  abs(taskResponsiveNeuronsMat);

%CS+
H_CSplus_responding = taskResponsiveNeuronsMat(:,1).*taskResponsiveNeuronsMat(:,3).*(~taskResponsiveNeuronsMat(:,2));
L_CSplus_responding = taskResponsiveNeuronsMat(:,2).*taskResponsiveNeuronsMat(:,3).*(~taskResponsiveNeuronsMat(:,1));
H_L_CSplus_responding = taskResponsiveNeuronsMat(:,1).*taskResponsiveNeuronsMat(:,2).*taskResponsiveNeuronsMat(:,3);

%CS-
H_CSminus_responding = taskResponsiveNeuronsMat(:,1).*taskResponsiveNeuronsMat(:,4);
L_CSminus_responding = taskResponsiveNeuronsMat(:,2).*taskResponsiveNeuronsMat(:,4);
H_L_CSminus_responding = taskResponsiveNeuronsMat(:,1).*taskResponsiveNeuronsMat(:,2).*taskResponsiveNeuronsMat(:,4);

%Compute rates
%CS+
H_CSplus_responseRate = sum(H_CSplus_responding)./sum(taskResponsiveNeuronsMat(:,3));
L_CSplus_responseRate = sum(L_CSplus_responding)./sum(taskResponsiveNeuronsMat(:,3));
H_L_CSplus_responseRate = sum(H_L_CSplus_responding)./sum(taskResponsiveNeuronsMat(:,3));


H_CSminus_responseRate = sum(H_CSminus_responding)./sum(taskResponsiveNeuronsMat(:,4));
L_CSminus_responseRate = sum(L_CSminus_responding)./sum(taskResponsiveNeuronsMat(:,4));

figure;
title('CS+')
venn(sum([H_CSplus_responding L_CSplus_responding])+sum(H_L_CSplus_responding), sum(H_L_CSplus_responding))

end

function [taskResponsiveNeuronsMat] = computeBinaryResponseMatrix(allMiceData, pValueTH, analysisTimeWin)
c = 0;

%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            
            Atrials = mouseData(recInd).data.Atrials;
            Ctrials = mouseData(recInd).data.Ctrials;
                        
            CS_plus_trials = [mouseData(recInd).data.targetTrials.A mouseData(recInd).data.targetTrials.B mouseData(recInd).data.targetTrials.C];
            CS_minus_trials = [mouseData(recInd).data.tMinusTrials.A mouseData(recInd).data.tMinusTrials.B mouseData(recInd).data.tMinusTrials.C];
            

            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;

            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;

                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= analysisTimeWin(1,1) & timeBins < analysisTimeWin(1,2));
                firstOdorDuration = find(timeBins >= analysisTimeWin(2,1) & timeBins < analysisTimeWin(2,2));
                CSDuration = find(timeBins >= analysisTimeWin(3,1) & timeBins < analysisTimeWin(3,2));
                
                %---------------------- Predicting odors --------------------------
                taskResponsiveNeuronsMat(c,:) = nan(1,4);
                
                Amat = currFRmat(Atrials,:);
                Cmat = currFRmat(Ctrials,:);
                
                %Baseline
                bgFR = mean(currFRmat(:,baselineDuration),2);
                
                % first Odor
                firstOdorFR_A = mean(Amat(:,firstOdorDuration),2);
                [h_A,~] = ttest2(bgFR, firstOdorFR_A, 'alpha', pValueTH);
                if mean(firstOdorFR_A) < mean(bgFR)
                    h_A = h_A*-1;
                end
                
                firstOdorFR_C = mean(Cmat(:,firstOdorDuration),2);
                [h_C,~] = ttest2(bgFR, firstOdorFR_C, 'alpha', pValueTH);
                if mean(firstOdorFR_C) < mean(bgFR)
                    h_C = h_C*-1;
                end
                
                %Check if this odor was H or L
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    taskResponsiveNeuronsMat(c,1) = h_A; taskResponsiveNeuronsMat(c,2) = h_C;
                else
                    taskResponsiveNeuronsMat(c,1) = h_C; taskResponsiveNeuronsMat(c,2) = h_A;
                end
                
                
                % CS + Odor
                csPlusOdorFR = mean(currFRmat(CS_plus_trials,CSDuration),2);
                [h,~] = ttest2(bgFR, csPlusOdorFR, 'alpha', pValueTH);
                if mean(csPlusOdorFR) < mean(bgFR)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat(c,3) = h;
                
                % CS - Odor
                csMinusOdorFR = mean(currFRmat(CS_minus_trials,CSDuration),2);
                [h,~] = ttest2(bgFR, csMinusOdorFR, 'alpha', pValueTH);
                if mean(csMinusOdorFR) < mean(bgFR)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat(c,4) = h;
                
            end
        end
    end
end
%Avoid nans
taskResponsiveNeuronsMat(isnan(taskResponsiveNeuronsMat)) = 0;
taskResponsiveNeuronsMat(isnan(taskResponsiveNeuronsMat)) = 0;
end
