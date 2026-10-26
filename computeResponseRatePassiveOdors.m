%% Load
clear;
if ismac
    cd('/Volumes/My Passport/Tal/Experiments/2022/Behavior_Probability/head_fixed/data/passive_odor_stimulation');
else
    cd('F:\Experiments\2022\Behavior_Probability\head_fixed\data\passive_odor_stimulation');
end
load('allPassiveOdorData.mat')
odorIdentities{1} = '2-heptanone(cue)';%'A'
odorIdentities{2} = 'ethyl-acetate(cue)';%'C'
odorIdentities{3} = 'ethyl-butyrate(CS+)';%'T+'
odorIdentities{4} = 'penthyl-acetate(CS-)';%'T-'



responseTH = 0.01;%./size(odorIdentities,2);
responseMat = nan(size(allRecs,2), 5);


for ind = 1:size(allPassiveOdorData,2)
    currParray = allRecs(ind).data.pArray;
    
    responseMat(ind, :) = double(logical(currParray < responseTH));
end
responseRates = sum(responseMat)./size(allRecs,2);responseRates(2) = [];
[sortedPercentages, locs] = sort(responseRates, 'descend');
figure;
plot(sortedPercentages,'ks-', 'LineWidth', 3);
set(gca, 'FontSize', 18, 'XTickLabel', {odorIdentities{locs(1)}, odorIdentities{locs(2)}, odorIdentities{locs(3)}, odorIdentities{locs(4)}});box off;
xtickangle(45);ylabel('Active neurons (%)');
title(['N = ' num2str(size(responseMat,1)) ' neurons'])