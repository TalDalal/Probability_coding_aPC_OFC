function [AUC] = auROC_TwoDistributions(dist0, dist1, plotFlag)
% Concatenate scores and create corresponding labels (1 for distribution 1, 0 for distribution 2)
scores = [dist0; dist1];
labels = [ones(length(dist0), 1); zeros(length(dist1), 1)];
% 
% mdl = fitglm(scores,labels,'Distribution','binomial','Link','logit');   
% scores = mdl.Fitted.Probability;

% Compute ROC curve
[FPR, TPR, ~, AUC] = perfcurve(labels, scores, 1);

% Plot ROC curve
if plotFlag
    figure;
    plot(FPR, TPR)
    xlabel('False Positive Rate (FPR)');
    ylabel('True Positive Rate (TPR)');
    legend(['AUC = ' num2str(AUC, '%.4f')]);
end

