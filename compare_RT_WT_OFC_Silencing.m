function [] = compare_RT_WT_OFC_Silencing(allMiceData, allMiceData_OFC_SILENCING)
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

[lickData_WT] = analyzeRTforNaiveExpert(allMiceData);
close;

[lickData_OFC] = analyzeRTforNaiveExpert(allMiceData_OFC_SILENCING);
close;

combinedExpertData = {lickData_WT{3} lickData_WT{4} lickData_OFC{3} lickData_OFC{4}};


categories = {'High', 'Low', 'High', 'Low'};
colors = [highProbColor; lowProbColor; highProbColor; lowProbColor;];  % Optional custom colors

figure;
violinplot_with_mean_single_side(combinedExpertData, categories, colors, 1, 0);
ylabel('First lick latency (S)')


figure;
histBins = -2:.2:2;
hist(lickData_WT{4}, histBins)
hold all;
hist(lickData_OFC{4}, histBins)
set(gca, 'FontSize', 18);box off;
xlabel('Reaction time (sec)');ylabel('Count')
[~,p] = kstest2(lickData_WT{4}', lickData_OFC{4}')


