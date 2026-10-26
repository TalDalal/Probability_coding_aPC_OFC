clear;clc
%% READ THE DATA FROM ALL EXPERIMENTS
%Cage 394
fileNames = {'m1_150922141732', 'm1_150922142607'};%15.09.22
%Cage 414
% fileNames = {'m2_150922150802', 'm2_150922145912'};%15.09.22
% fileNames = {'m1_150922131727', 'm1_150922132733'};first pair, 15.09.22
% fileNames = {'m1_140922132010', 'm1_140922130829'};% 14.09.22 - M394
% fileNames = {'prob80_190922122952', 'prob50_190922144923'};%19.09.22 - % M394 - th 0.4

targetProbability = {'80%', '50%'};
global lickTh
lickTh = 0.45;

figure; 
successData = [];
anticpLicks = [];
for expInd = 1:length(fileNames)
    % read the dat file
    [outputStruct, params] = READ_EXPERIMENT(fileNames{expInd});
    
    % Extract lick times
    lickData =   outputStruct.hitLickData;
    
    r = randsample(length(lickData), length(lickData));
    lickData = lickData(r);
    lickData = lickData(1:30);
    
    subplot(2,3,expInd)
    for lickInd = 1:length(lickData)
        firstLick(lickInd) = lickData(lickInd).times(1);
    end
    %sort
    [~,loc] = sort(firstLick, 'ascend');lickData = lickData(loc);
    
    %Plot rasterplot
    for lickInd = 1:length(lickData)
        % normalize the times
        lickData(lickInd).times = lickData(lickInd).times-outputStruct.lickBaseline/outputStruct.sampleRate;
        
        scatter(lickData(lickInd).times, lickInd.*ones(1, length(lickData(lickInd).times)),20, 'k', 'filled');
        hold on;
    end
    box off;xlabel('Time from odor onset (sec)');ylabel('Trials');
    patch([0 params.odor_duration/outputStruct.sampleRate params.odor_duration/outputStruct.sampleRate 0], [0 0 length(lickData) length(lickData)], 'k', 'faceAlpha', 0.1)
    xlim([-outputStruct.lickBaseline outputStruct.delay_duration]./outputStruct.sampleRate)
    ylim([0 length(lickData)])
    title(targetProbability{expInd})
    
    % normalize the times
    firstLick = firstLick -outputStruct.lickBaseline/outputStruct.sampleRate;
    allLickData(expInd).lick = lickData;
    
    % Licks within the odor
    licksWithinOdor{expInd} = firstLick(find(firstLick > params.windowStartLickAnalaysis/outputStruct.sampleRate & firstLick < params.odor_duration/outputStruct.sampleRate));
    
    % Anticipitory licks
    anticpLicks{expInd} = firstLick(find(firstLick < params.windowStartLickAnalaysis/outputStruct.sampleRate));
    lickData = [];firstLick = [];
    
    successData = [successData  [outputStruct.hitRate;outputStruct.FARate; outputStruct.finalSucc]];
    
end

% Plot the mean latency
subplot(2,3,3)
barwitherr([std(licksWithinOdor{1})./length(licksWithinOdor{1}) std(licksWithinOdor{2})./length(licksWithinOdor{2})], ... 
    [mean(licksWithinOdor{1}) mean(licksWithinOdor{2})], 'k')
[~,p] = ttest2(licksWithinOdor{1}, licksWithinOdor{2});
title(['P = ' num2str(p)])
box off;ylabel('First lick latency (sec)');set(gca, 'XTickLabel', targetProbability)

% Plot the success rates
subplot(2,3,4)
bar(successData')
title('Succes rates')
box off;ylabel('% success');set(gca, 'XTickLabel', targetProbability)
legend('Hit', 'FA', 'Total')

% Plot the PSTHs
subplot(2,3,5)
mypsth(allLickData(1).lick, 0.05, 'r');
hold on;
mypsth(allLickData(2).lick, 0.05, 'b');
box off;ylabel('Mean # licks');xlabel('Time (sec)')
legend(targetProbability)