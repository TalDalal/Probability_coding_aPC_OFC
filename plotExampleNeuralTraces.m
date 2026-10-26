function [] = plotExampleNeuralTraces(mouseData, timeWin)
%e.g. mouseData = allRecs(11).data;
% e.g.timeWin = [0 120];
allTimeVecs = [];allTraces = [];
figure;
spacingVar = 15;% for the plot of the traces
kernelSTD = 0.5;
Ccolor = [171,62,143]./255;%purple
Acolor = [0,169,137]./255;%green
Bcolor = 'b';
%% plot the traces
hold all;
%Run over all the units in this recording
for unitInd = 1:size(mouseData.NeuralData.Spikes,2)
    
    %The current unit spike times
    currUnit = mouseData.NeuralData.Spikes{unitInd}.t;
    % Find the spikes in the requested time window
    loc = find(currUnit >= timeWin(1) & currUnit < timeWin(2));
    %into a struct
    data(1).times = currUnit(loc);
    %PSTH
    if ~isempty(data.times)
        [R,t]=mypsth(data, kernelSTD, 'n');
        R = R-mean(R);
        %plot
        plot(t, (spacingVar*unitInd)+R, 'k', 'LineWidth', 1.5)
    end
end
%% plot the events
allEvents = mouseData.NeuralData.Events(1,1:2:end);
eventsLoc = find(allEvents >= timeWin(1) & allEvents < timeWin(2));

trialOnsets = allEvents(eventsLoc);

outcomeVec = [mouseData.lickIndicator(eventsLoc);mouseData.trialsIndex(eventsLoc)];
patchYsize = [-5 -5 2 2];
textHeight = 5;
textShift = 0.3;
trialDur = (2*mouseData.odor_duration + mouseData.ISIbetweenOdors)./1000;
hold all;
for patchInd = 1:size(outcomeVec,2)
    
    if abs(outcomeVec(2,patchInd)) == 1
        patchColor = Acolor;
    elseif abs(outcomeVec(2,patchInd)) == 2
        patchColor = Bcolor;
    elseif abs(outcomeVec(2,patchInd)) == 3
        patchColor = Ccolor;
    end
    
    if outcomeVec(1,patchInd) == 1
        if outcomeVec(2,patchInd) > 0
            patch([trialOnsets(patchInd) (ones(1,2).*(trialOnsets(patchInd) + trialDur)) trialOnsets(patchInd)], ...
                patchYsize, patchColor)
            text(trialOnsets(patchInd)+textShift, textHeight, 'Hit')
        else
            patch([trialOnsets(patchInd) (ones(1,2).*(trialOnsets(patchInd) + trialDur)) trialOnsets(patchInd)], ...
                patchYsize, patchColor)
            text(trialOnsets(patchInd)+textShift, textHeight, 'FA')
        end
    else % no lick
        if outcomeVec(2,patchInd) > 0
            patch([trialOnsets(patchInd) (ones(1,2).*(trialOnsets(patchInd) + trialDur)) trialOnsets(patchInd)], ...
                patchYsize, patchColor)
            text(trialOnsets(patchInd)+textShift, textHeight, 'Miss')
        else
            patch([trialOnsets(patchInd) (ones(1,2).*(trialOnsets(patchInd) + trialDur)) trialOnsets(patchInd)], ...
                patchYsize, patchColor)
            text(trialOnsets(patchInd)+textShift, textHeight, 'CR')
        end
    end
end


set(gca, 'YTick', '');set(gca, 'FontSize', 14');box off;
ylabel('Neurons');xlabel('Time (sec)');set(gcf, 'Renderer', 'painters')

