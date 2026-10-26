function [params] = sortSpikingActivityByTrialType(params)

params.minimalSpikesPerTrial = 2;

%% DIVIDE THE RASTERPLOTS FIRING RATES BY TRIALS OUTCOME AND TYPE
if ~isempty(params.targetTrials.A)
    % data from hit trials
    hitRasterA = params.allRasterPlots(params.clusNum).data(params.trialOutcome.hit.A);
    %delete trials with less than the minimal num of spikes per
    %trial
    [hitRasterA, numHitSpikesA, ~] = countSpikesInRaster(hitRasterA, params.minimalSpikesPerTrial, 1);
    % data from miss trials
    missRasterA = params.allRasterPlots(params.clusNum).data(params.trialOutcome.miss.A);
    [missRasterA, ~, ~] = countSpikesInRaster(missRasterA,params.minimalSpikesPerTrial, 0);
    % data from CR trials
    correcrRejRasterA = params.allRasterPlots(params.clusNum).data(params.trialOutcome.CR.A);
    [correcrRejRasterA, ~, ~] = countSpikesInRaster(correcrRejRasterA,params.minimalSpikesPerTrial, 0);
    % data from FA trials
    FaRasterA = params.allRasterPlots(params.clusNum).data(params.trialOutcome.FA.A);
    [FaRasterA, ~, ~] = countSpikesInRaster(FaRasterA,params.minimalSpikesPerTrial, 0);
    
    
    params.PSTHsAndRasters.hit.A.rasterPlot = hitRasterA;
    params.PSTHsAndRasters.miss.A.rasterPlot = missRasterA;
    params.PSTHsAndRasters.CR.A.rasterPlot = correcrRejRasterA;
    params.PSTHsAndRasters.FA.A.rasterPlot = FaRasterA;
    params.numHitSpikesA = numHitSpikesA;
    
%     %Assign the firing rate
%     for unitInd = 1:size(params.firingRates,2)
%         params.firingRatesByTRialType(unitInd).A.bgFR = params.firingRates(unitInd).bgFR(params.Atrials);
%         params.firingRatesByTRialType(unitInd).A.firstOdor = params.firingRates(unitInd).firstOdor(params.Atrials);
%         params.firingRatesByTRialType(unitInd).A.wait = params.firingRates(unitInd).wait(params.Atrials);
% %         params.firingRatesByTRialType(unitInd).A.secondOdor = params.firingRates(unitInd).secondOdor(params.Atrials);
% %         params.firingRatesByTRialType(unitInd).A.postSecondOdor = params.firingRates(unitInd).postSecondOdor(params.Atrials);
%     end
end
%%
if ~isempty(params.targetTrials.B)
    
    % data from hit trials
    hitRasterB = params.allRasterPlots(params.clusNum).data(params.trialOutcome.hit.B);
    %delete trials with less than the minimal num of spikes per
    %trial
    [hitRasterB, numHitSpikesB, ~] = countSpikesInRaster(hitRasterB,params.minimalSpikesPerTrial, 1);
    % data from miss trials
    missRasterB = params.allRasterPlots(params.clusNum).data(params.trialOutcome.miss.B);
    [missRasterB, ~, ~] = countSpikesInRaster(missRasterB,params.minimalSpikesPerTrial, 0);
    % data from CR trials
    correcrRejRasterB = params.allRasterPlots(params.clusNum).data(params.trialOutcome.CR.B);
    [correcrRejRasterB, ~, ~] = countSpikesInRaster(correcrRejRasterB,params.minimalSpikesPerTrial, 0);
    
    params.PSTHsAndRasters.hit.B.rasterPlot = hitRasterB;
    params.PSTHsAndRasters.miss.B.rasterPlot = missRasterB;
    params.PSTHsAndRasters.CR.B.rasterPlot = correcrRejRasterB;
    params.numHitSpikesB = numHitSpikesB;
    
%     %Assign the firing rate
%     for unitInd = 1:size(params.firingRates,2)
%         params.firingRatesByTRialType(unitInd).B.bgFR = params.firingRates(unitInd).bgFR(params.Btrials);
%         params.firingRatesByTRialType(unitInd).B.firstOdor = params.firingRates(unitInd).firstOdor(params.Btrials);
%         params.firingRatesByTRialType(unitInd).B.wait = params.firingRates(unitInd).wait(params.Btrials);
% %         params.firingRatesByTRialType(unitInd).A.secondOdor = params.firingRates(unitInd).secondOdor(params.Atrials);
% %         params.firingRatesByTRialType(unitInd).A.postSecondOdor = params.firingRates(unitInd).postSecondOdor(params.Atrials);
%     end
end 
    %%
