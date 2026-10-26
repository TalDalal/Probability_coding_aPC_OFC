clear;clc
%% Prepare the data
[allTrialsMatrix_CS_plus,mouse_session_vec, minNumTrials_CS_plus] = prepareDataForCSdecoding([-3 -2], [0 1], 'CS+');
[allTrialsMatrix_CSminus,mouse_session_vec, minNumTrials_CS_minus] = prepareDataForCSdecoding([-3 -2], [0 1], 'CS-');

% Combine the matrices
High_CS_decoding_matrix = [allTrialsMatrix_CS_plus(1:minNumTrials_CS_plus,:);allTrialsMatrix_CSminus(1:minNumTrials_CS_plus,:) ];
Low_CS_decoding_matrix = [allTrialsMatrix_CS_plus(minNumTrials_CS_plus+1:end,:);allTrialsMatrix_CSminus(minNumTrials_CS_plus+1:end,:) ];

% Run the decoder
[meanSRandSTD_High, meanSRandSTD_SHUFF_High, binsVec_High] = performDecodingUsingTrialsMatrix(High_CS_decoding_matrix, 20, 100, minNumTrials_CS_plus);

[meanSRandSTD_Low, meanSRandSTD_SHUFF_Low, binsVec_Low] = performDecodingUsingTrialsMatrix(Low_CS_decoding_matrix, 20, 100, minNumTrials_CS_minus);

%% Plot
CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green

figure;
errorbar_patch(binsVec_High, meanSRandSTD_High(1,:), meanSRandSTD_High(2,:), AColor)
hold all;
errorbar_patch(binsVec_Low, meanSRandSTD_Low(1,:), meanSRandSTD_Low(2,:), CColor)

plot(binsVec_High, meanSRandSTD_SHUFF_High(1,:), '--', 'Color', AColor)
hold all;
plot(binsVec_High, meanSRandSTD_SHUFF_Low(1,:), '--', 'Color', CColor)

plot([0 binsVec_High(end)],[ 0.5 .5], 'k--')
ylim([0 1])
set(gcf, 'Renderer', 'painters');set(gca, 'FontSize', 14);box off;
xlabel('Number of neurons');ylabel('Accuracy');
xlim([0  binsVec_High(end)]);


