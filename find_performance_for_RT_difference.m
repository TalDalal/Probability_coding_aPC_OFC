function [firstRTdiff_SR] = find_performance_for_RT_difference(mouseData)
% Plot the learning curve per mouse
probExpCounter = 0;pretrainCounter = 0;sessionNumPretrain = [];
analyzeBodor = 0;% include B (50%) trials
successRateCriterion = 0.7;


highColor = [0,169,137]./255;%green
BColor = [2,0,121]./255;%blue
lowColor = [171,62,143]./255;%purple

for recInd = 1:size(mouseData.allRecs,2)
    
    if mouseData.allRecs(recInd).sessionNum > 0
        probExpCounter = probExpCounter + 1;
        
        
        SR(probExpCounter) = mean([mouseData.allRecs(recInd).data.successRate.A mouseData.allRecs(recInd).data.successRate.C]);
        
        currH_RTs = mouseData.allRecs(recInd).data.firstLickLatency.C;
        currL_RTs = mouseData.allRecs(recInd).data.firstLickLatency.A;
        
        
%         [signifRTdiff(probExpCounter),~] = ttest2(currH_RTs, currL_RTs);
        [p] = permutation_test(currH_RTs', currL_RTs');
        if p < 0.05
            signifRTdiff(probExpCounter) = 1;
        else
            signifRTdiff(probExpCounter) = 0;
        end
        sessionNum(probExpCounter) = mouseData.allRecs(recInd).sessionNum;
        
    end
end


%------------ PLOT Prob. Exp DATA-------

%Sort the data by the session number (according to training days)
[~, sessNumInds] = sort(sessionNum);
sortedSRs = SR(sessNumInds);
sortedRTdiff = signifRTdiff(sessNumInds);

firstRTdiff_SR = sortedSRs(find(sortedRTdiff > 0,1));


end

function p = permutation_test(x, y, n_perm)
    if nargin < 3
        n_perm = 10000; % Default number of permutations
    end
    
    % Compute observed difference in means
    obs_diff = mean(x) - mean(y);
    
    % Pool data
    pooled = [x; y];
    n_x = length(x);
    n_y = length(y);
    
    % Permutation procedure
    perm_diffs = zeros(n_perm, 1);
    for i = 1:n_perm
        perm_indices = randperm(length(pooled));
        perm_x = pooled(perm_indices(1:n_x));
        perm_y = pooled(perm_indices(n_x+1:n_x+n_y));
        perm_diffs(i) = mean(perm_x) - mean(perm_y);
    end
    
    % Compute p-value (two-tailed test)
    p = mean(abs(perm_diffs) >= abs(obs_diff));
end


