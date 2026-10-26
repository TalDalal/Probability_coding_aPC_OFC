function [params] = plotExpResult(params)
%%

% figure('units','normalized','outerposition',[0 0 1 1]);
figure;
set(gcf, 'Position', get(0, 'Screensize'));
params.lickSmoothKernel = 0.07;
params.sniffSmoothKernel = 0.1;
sniffPlotFlag = 1;

if params.newAnalysisMethodFlag==0
    subplot(1,3,1)
    if isempty(params.targetTrials.B) & isempty(params.targetTrials.C)
        bar([params.hitRate.A params.FA.A params.successRate.A])
        set(gca, 'XTickLabel', {'A (75%)'})
        title(['#A trials: ' num2str(length(params.Atrials))])
        
    elseif  isempty(params.targetTrials.C)
        bar([params.hitRate.A params.FA.A params.successRate.A ; ...
            params.hitRate.B params.FA.B params.successRate.B]);
        set(gca, 'XTickLabel', {'A (75%)', 'B (50%)'})
        title(['#A trials: ' num2str(length(params.Atrials)) '; #B trials: ' num2str(length(params.Btrials))]);
        
    else
        bar([params.hitRate.A params.FA.A params.successRate.A ; ...
            params.hitRate.B params.FA.B params.successRate.B; ...
            params.hitRate.C params.FA.C params.successRate.C]);
        set(gca, 'XTickLabel', {'A (75%)', 'B (50%)', 'C (25%)'})
        title(['#A trials: ' num2str(length(params.Atrials)) '; #B trials: ' num2str(length(params.Btrials)) '; #C trials: ' num2str(length(params.Ctrials))])
    end
    
    legend('Hit', 'FA', 'Final')
    ylabel('Success rate');
    box off;set(gca, 'FontSize', 14);
    %%
    subplot(1,3,2)
    mypsth(params.LickRaster.A, 0.07, Acolor);
    hold all;
    if ~isempty(params.targetTrials.B)
        mypsth(params.LickRaster.B, 0.07, Bcolor);
        legend('A (75%)', 'B (50%)');
        title(['Correct trials: A: ' num2str(length(params.LickRaster.A)) ...
            '/' num2str(length(params.targetTrials.A)) ' ; B: '  ...
            num2str(length(params.LickRaster.B)) '/' ...
            num2str(length(params.targetTrials.B))])
        
    end
    if ~isempty(params.targetTrials.C)
        mypsth(params.LickRaster.C, 0.07, Ccolor);
        legend('A (75%)', 'B (50%)', 'C (25%)');
        title(['Hit trials: A: ' num2str(length(params.LickRaster.A)) ...
            '/' num2str(length(params.targetTrials.A)) ' ; B: '  ...
            num2str(length(params.LickRaster.B)) '/' ...
            num2str(length(params.targetTrials.B)) ' ; C: '  ...
            num2str(length(params.LickRaster.C)) '/' ...
            num2str(length(params.targetTrials.C)) ', lickTh = ' num2str(params.lickTh) ...
            ', Min # licks: ' num2str(params.minimalNumLicks)])
    end
    box off
    xlabel('Time from Go odor onset (S)');
    ylabel('Mean # licks');set(gca, 'FontSize', 14);
    
    %%
    subplot(1,3,3)
    responseTh = 0.1;%Sec after the stimuli
    responseThFlag = 0;
    
    hold all;
    if isempty(params.targetTrials.B) & isempty(params.targetTrials.C)
        if responseThFlag
            params.firstLickLatency.A = params.firstLickLatency.A(find(params.firstLickLatency.A >= responseTh));
        end
        
        hold all;
        barwitherr(std(params.firstLickLatency.A)./length(params.firstLickLatency.A) ,mean(params.firstLickLatency.A));
        set(gca, 'XTickLabel', {'A (75%)'});set(gca, 'FontSize', 14);
        scatter(ones(1,length(params.firstLickLatency.A)), params.firstLickLatency.A, Acolor)
        
    elseif  isempty(params.targetTrials.C)
        
        if responseThFlag
            params.firstLickLatency.A = params.firstLickLatency.A(find(params.firstLickLatency.A >= responseTh));
            params.firstLickLatency.B = params.firstLickLatency.B(find(params.firstLickLatency.B >= responseTh));
        end
        
        barwitherr([std(params.firstLickLatency.A)./length(params.firstLickLatency.A) std(params.firstLickLatency.B)./length(params.firstLickLatency.B)] ...
            ,[mean(params.firstLickLatency.A) mean(params.firstLickLatency.B)]);
        set(gca, 'XTickLabel', {'A (75%)', 'B (50%)'});set(gca, 'FontSize', 14);
        hold all;
        scatter(ones(1,length(params.firstLickLatency.A)), params.firstLickLatency.A, Acolor)
        scatter(2.*ones(1,length(params.firstLickLatency.B)), params.firstLickLatency.B, Bcolor)
        [~,pA_B] = ttest2(params.firstLickLatency.A, params.firstLickLatency.B);
        title(['Reaction time, P = ' num2str(pA_B)])
        
    else
        if responseThFlag
            params.firstLickLatency.A = params.firstLickLatency.A(find(params.firstLickLatency.A >= responseTh));
            params.firstLickLatency.B = params.firstLickLatency.B(find(params.firstLickLatency.B >= responseTh));
            params.firstLickLatency.C = params.firstLickLatency.C(find(params.firstLickLatency.C >= responseTh));
        end
        
        barwitherr([std(params.firstLickLatency.A)./length(params.firstLickLatency.A) ...
            std(params.firstLickLatency.B)./length(params.firstLickLatency.B) ...
            std(params.firstLickLatency.C)./length(params.firstLickLatency.C)] ...
            ,[mean(params.firstLickLatency.A) mean(params.firstLickLatency.B)  mean(params.firstLickLatency.C)]);
        set(gca, 'FontSize', 14);
        set(gca, 'XTickLabel', {'A ', 'B ', 'C'});
        hold all;
        scatter(ones(1,length(params.firstLickLatency.A)), params.firstLickLatency.A, 15, 'filled', Acolor)
        scatter(2.*ones(1,length(params.firstLickLatency.B)), params.firstLickLatency.B, 15, 'filled', Bcolor)
        scatter(3.*ones(1,length(params.firstLickLatency.C)), params.firstLickLatency.C, 15, 'filled', Ccolor)
        [~,pA_B] = ttest2(params.firstLickLatency.A, params.firstLickLatency.B);
        [~,pA_C] = ttest2(params.firstLickLatency.A, params.firstLickLatency.C);
        title(['Reaction time, P A_B = ' num2str(pA_B) ';P A_C = ' num2str(pA_C) ])
        
    end
    hold off
    ylabel('RT relative to T onset (sec)');
    box off;
    
