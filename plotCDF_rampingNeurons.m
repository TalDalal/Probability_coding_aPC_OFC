function [] = plotCDF_rampingNeurons(outputStruct)
figure;
allNormSessionNums = [outputStruct.relativeSessionNum.relSessNum];
[e1,e2] = ecdf(allNormSessionNums);
plot(e2, e1, 'LineWidth', 2, 'Color', rand(1,3))
hold on;
plot([0 1], [0 1], 'k--')
xlabel('Learning sessions (normalized)');
set(gca, 'FontSize', 14');box off;
ylabel('CDF of ramping neurons')
legend('CDF', 'identity')
