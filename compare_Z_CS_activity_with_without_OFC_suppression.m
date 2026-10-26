function [] = compare_Z_CS_activity_with_without_OFC_suppression(allMiceData, allMiceData_OFC_SILENCING,  bgPeriod, fgPeriod)

[CSplus_control] = Z_scored_CS_firing_rates(allMiceData, bgPeriod, fgPeriod, 'CS+');
[CSplus_OFC] = Z_scored_CS_firing_rates(allMiceData_OFC_SILENCING, bgPeriod, fgPeriod, 'CS+');

[CSminus_control] = Z_scored_CS_firing_rates(allMiceData, bgPeriod, fgPeriod, 'CS-');
[CSminus_OFC] = Z_scored_CS_firing_rates(allMiceData_OFC_SILENCING, bgPeriod, fgPeriod, 'CS-');


%%
%Divide to exc and inh
excData{1} = CSplus_control(find(CSplus_control(:,1) > 0),1);
excData{2} = CSplus_OFC(find(CSplus_OFC(:,1) > 0),1);
excData{3} = CSminus_control(find(CSminus_control(:,1) > 0),1);
excData{4} = CSminus_OFC(find(CSminus_OFC(:,1) > 0),1);

inhData{1} = CSplus_control(find(CSplus_control(:,1) < 0),1);
inhData{2} = CSplus_OFC(find(CSplus_OFC(:,1) < 0),1);
inhData{3} = CSminus_control(find(CSminus_control(:,1) < 0),1);
inhData{4} = CSminus_OFC(find(CSminus_OFC(:,1) < 0),1);


%% Stat
%EXC
[~,pExc_CSplus] = ttest2(excData{1}, excData{2});
[~,pExc_CSminus] = ttest2(excData{3}, excData{4});
%Expert
[~,pInh_CSplus] = ttest2(inhData{1}, inhData{2});
[~,pInh_CSminus] = ttest2(inhData{3}, inhData{4});

%naive vs expert
% [~,pNaive_expert_csPlus_Exc] = ttest2(excData{1}, excData{3});
% [~,pNaive_expert_cMinus_Exc] = ttest2(excData{2}, excData{4});
% 
% [~,pNaive_expert_csPlus_Inh] = ttest2(inhData{1}, inhData{3});
% [~,pNaive_expert_cMinus_Inh] = ttest2(inhData{2}, inhData{4});

disp(['pExc_CSplus = ' num2str(pExc_CSplus) '; pExc_CSminus = ' num2str(pExc_CSminus) '; pInh_CSplus = ' num2str(pInh_CSplus) '; pInh_CSminus = ' num2str(pInh_CSminus)])
%%
figure;
subplot(1,2,1)
title('Excitation')
CSplusColor = [154,52,52]./255;
CSminusColor = [153,102,51]./255;

categories = {'control - CS+', 'OFC suppressed - CS+', 'control - CS-', 'OFC suppressed - CS-'};
colors = [CSplusColor; CSplusColor ; CSminusColor; CSminusColor];  % Optional custom colors

violinplot_with_mean_single_side(excData, categories, colors, 1, 0);
ylabel('Firing rate (Z-score)');

subplot(1,2,2)
title('Inhibition')
CSplusColor = [154,52,52]./255;
CSminusColor = [153,102,51]./255;

violinplot_with_mean_single_side(inhData, categories, colors, 1, 0);
ylabel('Firing rate (Z-score)');

