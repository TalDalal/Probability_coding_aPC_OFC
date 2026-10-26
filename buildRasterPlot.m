function [params] = buildRasterPlot(params)
events = params.NeuralData.Events;
analysisWin = [-2000-params.ISIbetweenOdors-params.odor_duration params.odor_duration + 3000]./1000;
params.refPeriodTH = 0.003;
inhalationOnsetFlag = 0;

if isfield(params, 'SingleOdorsExp') & params.SingleOdorsExp == 1
    trialsToAnalyze = 1:size(events,2);
else % Case of a regular run with odors per trial
    trialsToAnalyze = params.targetOdorIndices;
end

for clusInd = 1:length(params.NeuralData.Spikes)
    currSpikes = params.NeuralData.Spikes{clusInd}.t;
        data = [];
        
        for trialInd = trialsToAnalyze
            data(end+1).times = currSpikes(find(currSpikes >= events(1,trialInd) + analysisWin(1) & currSpikes < events(1,trialInd) + analysisWin(2))) - events(1,trialInd);
            % if we correct by first inhalation
            if inhalationOnsetFlag
                currSniffs = params.SniffData.InhaleExhale(1,find(params.SniffData.InhaleExhale(1,:) >= events(1,trialInd) + analysisWin(1) & ...
                    params.SniffData.InhaleExhale(1,:) < events(1,trialInd) + analysisWin(2))) - events(1,trialInd);
                currFirstSniff = currSniffs(find(currSniffs > 0,1));
                data(end).times = data(end).times - currFirstSniff;
            end
        end
        data(1).info = params.NeuralData.Spikes{clusInd}.tetrode(1:end-4);
        params.allRasterPlots(clusInd).data = data;
        
        % refractory period violation
        params.NeuralData.Spikes{clusInd}.percentRefPeriodViolation = ...
            (length(find(diff(currSpikes) < params.refPeriodTH))./length(diff(currSpikes))).*100;
end