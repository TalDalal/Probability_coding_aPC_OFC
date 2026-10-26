
mouseData = allPassiveOdorData(3).data;
kernelSTD = 0.1;spacingVar = 5;% for the plot of the traces

trialsData{1} = mouseData.Atrials;
trialsData{2} = mouseData.Ctrials;
trialsData{3} = mouseData.TplusTrials;
trialsData{4} = mouseData.TminusTrials;

odorIdentities{1} = '2-heptanone(cue)';%'A'
odorIdentities{2} = 'ethyl-acetate(cue)';%'C'
odorIdentities{3} = 'ethyl-butyrate(CS+)';%'T+'
odorIdentities{4} = 'penthyl-acetate(CS-)';%'T-'


%Run over all the units in this recording
figure
for odorInd = 1:size(trialsData,2)
    subplot(1,4,odorInd)
    currTrials = trialsData{odorInd};
    
    for unitInd = 1:size(mouseData.allRasterPlots,2)
        currRaster = mouseData.allRasterPlots(unitInd).data(currTrials);
        [R,t]=mypsth(currRaster, kernelSTD, 'n');
        R = R-mean(R);
        %plot
        plot(t, (spacingVar*unitInd)+R, 'k', 'LineWidth', 1.5)
        hold on;
    end
    hold on;
    yLims = [0 spacingVar*unitInd];
    patch([0 1 1 0], [0 0 yLims(2) yLims(2)], [0.5 .5 .5],'FaceAlpha', .2)
    xlim([-1 3]);box off;set(gca, 'FontSize', 14);
    title(odorIdentities{odorInd});%set(gca,'YTick',[])
end