else % new analysis method (more efficient)
    
    %% plot the success rates
    subplot(1,3,1)
    succRateVec = nan(4,3);titleString1 = [];xTickCell = {'','','',''};
    if ~isempty(params.hitRate.A)
        succRateVec(1,:) = [params.hitRate.A params.FA.A params.successRate.A];
        
        if params.probability.A > params.probability.C
            titleString1 = [titleString1 '#H trials: ' num2str(length(params.Atrials)) '; '];
            xTickCell{1} = ['H (' num2str(params.probability.A) ', odor A)'];
        else
            titleString1 = [titleString1 '#L trials: ' num2str(length(params.Atrials)) '; '];
            xTickCell{1} = ['L (' num2str(params.probability.A) ', odor A)'];
        end
    end
    if ~isempty(params.hitRate.B)
        succRateVec(2,:) = [params.hitRate.B params.FA.B params.successRate.B];
        titleString1 = [titleString1 '#M trials: ' num2str(length(params.Btrials)) '; '];
        xTickCell{2} = ['M (' num2str(params.probability.B) ', odor B)'];
    end
    if ~isempty(params.hitRate.C)
        succRateVec(3,:) = [params.hitRate.C params.FA.C params.successRate.C];
        
        if params.probability.A > params.probability.C
            titleString1 = [titleString1 '#L trials: ' num2str(length(params.Ctrials)) '; '];
            xTickCell{3} = ['L (' num2str(params.probability.C) ')'];
        else
            titleString1 = [titleString1 '#H trials: ' num2str(length(params.Ctrials)) '; '];
            xTickCell{3} = ['H (' num2str(params.probability.C) ', odor C)'];
        end
    end
    if ~isempty(params.hitRate.T)
        succRateVec(4,:) = [params.hitRate.T params.FA.T params.successRate.T];
        titleString1 = [titleString1 '#T trials: ' num2str(length(params.Ttrials))];
        xTickCell{4} = ['T alone'];
    end
    bar(succRateVec)
    %     b = bar(succRateVec,'FaceColor','flat')
    %     b. CData(2,:) = [1 0 0];
    %     b. CData(1,:) = [0 1 0];
    title(titleString1)
    set(gca, 'XTickLabel', xTickCell)
    legend('Hit', 'FA', 'Total')
    ylabel('Success rate');
    box off;set(gca, 'FontSize', 14);
    ylim([0 1])
    %% plot the PSTH of the licks
    subplot(1,3,2)
    titleString2 = ['Hit trials: '];
    hold all;lickData = {};
    if ~isempty(params.LickRaster.hit.A)
        lickData{1} =  params.firstLickLatency.A;
        mypsth(params.LickRaster.hit.A, params.lickSmoothKernel, params.Acolor);
        titleString2 = [titleString2  'A: ' num2str(length(params.LickRaster.hit.A)) ...
            '/' num2str(length(params.targetTrials.A)) ' ;'];
    end
    
    if ~isempty(params.LickRaster.hit.B)
        lickData{2} = params.firstLickLatency.B;
        mypsth(params.LickRaster.hit.B, params.lickSmoothKernel, params.Bcolor);
        titleString2 = [titleString2  'B: ' num2str(length(params.LickRaster.hit.B)) ...
            '/' num2str(length(params.targetTrials.B)) ' ;'];
    end
    
    if ~isempty(params.LickRaster.hit.C)
        lickData{3} = params.firstLickLatency.C;
        mypsth(params.LickRaster.hit.C, params.lickSmoothKernel, params.Ccolor);
        titleString2 = [titleString2  'C: ' num2str(length(params.LickRaster.hit.C)) ...
            '/' num2str(length(params.targetTrials.C))];
    end
    
    if ~isempty(params.LickRaster.hit.T)
        lickData{4} = params.firstLickLatency.T;
        mypsth(params.LickRaster.hit.T, params.lickSmoothKernel, params.Tcolor);
        titleString2 = [titleString2  '; T: ' num2str(length(params.LickRaster.hit.T)) ...
            '/' num2str(length(params.targetTrials.T))];
    end
    titleString2 = [titleString2 ', lickTH = ' num2str(params.lickTh)];
    title(titleString2)
    box off
    xlabel('Time from CS cue (S)');
    ylabel('Mean # licks');set(gca, 'FontSize', 14);
    
    %% Plot the mean+-SEM of first lick latency
    subplot(1,3,3)
    %     lickData = {params.firstLickLatency.A, params.firstLickLatency.B, params.firstLickLatency.C, params.firstLickLatency.T};
    
    % This case is for M1, where we initially had only H and M
    if isempty(params.targetTrials.T) & isempty(params.targetTrials.C)
        plotSpread(lickData, 'xNames', {'H', 'M', }, ...
            'distributionMarkers', {'o', 'o', }, 'distributionColors', {params.Acolor, params.Bcolor}, 'showMM', 1)
        [~,pA_B] = ttest2(params.firstLickLatency.A, params.firstLickLatency.B);
        title(['Reaction time, P A->B = ' num2str(pA_B)])
        
        % This case is for sessions without T+\- only
    elseif isempty(params.targetTrials.T)
        if params.probability.A > params.probability.C
            probabilityRTxTicks = {'H', 'M', 'L'};
        else
            probabilityRTxTicks = {'L', 'M', 'H'};
        end
        if length(lickData) > 1
        plotSpread(lickData, 'xNames', probabilityRTxTicks, ...
            'distributionMarkers', {'.', '.', '.'}, 'distributionColors', {params.Acolor, params.Bcolor, params.Ccolor}, 'showMM', 1)
        end
        %Stat
        [~,pA_C] = ttest2(params.firstLickLatency.A, params.firstLickLatency.C);
        if ~isempty(params.firstLickLatency.B)
            [~,pA_B] = ttest2(params.firstLickLatency.A, params.firstLickLatency.B);
            title(['Reaction time, P A->B = ' num2str(pA_B) ';P A->C = ' num2str(pA_C) ])
        else
            title(['Reaction time ;P H vs L = ' num2str(pA_C) ])
        end
        
    else
        plotSpread(lickData, 'xNames', {'H', 'M', 'L', 'T'}, ...
            'distributionMarkers', {'o', 'o', 'o', 'o'}, 'distributionColors', {params.Acolor, params.Bcolor, params.Ccolor, params.Tcolor}, 'showMM', 4)
    end
    ylabel('Time from CS (S)');set(gca, 'FontSize', 14);box off;
    
    
    %% Sniffing data
    if sniffPlotFlag & isfield(params.SniffRaster, 'A') & (length([params.SniffRaster.A.times]) > size(params.SniffRaster.A,2))
        figure;
        hold all;
        ISI = params.ISIbetweenOdors./1000;
        odorDur = params.odor_duration./1000;
        patchFaceAlpha = .2;
        patchHeight = 4;
        
        patch([-ISI-odorDur -ISI  -ISI  -ISI-odorDur], [0 0 patchHeight patchHeight], [.5 .5 .5], 'FaceAlpha', patchFaceAlpha);
        patch([0  odorDur odorDur 0], [0 0 patchHeight patchHeight], [.5 .5 .5], 'FaceAlpha', patchFaceAlpha);
        
        [sniffPSTH_A, sniffTime_A] = mypsth(params.SniffRaster.A, params.sniffSmoothKernel, params.Acolor);
        params.sniffPSTHs.A = [sniffPSTH_A;sniffTime_A];
        
        [sniffPSTH_C, sniffTime_C] = mypsth(params.SniffRaster.C, params.sniffSmoothKernel, params.Ccolor);
        params.sniffPSTHs.C = [sniffPSTH_C;sniffTime_C];
        
        xlabel('Time (sec)');ylabel('Sniff rate (Hz)')
        set(gca, 'FontSize', 14);box off;
        title(['\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', params.highProbColor) '} High', ...
            ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', params.lowProbColor) '} Low'])
    else
        params.sniffPSTHs.A = [];
        params.sniffPSTHs.C = [];
    end
    
    %% plot moving SR and RT
    if params.pretrainingFlag==0
        plotMoving_RT_SR(params)
    end
