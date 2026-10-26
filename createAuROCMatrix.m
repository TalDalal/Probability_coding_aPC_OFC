function [allAuROCtraces, ROCvalsPeriodToSort, timeBins, originalPSTH] = createAuROCMatrix(allRecs,auROCWinSize, expCondition, periodToSort, trialOutcome)
if nargin < 5
    trialOutcome = [];
end
c = 0;
allAuROCtraces = [];
ROCvalsPeriodToSort = [];
%%
%Run over the recordings
for recInd = 1:size(allRecs,2)
    params = allRecs(recInd).data;
    
    % baseline period for the ROC
    bgWin = [-params.odor_duration-params.ISIbetweenOdors-2000 ...
        -params.odor_duration-params.ISIbetweenOdors]./1000;

    % fg trials for the ROC 
    if strcmpi(expCondition, 'Atrials')
        
        if isempty(trialOutcome)
            fgTrials = params.Atrials;
        
        elseif strcmpi(trialOutcome, 'hit')
            fgTrials = params.trialOutcome.hit.A;
        elseif strcmpi(trialOutcome, 'CR')
            fgTrials = params.trialOutcome.CR.A;
        end
        
    elseif strcmpi(expCondition, 'Ctrials')
        
        if isempty(trialOutcome)
            fgTrials = params.Ctrials;
            
        elseif strcmpi(trialOutcome, 'hit')
            fgTrials = params.trialOutcome.hit.C;
        elseif strcmpi(trialOutcome, 'CR')
            fgTrials = params.trialOutcome.CR.C;
        end
    end
    
    for unitInd = 1:size(params.firingRates,2)
        
        c = c+1;
        currFRmat = params.firingRates(unitInd).firingRateByBIn;
        
        %Compute the ROC for A trials
        [auROC, timeBins] = compute_auROC(params, currFRmat, bgWin, fgTrials, auROCWinSize);
        

        allAuROCtraces(end+1,:) = auROC;
        ROCvalsPeriodToSort(end+1) = mean(auROC(find(timeBins >= periodToSort(1) & timeBins < periodToSort(2))));
        auROC = [];
        
        % Save the original PSTH
        rasterA = params.allRasterPlots(unitInd).data(params.Atrials);
        [R,t] = mypsth(rasterA, .1, 'n');
        originalPSTH(c).A = [t;R];
        
        rasterC = params.allRasterPlots(unitInd).data(params.Ctrials);
        [R,t] = mypsth(rasterC, .1, 'n');
        originalPSTH(c).C = [t;R];
 
    end
end


    