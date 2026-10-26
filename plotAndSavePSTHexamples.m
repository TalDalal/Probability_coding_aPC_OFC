
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green


allPSTHs = pooledPSTHstructEXC(1).PSTHstruct;
%Expert and naive data
naiveExc = allPSTHs(pooledPSTHstructEXC(1).High_responding_exc_inds);
expertExc = allPSTHs(pooledPSTHstructEXC(2).High_responding_exc_inds);

for i = 1:size(expertExc,2)
    curr_High_raster = expertExc(i).rasterHigh;
    curr_Low_raster = expertExc(i).rasterLow;
    
    figure;
    subplot(4,1,1)
    for trialInd = 1:size(curr_High_raster,2)
        scatter(curr_High_raster(trialInd).times, trialInd.*ones(1, length(curr_High_raster(trialInd).times)),10,'MarkerFaceColor', highProbColor,'MarkerEdgeColor', 'none' );
        hold all;
    end
    axis off; xlim([-3 0])
    
    subplot(4,1,2)
    for trialInd = 1:size(curr_Low_raster,2)
        scatter(curr_Low_raster(trialInd).times, trialInd.*ones(1, length(curr_Low_raster(trialInd).times)),10,'MarkerFaceColor', lowProbColor,'MarkerEdgeColor', 'none' );
        hold all;
    end
    axis off; xlim([-3 0])
    
    subplot(4,1,3:4)
    mypsth(curr_High_raster, 0.05, highProbColor);
    hold on;
    mypsth(curr_Low_raster, 0.05, lowProbColor);
    xlim([-3 0])
    set(gca, 'FontSize', 14);box off;
    xlabel('Time relative to CS(S)');ylabel('Firing rate (Hz)')
    
    saveas(gca, ['F:\Experiments\2022\Behavior_Probability\head_fixed\Figures\examplesCueOdor_expert\High_responding_expert_cell#' num2str(i) '.pdf'])
    close;
    
    
end



