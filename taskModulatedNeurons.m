function [taskModulationMat] = taskModulatedNeurons(allMiceData, pValue, analysisTimeWin, bgPeriod, brainRegion)

if nargin < 5
    brainRegion = 'PC';
end
numOfConditions = 8;c = 0

for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
            
            Atrials = mouseData(recInd).data.Atrials;
            Ctrials = mouseData(recInd).data.Ctrials;
                        
            CS_plus_A_trials = mouseData(recInd).data.targetTrials.A;
            CS_plus_C_trials = mouseData(recInd).data.targetTrials.C;
            
            CS_minus_A_trials = mouseData(recInd).data.tMinusTrials.A;
            CS_minus_C_trials = mouseData(recInd).data.tMinusTrials.C;
                        

            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;

            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;

                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= bgPeriod(1,1) & timeBins < bgPeriod(1,2));
                
                predictingOdorDuration = find(timeBins >= analysisTimeWin(1,1) & timeBins < analysisTimeWin(1,2));
                delay = find(timeBins >= analysisTimeWin(2,1) & timeBins < analysisTimeWin(2,2));
                CSDuration = find(timeBins >= analysisTimeWin(3,1) & timeBins < analysisTimeWin(3,2));
                
                
                taskResponsiveNeuronsMat(c,:) = nan(1,numOfConditions);
                
                
                %Baseline
                bgFR = mean(currFRmat(:,baselineDuration),2);
                
                
                % odor A
                Odor_A_FR = mean(currFRmat(Atrials,predictingOdorDuration),2);
                [taskModulationMat(c,1)] = testResponseSignificance(bgFR, Odor_A_FR, pValue);

                
                % odor C
                Odor_C_FR = mean(currFRmat(Ctrials,predictingOdorDuration),2);
                [taskModulationMat(c,2)] = testResponseSignificance(bgFR, Odor_C_FR, pValue);
                
                % delay A
                delay_A_FR = mean(currFRmat(Atrials,delay),2);
                [taskModulationMat(c,3)] = testResponseSignificance(bgFR, delay_A_FR, pValue);
                
                % delay C
                delay_C_FR = mean(currFRmat(Ctrials,delay),2);
                [taskModulationMat(c,4)] = testResponseSignificance(bgFR, delay_C_FR, pValue);
                
                
                % CS+ A
                CSplus_A_FR = mean(currFRmat(CS_plus_A_trials,CSDuration),2);
                [taskModulationMat(c,5)] = testResponseSignificance(bgFR, CSplus_A_FR, pValue);
                
                % CS+ C
                CSplus_C_FR = mean(currFRmat(CS_plus_C_trials,CSDuration),2);
                [taskModulationMat(c,6)] = testResponseSignificance(bgFR, CSplus_C_FR, pValue);
                
                
                % CS- A
                CSminus_A_FR = mean(currFRmat(CS_minus_A_trials,CSDuration),2);
                [taskModulationMat(c,7)] = testResponseSignificance(bgFR, CSminus_A_FR, pValue);
                
                % CS- C
                CSminus_C_FR = mean(currFRmat(CS_minus_C_trials,CSDuration),2);
                [taskModulationMat(c,8)] = testResponseSignificance(bgFR, CSminus_C_FR, pValue);

                
            end
        end
    end
end
disp([num2str(length(find(sum(abs(taskModulationMat),2) >0))./size(taskModulationMat,1).*100) '% task-modulated neurons'])
end

function [h] = testResponseSignificance(bg, fg, pValue)
[h,~] = ttest2(bg, fg, 'alpha', pValue);
if mean(fg) < mean(bg)
    h = h*-1;
end

end

                
