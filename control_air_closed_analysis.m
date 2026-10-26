H_SR = [];L_SR = [];
%M17
cd('F:\Experiments\2022\Behavior_Probability\head_fixed\data\M17_PC_tetrodes\airCLosed')
[params] = READ_PROB_EXP('M17_airClosed_090724131413', 'head-fixed', 3.4);
if params.probability.A > params.probability.C
    H_SR(end+1) =  params.successRate.A*100;
    L_SR(end+1) =  params.successRate.C*100;
else
    H_SR(end+1) =  params.successRate.C*100;
    L_SR(end+1) =  params.successRate.A*100;
end

%M20
cd('F:\Experiments\2022\Behavior_Probability\head_fixed\data\M20_PC_tetrodes\airClosed')
[params] = READ_PROB_EXP('M20_airClosed_130824111456', 'head-fixed', 3.3);
if params.probability.A > params.probability.C
    H_SR(end+1) =  params.successRate.A*100;
    L_SR(end+1) =  params.successRate.C*100;
else
    H_SR(end+1) =  params.successRate.C*100;
    L_SR(end+1) =  params.successRate.A*100;
end
mean_vec = mean([H_SR' L_SR']);
se_vec = std([H_SR'  L_SR'])./sqrt(length(H_SR));
%%
figure;
barwitherr(se_vec, mean_vec)
hold all;           
scatter(ones(1, length(H_SR)), H_SR, 36, 'MarkerFaceColor', [.5 .5 .5], ...
    'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.5);

scatter(2.*ones(1, length(L_SR)), L_SR, 36, 'MarkerFaceColor', [.5 .5 .5], ...
    'MarkerEdgeColor', 'k', 'MarkerFaceAlpha', 0.5);
set(gca, 'FontSize', 18);box off;
set(gca, 'XTickLabel', {'H', 'L'});
ylabel('Performance (%)');ylim([0 100]); title 'Air closed'