%% Use this data for plotting the example
[allMiceData] = concateMiceData([2 3 5]);
mouseData = allMiceData(3).allRecs;
%% params
currXLim = [-1 3];
lickSmoothKernel = 0.05;
patchSize = 0;
transpValue = .2;
CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
patchColor = [190, 190, 190]./255;

for recInd = 1:size(mouseData,2)
    
    firstOdorTimes = [-mouseData(recInd).data.ISIbetweenOdors-mouseData(recInd).data.odor_duration, -mouseData(1).data(1).odor_duration]./1000;
    secondOdorTimes = [0, mouseData(1).data(1).odor_duration]./1000;
    
    
    %% plot general CS+ and - trials
    allCSplusIndices = find(mouseData(recInd).data.trialsIndex > 0);
    CSplusRaster = mouseData(recInd).data.LickRaster.allTrials(allCSplusIndices);
    
    allCSminusIndices = find(mouseData(recInd).data.trialsIndex < 0);
    CSminusRaster = mouseData(recInd).data.LickRaster.allTrials(allCSminusIndices);
    
    waterOnset = (mouseData(recInd).data.delay_to_water + mouseData(recInd).data.odor_duration)./1000;
    
    fig = figure;
    subplot(1,2,1)
    hold all
    patch([firstOdorTimes(1) firstOdorTimes(2) firstOdorTimes(2) firstOdorTimes(1)], ...
        [0 0 ones(1,2).*size(CSplusRaster,2)+patchSize], ...
        patchColor, 'FaceAlpha', transpValue, 'EdgeColor', 'none')
    
    patch([secondOdorTimes(1) secondOdorTimes(2) secondOdorTimes(2) secondOdorTimes(1)], ...
        [0 0 ones(1,2).*size(CSplusRaster,2)+patchSize], ...
        patchColor, 'FaceAlpha', transpValue, 'EdgeColor', 'none')
    
    
    for trialInd = 1:size(CSplusRaster,2)
        scatter(CSplusRaster(trialInd).times, trialInd.*ones(1,length(CSplusRaster(trialInd).times)), 10, 'k', 'filled');
        hold on;
        scatter(waterOnset, trialInd,5, 'bd')
    end
    title('CS+')
    box off
    xlim([-2.5 3])
    set(gca, 'FontSize', 18)
%     xlabel('Time from cue (S)');
%     ylabel('Trials');set(gca, 'FontSize', 14);
    
    subplot(1,2,2)
    hold all
    patch([firstOdorTimes(1) firstOdorTimes(2) firstOdorTimes(2) firstOdorTimes(1)], ...
        [0 0 ones(1,2).*size(CSminusRaster,2)+patchSize], ...
        patchColor, 'FaceAlpha', transpValue, 'EdgeColor', 'none')
    
    patch([secondOdorTimes(1) secondOdorTimes(2) secondOdorTimes(2) secondOdorTimes(1)], ...
        [0 0 ones(1,2).*size(CSminusRaster,2)+patchSize], ...
        patchColor, 'FaceAlpha', transpValue, 'EdgeColor', 'none')
    
    
    for trialInd = 1:size(CSminusRaster,2)
        scatter(CSminusRaster(trialInd).times, trialInd.*ones(1,length(CSminusRaster(trialInd).times)), 10, 'k', 'filled');
    end
    
    title(['CS-, sessions #' num2str(mouseData(recInd).sessionNum)])
    
    
    han=axes(fig,'visible','off');
    han.Title.Visible='on';
    han.XLabel.Visible='on';
    set(gca, 'FontSize', 12);
    han.YLabel.Visible='on';
    ylabel(han,'Trials');
    xlabel(han,'Time from CS (S)');
    
    xlim([-2.5 3])
    set(gca, 'FontSize', 18)
    clc
end





