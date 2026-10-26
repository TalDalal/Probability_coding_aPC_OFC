function [alltrialsActivity] = firingRatePerTrialForAllUnits(bgTimeWin, fgTimeWin, trialIndsToUse)
%% extract the data
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number
c = 0;
%% Run across mice
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            ISI = mouseData(recInd).data.ISIbetweenOdors./1000;
            odorDuration = mouseData(recInd).data.odor_duration./1000;
            
            %The requested trials to use
            if strcmpi(trialIndsToUse, 'allTrials')
                analysisTrials_A = mouseData(recInd).data.Atrials;
                analysisTrials_C = mouseData(recInd).data.Ctrials;
                
            elseif strcmpi(trialIndsToUse, 'CS+')
                analysisTrials_A = mouseData(recInd).data.targetTrials.A;
                analysisTrials_C = mouseData(recInd).data.targetTrials.C;
                
            elseif strcmpi(trialIndsToUse, 'CS-')
                analysisTrials_A = mouseData(recInd).data.tMinusTrials.A;
                analysisTrials_C = mouseData(recInd).data.tMinusTrials.C;
            end
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                %Record the session num
                alltrialsActivity(c).sessionNum  = [miceInd mouseData(recInd).sessionNum];
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
               
                
                
                % A trials
                Amat = currFRmat(analysisTrials_A,:);
                %Baseline
                bgFR = mean(Amat(:,find(timeBins >= bgTimeWin(1) & timeBins < bgTimeWin(2))),2);
                % PredictingOdor
                fgFR = mean(Amat(:,find(timeBins >= fgTimeWin(1) & timeBins < fgTimeWin(2))),2);
                
                
                % Save the firing rate in each trials
                alltrialsActivity(c).A = fgFR - bgFR;
                

                bgFR = [];fgFR = [];
                
                
                
                % C trials
                Cmat = currFRmat(analysisTrials_C,:);
                %Baseline
                bgFR = mean(Cmat(:,find(timeBins >= bgTimeWin(1) & timeBins < bgTimeWin(2))),2);
                % PredictingOdor
                fgFR = mean(Cmat(:,find(timeBins >= fgTimeWin(1) & timeBins < fgTimeWin(2))),2);
                
                
                % Save the firing rate in each trials
                alltrialsActivity(c).C = fgFR - bgFR;
                
                bgFR = [];fgFR = [];

            end
        end
    end
end
