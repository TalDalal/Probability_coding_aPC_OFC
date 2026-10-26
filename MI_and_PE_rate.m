% function [] = MI_and_PE_rate(csPlus_H_L_fr, csMinus_H_L_fr, csPlus_response_and_modulated, csMinus_response_and_modulated)

%%-------------------------------- CS+ ------------------------
%%  ------ H vs L
H_L_CSplus_PE_FR = csPlus_H_L_fr(:,find(csPlus_response_and_modulated > 0));

MI_csPlus_H_vs_L = abs((H_L_CSplus_PE_FR(1,:) - H_L_CSplus_PE_FR(2,:))./(H_L_CSplus_PE_FR(1,:) + H_L_CSplus_PE_FR(2,:)));


%% ----- H vs M
csPlus_response_and_modulated_H_vs_M = context_modulation_matrix_CSplus(:,2)'.*csPlusResponses;

H_vs_M_CSplus_PE_FR = [csPlus_H_L_fr(1,find(csPlus_response_and_modulated_H_vs_M > 0)) ; ...
    csPlus_B_fr(find(csPlus_response_and_modulated_H_vs_M > 0))];

MI_csPlus_H_vs_M = abs((H_vs_M_CSplus_PE_FR(1,:) - H_vs_M_CSplus_PE_FR(2,:))./(H_vs_M_CSplus_PE_FR(1,:) + H_vs_M_CSplus_PE_FR(2,:)));

%% ----- M vs L
csPlus_response_and_modulated_M_vs_L = context_modulation_matrix_CSplus(:,3)'.*csPlusResponses;

M_vs_L_CSplus_PE_FR = [csPlus_H_L_fr(2,find(csPlus_response_and_modulated_M_vs_L > 0)) ; ...
    csPlus_B_fr(find(csPlus_response_and_modulated_M_vs_L > 0))];

MI_csPlus_M_vs_L = abs((M_vs_L_CSplus_PE_FR(1,:) - M_vs_L_CSplus_PE_FR(2,:))./(M_vs_L_CSplus_PE_FR(1,:) + M_vs_L_CSplus_PE_FR(2,:)));

%%--------------------------------------------- CS- ------------------------------

%% H vs L
H_L_CSminus_PE_FR = csMinus_H_L_fr(:,find(csMinus_response_and_modulated > 0));
MI_csMinus_H_vs_L = abs((H_L_CSminus_PE_FR(1,:) - H_L_CSminus_PE_FR(2,:))./(H_L_CSminus_PE_FR(1,:) + H_L_CSminus_PE_FR(2,:)));

%% ----- H vs M
csMinus_response_and_modulated_H_vs_M = context_modulation_matrix_CSminus(:,2)'.*csMinusResponses;

H_vs_M_CSminus_PE_FR = [csMinus_H_L_fr(1,find(csMinus_response_and_modulated_H_vs_M > 0)) ; ...
    csMinus_B_fr(find(csMinus_response_and_modulated_H_vs_M > 0))];

MI_csMinus_H_vs_M = abs((H_vs_M_CSminus_PE_FR(1,:) - H_vs_M_CSminus_PE_FR(2,:))./(H_vs_M_CSminus_PE_FR(1,:) + H_vs_M_CSminus_PE_FR(2,:)));

%% ----- M vs L
csMinus_response_and_modulated_M_vs_L = context_modulation_matrix_CSminus(:,3)'.*csMinusResponses;

M_vs_L_CSMinus_PE_FR = [csMinus_H_L_fr(2,find(csMinus_response_and_modulated_M_vs_L > 0)) ; ...
    csMinus_B_fr(find(csMinus_response_and_modulated_M_vs_L > 0))];

MI_csMinus_M_vs_L = abs((M_vs_L_CSMinus_PE_FR(1,:) - M_vs_L_CSMinus_PE_FR(2,:))./(M_vs_L_CSMinus_PE_FR(1,:) + M_vs_L_CSMinus_PE_FR(2,:)));


%% plot

prediction_diff_25_MI = [MI_csPlus_H_vs_M MI_csPlus_M_vs_L MI_csMinus_H_vs_M MI_csMinus_M_vs_L];
prediction_diff_50_MI = [MI_csPlus_H_vs_L MI_csMinus_H_vs_L];


figure;
barwitherr([std(prediction_diff_50_MI)./sqrt(length(prediction_diff_50_MI)) std(prediction_diff_25_MI)./sqrt(length(prediction_diff_25_MI))], ...
    [mean(prediction_diff_50_MI) mean(prediction_diff_25_MI)]);
set(gca, 'FontSize', 18);box off;title('CS-')
set(gca, 'XTickLabel', {'50%', '25%'});xlabel('Error magnitude');ylabel(' Firing rate Modulation index')
title('Firing rate modulation for different levels of error')