if ~isempty(params.targetTrials.C)
    
    % data from hit trials
    hitRasterC = params.allRasterPlots(params.clusNum).data(params.trialOutcome.hit.C);
    %delete trials with less than the minimal num of spikes per
    %trial
    [hitRasterC, numHitSpikesC, ~] = countSpikesInRaster(hitRasterC,params.minimalSpikesPerTrial, 1);
    % data from miss trials
    missRasterC = params.allRasterPlots(params.clusNum).data(params.trialOutcome.miss.C);
    [missRasterC, ~, ~] = countSpikesInRaster(missRasterC,params.minimalSpikesPerTrial, 0);
    % data from CR trials
    correcrRejRasterC = params.allRasterPlots(params.clusNum).data(params.trialOutcome.CR.C);
    [correcrRejRasterC, ~, ~] = countSpikesInRaster(correcrRejRasterC,params.minimalSpikesPerTrial, 0);
    % data from FA trials
    FaRasterC = params.allRasterPlots(params.clusNum).data(params.trialOutcome.FA.C);
    [FaRasterC, ~, ~] = countSpikesInRaster(FaRasterC,params.minimalSpikesPerTrial, 0);
    
    params.PSTHsAndRasters.hit.C.rasterPlot = hitRasterC;
    params.PSTHsAndRasters.miss.C.rasterPlot = missRasterC;
    params.PSTHsAndRasters.CR.C.rasterPlot = correcrRejRasterC;
    params.PSTHsAndRasters.FA.C.rasterPlot = FaRasterC;
    params.numHitSpikesC = numHitSpikesC;
    
%     %Assign the firing rate
%     for unitInd = 1:size(params.firingRates,2)
%         params.firingRatesByTRialType(unitInd).C.bgFR = params.firingRates(unitInd).bgFR(params.Ctrials);
%         params.firingRatesByTRialType(unitInd).C.firstOdor = params.firingRates(unitInd).firstOdor(params.Ctrials);
%         params.firingRatesByTRialType(unitInd).C.wait = params.firingRates(unitInd).wait(params.Ctrials);
% %         params.firingRatesByTRialType(unitInd).A.secondOdor = params.firingRates(unitInd).secondOdor(params.Atrials);
% %         params.firingRatesByTRialType(unitInd).A.postSecondOdor = params.firingRates(unitInd).postSecondOdor(params.Atrials);
%     end
end
%%
if ~isempty(params.targetTrials.T)
    
    % data from hit trials
    hitRasterT = params.allRasterPlots(params.clusNum).data(params.trialOutcome.hit.T);
    %delete trials with less than the minimal num of spikes per
    %trial
    [hitRasterT, numHitSpikesT, ~] = countSpikesInRaster(hitRasterT,params.minimalSpikesPerTrial, 1);
    % data from miss trials
    missRasterT = params.allRasterPlots(params.clusNum).data(params.trialOutcome.miss.T);
    [missRasterT, ~, ~] = countSpikesInRaster(missRasterT,params.minimalSpikesPerTrial, 0);
    % data from CR trials
    correcrRejRasterT = params.allRasterPlots(params.clusNum).data(params.trialOutcome.CR.Tminus);
    [correcrRejRasterT, ~, ~] = countSpikesInRaster(correcrRejRasterT,params.minimalSpikesPerTrial, 0);
    
    
    params.PSTHsAndRasters.hit.T.rasterPlot = hitRasterT;
    params.PSTHsAndRasters.miss.T.rasterPlot = missRasterT;
    params.PSTHsAndRasters.CR.T.rasterPlot = correcrRejRasterT;
    params.numHitSpikesT = numHitSpikesT;
    
%     %Assign the firing rate
%     for unitInd = 1:size(params.firingRates,2)
%         
%         params.firingRatesByTRialType(unitInd).T.wait = params.firingRates(unitInd).wait(params.Ctrials);
%         params.firingRatesByTRialType(unitInd).T.secondOdor = params.firingRates(unitInd).secondOdor(params.Atrials);
% %         params.firingRatesByTRialType(unitInd).A.postSecondOdor = params.firingRates(unitInd).postSecondOdor(params.Atrials);
%     end
end
