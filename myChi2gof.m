function [p, chi2, df] = myChi2gof(observedVals, expectedRate)

n = sum(observedVals);
E_vals = expectedRate.*n;
df = length(observedVals)-1;
chi2 = 0;
for i = 1:length(observedVals)
    chi2 = chi2 + (((observedVals(i) - E_vals(i)).^2)./E_vals(i));
end
p = 1-chi2cdf(chi2, df);

% % Create a contingency table of your data
% observed_data = [naiveOneOdorResponse.*length(activityMat_High(naiveInds)) expertOneOdorResponse.*length(activityMat_High(expertInds)); ...
%     naiveTwoOdorResponse.*length(activityMat_High(naiveInds)) expertTwoOdorResponse.*length(activityMat_High(expertInds))]; % Replace a, b, c, d, e, f with your actual observed frequencies
% 
% % Perform the chi-squared test
% [h,p,stats] = chi2gof(double(observed_data), 'ctable');
% 
% % Display the results
% fprintf('Chi-squared statistic: %f\n', stats.chi2stat);
% fprintf('p-value: %f\n', p);
% 
% if h == 0
%     disp('Fail to reject the null hypothesis. No significant difference.');
% else
%     disp('Reject the null hypothesis. Significant difference detected.');
% end