end
end

function [] = plotMoving_RT_SR(params)

currValue_A = nan;
currValue_C = nan;
for i = 1:length(params.firstLickLatency.all)
    if ismember(i,params.trialOutcome.hit.A)
        currValue_A = mean(params.firstLickLatency.A(1: find(params.trialOutcome.hit.A==i)));
    end
    A_RT_VEC(i) =  currValue_A;
    
    if ismember(i,params.trialOutcome.hit.C)
        currValue_C = mean(params.firstLickLatency.C(1: find(params.trialOutcome.hit.C==i)));
    end
    C_RT_VEC(i) =  currValue_C;
end
if params.probability.A > params.probability.C
    A_color = params.highProbColor;
    C_color = params.lowProbColor;
else
    A_color = params.lowProbColor;
    C_color = params.highProbColor;
end
figure;
subplot(2,1,1)
plot(1:length(params.firstLickLatency.all), A_RT_VEC,'Color', A_color, 'LineWidth', 2)
hold on;
plot(1:length(params.firstLickLatency.all), C_RT_VEC,'Color', C_color, 'LineWidth', 2)
set(gca, 'FontSize', 18);box off;
xlabel('Trials');ylabel('Raection time (sec)')
xlim([1 length(params.firstLickLatency.all)])

%% Moving SR
binary_SR_vec_A = zeros(1,length(params.firstLickLatency.all));
binary_SR_vec_A(params.trialOutcome.hit.A) = 1;
binary_SR_vec_A(params.trialOutcome.FA.A) = -1;

