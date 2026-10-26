function [] = plotLickRasterExample(mouseData, sessionIndex)
%% Use this data for plotting the example
% mouseData = allMiceData(3).allRecs;%M5
% mouseData = allMiceData(4).allRecs;%M12
%% params
currXLim = [-2 3];
lickSmoothKernel = 0.07;
patchSize = 0;
transpValue = .2;


BColor = [38,40,110]./255;%blue
if mouseData(sessionIndex).data.probability.A > mouseData(sessionIndex).data.probability.C
    AColor = [0,169,137]./255;%green
    
    CColor = [171,62,143]./255;%purple
else
    CColor = [0,169,137]./255;%green
    
    AColor = [171,62,143]./255;%purple
end

GoOdorColor = [.5 .5 .5 ];
Aflag = 1;Bflag = 2;Cflag = 3;
analyzeBodor = 1;% include B (50%) trials

%% plot the example divide by the probability
%M2:
%recInd = 3% Expert
%recInd = 4% 1st session
%recInd = 5% 2nd session
for recInd = sessionIndex%1:size(mouseData,2)
    
    firstOdorTimes = [-mouseData(recInd).data.ISIbetweenOdors-mouseData(recInd).data.odor_duration, -mouseData(1).data(1).odor_duration]./1000;
    secondOdorTimes = [0, mouseData(1).data(1).odor_duration]./1000;
    
    % The rasterplot of licks for the current recording
    [~, sortedLicksIndsA] = sort(mouseData(recInd).data.firstLickLatency.A);
    [~, sortedLicksIndsC] = sort(mouseData(recInd).data.firstLickLatency.C);
    
    currRasterA = mouseData(recInd).data.LickRaster.hit.A;
    currRasterC = mouseData(recInd).data.LickRaster.hit.C;
    
    %Sort by the lick latency
    currRasterA = currRasterA(sortedLicksIndsA);
    currRasterC = currRasterC(sortedLicksIndsC);
    
    if analyzeBodor & ~isempty(mouseData(recInd).data.LickRaster.hit.B)
        [~, sortedLicksIndsB] = sort(mouseData(recInd).data.firstLickLatency.B);

        currRasterB = mouseData(recInd).data.LickRaster.hit.B;

        %Sort by the lick latency
        currRasterB = currRasterB(sortedLicksIndsB);
    end
    
    
    currYLim = [0 max(size(currRasterA,2), size(currRasterC,2)) + patchSize];
    [~,p]=ttest2(mouseData(recInd).data.firstLickLatency.C, mouseData(recInd).data.firstLickLatency.A);
    
    figure
    %Plot A trials
    subplot(1,3,1)
    hold all;
    
    patch([firstOdorTimes(1) firstOdorTimes(2) firstOdorTimes(2) firstOdorTimes(1)], ...
        [0 0 ones(1,2).*size(currRasterA,2)+patchSize], ...
        AColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    patch([secondOdorTimes(1) secondOdorTimes(2) secondOdorTimes(2) secondOdorTimes(1)], ...
        [0 0 ones(1,2).*size(currRasterA,2)+patchSize], ...
        GoOdorColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    for trialInd = 1:size(currRasterA,2)
        scatter(currRasterA(trialInd).times, trialInd.*ones(1,length(currRasterA(trialInd).times)), 10, AColor, 'filled');
    end
    title('A (0.75%)')
    xlim(currXLim);ylim(currYLim)
    set(gca, 'FontSize', 14');box off;
    xlabel('Time relative to CS+ (S)');ylabel('Trials');
    
    
    subplot(1,3,2)
    %Plot C trials
    hold all;
    
    patch([firstOdorTimes(1) firstOdorTimes(2) firstOdorTimes(2) firstOdorTimes(1)], ...
        [0 0 ones(1,2).*size(currRasterA,2)+patchSize], ...
        CColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    patch([secondOdorTimes(1) secondOdorTimes(2) secondOdorTimes(2) secondOdorTimes(1)], ...
        [0 0 ones(1,2).*size(currRasterA,2)+patchSize], ...
        GoOdorColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    for trialInd = 1:size(currRasterC,2)
        scatter(currRasterC(trialInd).times, trialInd.*ones(1,length(currRasterC(trialInd).times)), 10, CColor, 'filled');
    end
    title('C (0.25%)')
    xlim(currXLim);ylim(currYLim);
    set(gca, 'FontSize', 14');box off;
    xlabel('Time relative to CS+ (S)');ylabel('Trials')
    
    
    subplot(1,3,3)
    lickData{1} =  mouseData(recInd).data.firstLickLatency.A;
    lickData{2} = mouseData(recInd).data.firstLickLatency.C;
    plotSpread(lickData, 'xNames', {'H', 'L'}, ...
        'distributionMarkers', {'o', 'o'}, 'distributionColors', {AColor, CColor}, 'showMM', 1)
    title(['P = ' num2str(p)]);
    ylim([0 1.5]);ylabel('Reaction time (s)');set(gca, 'FontSize', 14);box off
    
    
    
    set(gcf, 'Renderer', 'painters')
    
    %% plot general CS+ and - trials
%     AindicesCSplus = find(mouseData(recInd).data.trialsIndex == Aflag);
%     CindicesCSplus = find(mouseData(recInd).data.trialsIndex == Cflag);
%     
%     if analyzeBodor
%         BindicesCSplus = find(mouseData(recInd).data.trialsIndex == Bflag);
%         allCSplusIndices = sort([AindicesCSplus BindicesCSplus  CindicesCSplus]);
%     else
%         allCSplusIndices = sort([AindicesCSplus  CindicesCSplus]);
%     end
%     CSplusRaster = mouseData(recInd).data.LickRaster.allTrials(allCSplusIndices);
%     
%     AindicesCSminus = find(mouseData(recInd).data.trialsIndex == -Aflag);
%     CindicesCSminus = find(mouseData(recInd).data.trialsIndex == -Cflag);
%     allCSminusIndices = sort([AindicesCSminus CindicesCSminus]);
%     CSminusRaster = mouseData(recInd).data.LickRaster.allTrials(allCSminusIndices);
    allCSplusIndices = find(mouseData(recInd).data.trialsIndex > 0);
    CSplusRaster = mouseData(recInd).data.LickRaster.allTrials(allCSplusIndices);
    
    allCSminusIndices = find(mouseData(recInd).data.trialsIndex < 0);
    CSminusRaster = mouseData(recInd).data.LickRaster.allTrials(allCSminusIndices);

    waterOnset = (mouseData(recInd).data.delay_to_water + mouseData(recInd).data.odor_duration)./1000;
    
    figure;
    subplot(1,2,1)
    hold all
    patch([firstOdorTimes(1) firstOdorTimes(2) firstOdorTimes(2) firstOdorTimes(1)], ...
        [0 0 ones(1,2).*size(CSplusRaster,2)+patchSize], ...
        GoOdorColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    patch([secondOdorTimes(1) secondOdorTimes(2) secondOdorTimes(2) secondOdorTimes(1)], ...
        [0 0 ones(1,2).*size(CSplusRaster,2)+patchSize], ...
        GoOdorColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    trialIdentityCSplus = mouseData(recInd).data.trialsIndex(allCSplusIndices);
    for trialInd = 1:size(CSplusRaster,2)
        if trialIdentityCSplus(trialInd)==Aflag
            scatter(CSplusRaster(trialInd).times, trialInd.*ones(1,length(CSplusRaster(trialInd).times)), 10, AColor, 'filled');
        elseif trialIdentityCSplus(trialInd)==Bflag
            scatter(CSplusRaster(trialInd).times, trialInd.*ones(1,length(CSplusRaster(trialInd).times)), 10, BColor, 'filled');
        else
            scatter(CSplusRaster(trialInd).times, trialInd.*ones(1,length(CSplusRaster(trialInd).times)), 10, CColor, 'filled');
        end
        hold on;
        scatter(waterOnset, trialInd,5, 'bd')
    end
    title('CS+')
    box off
    xlabel('Time from CS (s)');
    
    set(gca, 'FontSize', 18)
    ylabel('Trials');
    
    subplot(1,2,2)
    hold all
    patch([firstOdorTimes(1) firstOdorTimes(2) firstOdorTimes(2) firstOdorTimes(1)], ...
        [0 0 ones(1,2).*size(CSminusRaster,2)+patchSize], ...
        GoOdorColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    patch([secondOdorTimes(1) secondOdorTimes(2) secondOdorTimes(2) secondOdorTimes(1)], ...
        [0 0 ones(1,2).*size(CSminusRaster,2)+patchSize], ...
        GoOdorColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    trialIdentityCSminus = mouseData(recInd).data.trialsIndex(allCSminusIndices);
    for trialInd = 1:size(CSminusRaster,2)
        if trialIdentityCSminus(trialInd)==-Aflag
            scatter(CSminusRaster(trialInd).times, trialInd.*ones(1,length(CSminusRaster(trialInd).times)), 10, AColor, 'filled');
        elseif  trialIdentityCSminus(trialInd)==-Bflag
            scatter(CSminusRaster(trialInd).times, trialInd.*ones(1,length(CSminusRaster(trialInd).times)), 10, BColor, 'filled');
        
        else
            scatter(CSminusRaster(trialInd).times, trialInd.*ones(1,length(CSminusRaster(trialInd).times)), 10, CColor, 'filled');
        end
    end
    title(['CS-, sessions #' num2str(recInd)])
    box off;
    xlabel('Time from CS (s)');
     set(gca, 'YTickLabel', '')
    set(gca, 'FontSize', 18)
    
%     subplot(1,3,3)
    figure;
    titleString2 = ['Hit trials: '];
    hold all;lickData = {};
    patch([secondOdorTimes(1) secondOdorTimes(2) secondOdorTimes(2) secondOdorTimes(1)], ...
        [0 0 ones(1,2).*15], ...
        GoOdorColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    patch([firstOdorTimes(1) firstOdorTimes(2) firstOdorTimes(2) firstOdorTimes(1)], ...
        [0 0 ones(1,2).*15], ...
        GoOdorColor, 'EdgeColor','none', 'FaceAlpha', transpValue)
    
    mypsth(mouseData(recInd).data.LickRaster.hit.A, lickSmoothKernel, AColor);
    titleString2 = [titleString2  'A: ' num2str(length(mouseData(recInd).data.LickRaster.hit.A)) ...
        '/' num2str(length(mouseData(recInd).data.targetTrials.A)) ' ;'];
    
    if analyzeBodor & ~isempty(mouseData(recInd).data.LickRaster.hit.B)
            mypsth(mouseData(recInd).data.LickRaster.hit.B, lickSmoothKernel, BColor);
    end
    mypsth(mouseData(recInd).data.LickRaster.hit.C, lickSmoothKernel, CColor);
    titleString2 = [titleString2  'C: ' num2str(length(mouseData(recInd).data.LickRaster.hit.C)) ...
        '/' num2str(length(mouseData(recInd).data.targetTrials.C))];
    
    
    titleString2 = [titleString2 ', lickTH = ' num2str(mouseData(recInd).data.lickTh)];
    title(titleString2)
    box off
    xlabel('Time from CS (s)');
    ylabel('Lick rate (Hz)');set(gca, 'FontSize', 18);
    xlim(currXLim)
    

end





