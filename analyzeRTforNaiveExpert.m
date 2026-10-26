function [lickData] = analyzeRTforNaiveExpert(allMiceData, analyzeM)

lowColor = [171,62,143]./255;%purple
highColor = [0,169,137]./255;%green
mediumColor = [38, 48, 110]./255;


naiveTH = 0.7; expertTH = 0.7;

H_RT = [];L_RT = [];H_SR = [];L_SR = [];signifRTdiff = [];SR = [];M_RT = [];
for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    for recInd = 1:size(allRecs,2)
        if allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
            
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                curr_H_RT = allRecs(recInd).data.firstLickLatency.A;
                curr_L_RT = allRecs(recInd).data.firstLickLatency.C;

            else
                curr_H_RT = allRecs(recInd).data.firstLickLatency.C;
                curr_L_RT = allRecs(recInd).data.firstLickLatency.A;

            end
            if ~isempty(analyzeM) & ~isempty(allRecs(recInd).data.firstLickLatency.B)
                M_RT(end+1) = mean(allRecs(recInd).data.firstLickLatency.B);
            elseif ~isempty(analyzeM)
                M_RT(end+1) = nan;
            end
            %Mean RT
            H_RT(end+1) = mean(curr_H_RT);
            L_RT(end+1) = mean(curr_L_RT);
            %Mean SR
            SR(end+1) = mean([allRecs(recInd).data.successRate.A allRecs(recInd).data.successRate.C]);
            
            [h,~] = ttest2(curr_H_RT, curr_L_RT);
            signifRTdiff(end+1) = h;
            
                
        end
    end
    
end

if analyzeM % analyze M condition data
    %Naive
    naiveHighLick = H_RT(find(SR <= naiveTH ));
    naiveMediumLick = M_RT(find(SR <= naiveTH ));
    naiveLowLick = L_RT(find(SR <= naiveTH));
    %Expert
    expertHighLick = H_RT(find(SR >= expertTH));
    expertMediumLick = M_RT(find(SR >= expertTH));
    expertLowLick = L_RT(find(SR >= expertTH));
    
    lickData{1} = naiveHighLick;
    lickData{2} = naiveMediumLick;
    lickData{3} = naiveLowLick;
    
    lickData{4} = expertHighLick;
    lickData{5} = expertMediumLick;
    lickData{6} = expertLowLick;
    
    % Stat
    [~,pNaive_H_L] = ttest2(naiveHighLick, naiveLowLick);
    [~,pNaive_M_L] = ttest2(naiveMediumLick, naiveLowLick);
    [~,pNaive_M_H] = ttest2(naiveMediumLick, naiveHighLick);
    
    [~,pExpert_H_L] = ttest2(expertHighLick, expertLowLick);
    [~,pExpert_M_L] = ttest2(expertMediumLick, expertLowLick);
    [~,pExpert_M_H] = ttest2(expertHighLick, expertMediumLick);
    
    figure;
    % Generate example data
    categories = {'Naive - H', 'Naive - M', 'Naive - L', 'Expert - H', 'Expert - M', 'Expert - L'};
    colors = [highColor;mediumColor; lowColor; highColor;mediumColor; lowColor;];  % Optional custom colors
    
    % Call the function
    violinplot_with_mean_single_side(lickData, categories, colors, 1, 0);
    ylabel('First lick latency (S)')
    
    disp(['P - naive H vs L = ' num2str(pNaive_H_L) 'P - naive M vs L = ' num2str(pNaive_M_L) ', P - naive M vs H = ' num2str(pNaive_M_H)  ... 
        'P - expert H vs L = ' num2str(pExpert_H_L) 'P - expert M vs L = ' num2str(pExpert_M_L) ', P - expert M vs H = ' num2str(pExpert_M_H)])
    title([num2str(size(allMiceData,2)) ' mice, N = ' num2str(length(H_RT)) ' sessions'])

else
%% Plot
%Naive
naiveHighLick = H_RT(find(SR <= naiveTH ));
naiveLowLick = L_RT(find(SR <= naiveTH));
%Expert
expertHighLick = H_RT(find(SR >= expertTH));
expertLowLick = L_RT(find(SR >= expertTH));

lickData{1} = naiveHighLick;
lickData{2} = naiveLowLick;
lickData{3} = expertHighLick;
lickData{4} = expertLowLick;


% Stat
[~,pNaive] = ttest2(naiveHighLick, naiveLowLick);
[~,pExpert] = ttest2(expertHighLick, expertLowLick);

[~,pNaive_exper_H] = ttest2(naiveHighLick, expertHighLick);
[~,pNaive_exper_L] = ttest2(naiveLowLick, expertLowLick);
%% Plot
%Hit
figure;
% Generate example data
categories = {'Naive - High', 'Naive - Low', 'Expert - High', 'Expert - Low'};
colors = [highColor; lowColor; highColor; lowColor;];  % Optional custom colors

% Call the function
violinplot_with_mean_single_side(lickData, categories, colors, 1, 0);
ylabel('First lick latency (S)')

disp(['Pnaive = ' num2str(pNaive) ', Pexpert = ' num2str(pExpert) '; P_naive_expert_H = ' num2str(pNaive_exper_H) ', P_naive_expert_L = ' num2str(pNaive_exper_L)]) 
title([num2str(size(allMiceData,2)) ' mice, N = ' num2str(length(H_RT)) ' sessions'])
end