binary_SR_vec_C = zeros(1,length(params.firstLickLatency.all));
binary_SR_vec_C(params.trialOutcome.hit.C) = 3;
binary_SR_vec_C(params.trialOutcome.FA.C) = -3;

sr_win_size = 30;currTrials_A = [];currTrials_C = [];currSR_A = [];currSR_C = [];
for srInd = 1:length(params.firstLickLatency.all)-sr_win_size
    %----A
    currTrials_A = binary_SR_vec_A(srInd:srInd+sr_win_size-1);
    currHit_A = length(find(currTrials_A==1))./length(find(params.trialsIndex(srInd:srInd+sr_win_size-1)==1));
    currFA_A = length(find(currTrials_A==-1))./length(find(params.trialsIndex(srInd:srInd+sr_win_size-1)==-1));
    currSR_A(srInd) = (currHit_A + (1 - currFA_A))/2;
    
    %----C
    currTrials_C = binary_SR_vec_C(srInd:srInd+sr_win_size-1);
    currHit_C = length(find(currTrials_C==3))./length(find(params.trialsIndex(srInd:srInd+sr_win_size-1)==3));
    currFA_C = length(find(currTrials_C==-3))./length(find(params.trialsIndex(srInd:srInd+sr_win_size-1)==-3));
    currSR_C(srInd) = (currHit_C + (1 - currFA_C))/2;
end
subplot(2,1,2)
plot(1:length(params.firstLickLatency.all)-sr_win_size,currSR_A,'Color', A_color, 'LineWidth', 2);
hold all;
plot(1:length(params.firstLickLatency.all)-sr_win_size, currSR_C,'Color', C_color, 'LineWidth', 2);
set(gca, 'FontSize', 18);box off;
ylabel('Success rate');xlabel('Trials');ylim([0 1])
xlim([1 length(params.firstLickLatency.all)])

end
