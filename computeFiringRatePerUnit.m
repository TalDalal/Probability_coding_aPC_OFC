function [params] = computeFiringRatePerUnit(params)
events = params.NeuralData.Events;
bgWin = 2000;
%%
analysisWin = [-bgWin-params.ISIbetweenOdors-params.odor_duration ...%baseline
              -params.ISIbetweenOdors-params.odor_duration ... first odor
              -params.ISIbetweenOdors ... wait
              0 ... second odor
              params.odor_duration ... end of odor
              params.odor_duration*2]./1000;
%%
for clusInd = 1:length(params.NeuralData.Spikes)
    currSpikes = params.NeuralData.Spikes{clusInd}.t;
    c = 0;
    for trialInd = params.targetOdorIndices
        c = c+1;
        currEvent = events(1,trialInd);
        for trialPartInd = 1:length(analysisWin)-1
            currPart = length(currSpikes(find(currSpikes >=  currEvent + analysisWin(trialPartInd) & currSpikes < currEvent + analysisWin(trialPartInd+1))))./(analysisWin(trialPartInd+1)-analysisWin(trialPartInd));
            trialParts(trialPartInd) = currPart;
            currPart = [];
        end
        params.firingRates(clusInd).bgFR(c) = trialParts(1);
        params.firingRates(clusInd).firstOdor(c) = trialParts(2);
        params.firingRates(clusInd).wait(c) = trialParts(3);
        params.firingRates(clusInd).secondOdor(c) = trialParts(4);
        params.firingRates(clusInd).postSecondOdor(c) = trialParts(5);
    end
end