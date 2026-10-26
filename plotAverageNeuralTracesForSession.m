function [] = plotAverageNeuralTracesForSession(mouseData)
%input example
% mouseData = allRecs(3).data;
highColor = [0,169,137]./255;%green
lowColor = [171,62,143]./255;%purple


kernelSTD = 0.1;spacingVar = 10;% for the plot of the traces
xLIM = [-3 4];lickSmoothKernel = 0.07;

if mouseData.probability.A > mouseData.probability.C
    highTrials = mouseData.Atrials;
    lowTrials = mouseData.Ctrials;
    highLickRaster = mouseData.LickRaster.hit.A;
    lowLickRaster = mouseData.LickRaster.hit.C;
else
    highTrials = mouseData.Ctrials;
    lowTrials = mouseData.Atrials;
    highLickRaster = mouseData.LickRaster.hit.C;
    lowLickRaster = mouseData.LickRaster.hit.A;
end


%Run over all the units in this recording
figure
subplot(10,1,1:2)
mypsth(highLickRaster, lickSmoothKernel, highColor)
hold on;
mypsth(lowLickRaster, lickSmoothKernel, lowColor)


subplot(10,1,3:10)
for unitInd = 1:size(mouseData.allRasterPlots,2)
    
    currHighRaster = mouseData.allRasterPlots(unitInd).data(highTrials);
    currLowRaster = mouseData.allRasterPlots(unitInd).data(lowTrials);
    
    [Rhigh,tHigh]=mypsth(currHighRaster, kernelSTD, 'n');
    bgPeriodHigh = Rhigh(find(tHigh < 0));
    Rhigh = (Rhigh-mean(bgPeriodHigh));%./std(bgPeriodHigh);
    
    [Rlow,tLow]=mypsth(currLowRaster, kernelSTD, 'n');
    bgPeriodLow = Rlow(find(tLow < 0));
    Rlow = (Rlow-mean(bgPeriodLow));%./std(bgPeriodLow);
    
    %plot
    plot(tHigh, (spacingVar*unitInd)+Rhigh,'Color', highColor, 'LineWidth', 1.5)
    hold on;
    plot(tLow, (spacingVar*unitInd)+Rlow,'Color', lowColor, 'LineWidth', 1.5)
    
    currHighRaster = [];currLowRaster = [];
    
end

hold on;
yLims = [0 spacingVar*unitInd];
patch([-2 -1 -1 -2], [0 0 yLims(2) yLims(2)], [0.5 .5 .5],'FaceAlpha', .2)
patch([0 1 1 0], [0 0 yLims(2) yLims(2)], [0.5 .5 .5],'FaceAlpha', .2)
xlim(xLIM);box off;set(gca, 'FontSize', 14);
set(gca,'YTick',[]);xlabel('Time relative to CS (S)');



