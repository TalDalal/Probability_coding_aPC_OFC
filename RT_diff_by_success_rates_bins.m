function [] = RT_diff_by_success_rates_bins(allMiceData, numGroupedSessions, criterionTH, analyzeM)

% numGroupedSessions = this atgument is for plotting by session number and
% not performance.
% criterionTH = success rate criterion

if nargin < 4
    analyzeM = [];
end

SR = [];lickOnset_H_L = [];session_ind = [];mouseNumIndex = [];LickOnset_M = [];
for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    
    for recInd = 1:size(allRecs,2)
        
        if allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
            
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                
                lickOnset_H_L(end+1,:) = [mean(allRecs(recInd).data.firstLickLatency.A) mean(allRecs(recInd).data.firstLickLatency.C)];
                
                
            else
                
                lickOnset_H_L(end+1,:) = [mean(allRecs(recInd).data.firstLickLatency.C) mean(allRecs(recInd).data.firstLickLatency.A)];
                
                
            end
            if ~isempty(analyzeM) & ~isempty(allRecs(recInd).data.firstLickLatency.B)
                LickOnset_M(end+1,:) = mean(allRecs(recInd).data.firstLickLatency.B);
            elseif ~isempty(analyzeM)
                LickOnset_M(end+1,:) = nan;
            end
            SR(end+1) = mean([allRecs(recInd).data.successRate.C allRecs(recInd).data.successRate.A]);
            
            session_ind(end+1) = allRecs(recInd).sessionNum;
            
            mouseNumIndex(end+1) = mouseInd;
            
            
        end
    end
    
end

%  plotReactionTimes(session_ind, lickOnset_H_L)
% plotGroupedReactionTimes(session_ind, lickOnset_H_L, 2)
plotGroupedReactionTimesAndSuccess(session_ind, lickOnset_H_L,SR, numGroupedSessions, criterionTH)

plot_RT_vs_success_rate(lickOnset_H_L, SR, LickOnset_M)
end
%%
function plotGroupedReactionTimesAndSuccess(sessions, rtMatrix, successRates, k,criterionTH)

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green
% Default grouping parameter
if nargin < 4
    k = 2; % Default to grouping every 2 sessions
end

% Validate input
if length(sessions) ~= size(rtMatrix, 1) || length(sessions) ~= length(successRates)
    error('The number of sessions must match the number of rows in rtMatrix and the length of successRates.');
end

% Get unique session numbers
uniqueSessions = unique(sessions);

% Initialize arrays for means, SEMs, and p-values
numGroups = ceil((length(uniqueSessions) - 1) / k) + 1; % +1 for the first session separately
meanRT_H = zeros(numGroups, 1);
meanRT_L = zeros(numGroups, 1);
semRT_H = zeros(numGroups, 1);
semRT_L = zeros(numGroups, 1);
meanSuccess = zeros(numGroups, 1);
semSuccess = zeros(numGroups, 1);
pValues = zeros(numGroups, 1); % Store p-values for statistical significance
groupLabels = cell(numGroups, 1);

% Process the first session separately
firstSessionIdx = sessions == uniqueSessions(1);
condHData = rtMatrix(firstSessionIdx, 1);
condLData = rtMatrix(firstSessionIdx, 2);
successData = successRates(firstSessionIdx);

meanRT_H(1) = mean(condHData);
semRT_H(1) = std(condHData) / sqrt(length(condHData));
meanRT_L(1) = mean(condLData);
semRT_L(1) = std(condLData) / sqrt(length(condLData));
meanSuccess(1) = mean(successData);
semSuccess(1) = std(successData) / sqrt(length(successData));
[~, pValues(1)] = ttest(condHData, condLData); % Paired t-test for first session
groupLabels{1} = sprintf('%d', uniqueSessions(1));

% Process the remaining sessions in groups of k
groupIdx = 2;
for i = 2:k:length(uniqueSessions)
    if i + k - 1 <= length(uniqueSessions)
        sessionRange = uniqueSessions(i:i + k - 1);
    else
        sessionRange = uniqueSessions(i:end); % Last group may have fewer than k sessions
    end
    
    sessionIdx = ismember(sessions, sessionRange);
    
    % Condition H
    condHData = rtMatrix(sessionIdx, 1);
    meanRT_H(groupIdx) = mean(condHData);
    semRT_H(groupIdx) = std(condHData) / sqrt(length(condHData));
    
    % Condition L
    condLData = rtMatrix(sessionIdx, 2);
    meanRT_L(groupIdx) = mean(condLData);
    semRT_L(groupIdx) = std(condLData) / sqrt(length(condLData));
    
    % Success rates
    successData = successRates(sessionIdx);
    meanSuccess(groupIdx) = mean(successData);
    semSuccess(groupIdx) = std(successData) / sqrt(length(successData));
    
    % Paired t-test
    [~, pValues(groupIdx)] = ttest(condHData, condLData);
    
    % Set group label
    groupLabels{groupIdx} = sprintf('%d-%d', sessionRange(1), sessionRange(end));
    groupIdx = groupIdx + 1;
end

% Plotting
figure;

% Subplot for success rates
subplot(3,1,1);
errorbar_patch(1:numGroups, meanSuccess', semSuccess');
hold on;
plot([1 numGroups], [criterionTH criterionTH], 'k--')
plot([1 numGroups], [0.5 0.5], 'k--')
%     xlabel('Session Group');
ylabel('Success rate');
%     title('Success Rates');
%     set(gca, 'XTick', 1:numGroups, 'XTickLabel', groupLabels, 'XTickLabelRotation', 45);
hold off;set(gca, 'FontSize', 18);box off;ylim([0 1]);set(gca, 'XTickLabel', []);


% Subplot for reaction times
subplot(3,1,2:3);
hold on;
errorbar(1:numGroups, meanRT_H, semRT_H, '-o', 'DisplayName', 'H', 'LineWidth', 1.5, 'Color', highProbColor);
errorbar(1:numGroups, meanRT_L, semRT_L, '-o', 'DisplayName', 'L', 'LineWidth', 1.5, 'Color', lowProbColor);
xlabel('Session group');
ylabel('Reaction time (s)');
%     title('Reaction time');
set(gca, 'XTick', 1:numGroups, 'XTickLabel', groupLabels, 'XTickLabelRotation', 45);
legend('show');

% Annotate plot with significance stars
for j = 1:numGroups
    if pValues(j) < 0.001
        text(j, max(meanRT_H(j) + semRT_H(j), meanRT_L(j) + semRT_L(j)) * 1.05, '* * *', 'FontSize', 18, 'HorizontalAlignment', 'center');
    elseif pValues(j) < 0.01
        text(j, max(meanRT_H(j) + semRT_H(j), meanRT_L(j) + semRT_L(j)) * 1.05, '* *', 'FontSize', 18, 'HorizontalAlignment', 'center');
    elseif pValues(j) < 0.05
        text(j, max(meanRT_H(j) + semRT_H(j), meanRT_L(j) + semRT_L(j)) * 1.05, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    
end
hold off;set(gca, 'FontSize', 18);box off;
end

function [] = plot_RT_vs_success_rate(lickOnset_H_L, SR, LickOnset_M)
mFlag = ~isempty(LickOnset_M);
SR_bins = .5:.1:1;

for ind = 1:length(SR_bins)-1
    
    currPerformance = find(SR >= SR_bins(ind) & SR < SR_bins(ind+1));
    if mFlag
        currMeanRT(:,ind) = [mean(lickOnset_H_L(currPerformance,:))' ; nanmean(LickOnset_M(currPerformance))];
        currMeanSE(:,ind) = [(std(lickOnset_H_L(currPerformance,:))./sqrt(length(currPerformance)))' ; nanstd(LickOnset_M(currPerformance))./sqrt(length(currPerformance))];
    else
        currMeanRT(:,ind) = mean(lickOnset_H_L(currPerformance,:))';
        currMeanSE(:,ind) = (std(lickOnset_H_L(currPerformance,:))./sqrt(length(currPerformance)))';
    end
    %stat
    [~,pRTperSRbin_H_vs_L(ind)] = ttest(lickOnset_H_L(currPerformance,1), lickOnset_H_L(currPerformance,2));
%     [~,pRTperSRbin_LvsM(ind)] = ttest2(lickOnset_H_L(currPerformance,2), LickOnset_M(currPerformance));
    N_per_bin(ind) = length(currPerformance);
    
    performanceLabels{ind} = sprintf('%d-%d', SR_bins(ind).*100, SR_bins(ind+1).*100);
    
end
currMeanRT(3,1) = nan;
lowProbColor = [171,62,143]./255;%purple
mediumColor = [38, 48, 110]./255;
highProbColor = [0,169,137]./255;%green

figure;
errorbar(1:length(SR_bins)-1, currMeanRT(1,:), currMeanSE(1,:), '-o', 'DisplayName', 'H', 'LineWidth', 1.5, 'Color', highProbColor);
hold all
errorbar(1:length(SR_bins)-1, currMeanRT(2,:), currMeanSE(2,:), '-o', 'DisplayName', 'L', 'LineWidth', 1.5, 'Color', lowProbColor);
if mFlag
   errorbar(1:length(SR_bins)-1, currMeanRT(3,:), currMeanSE(3,:), '-o', 'DisplayName', 'M', 'LineWidth', 1.5, 'Color', mediumColor);
end 
xlabel('Perfromance (%)');
ylabel('Reaction time (sec)');
set(gca, 'XTick', 1:length(SR_bins), 'XTickLabel', performanceLabels, 'XTickLabelRotation', 45);
legend('show');

if mFlag
reaction_times = currMeanRT(:,3:end)';

% Convert data to table
T = array2table(reaction_times, 'VariableNames', {'A', 'B', 'M'});

% Define the within-subject design (Condition is a factor with 3 levels)
WithinDesign = table({'A'; 'B'; 'M'}, 'VariableNames', {'Condition'});

% Define repeated measures model: the response variables (A, B, M) have no predictor (intercept only)
rm = fitrm(T, 'A-M ~ 1', 'WithinDesign', WithinDesign);

% Run repeated-measures ANOVA
ranova_result = ranova(rm);

% Show the result
disp(ranova_result);

multcompare(rm, 'Condition')
end

% Plot a line for each mouse
% totalNumMice = unique(mouseNumIndex);
% for miceInd = 1:length(totalNumMice)
%     currMouseRTs = [];
%     currMouseInds = find(mouseNumIndex==totalNumMice(miceInd));
%     
%     currMouseSRs = SR(currMouseInds);
%     currMouse_allRTs = lickOnset_H_L(currMouseInds,:);
%     for ind = 1:length(SR_bins)-1
%         currMouseBin = find(currMouseSRs >= SR_bins(ind) & currMouseSRs < SR_bins(ind+1));
%         if length(currMouseBin) > 1
%             currMouseRTs(:,ind) = mean(currMouse_allRTs(currMouseBin,:))';
%         else
%             currMouseRTs(:,ind) = mean(currMouse_allRTs(currMouseBin,:),1)';
%         end
%     end
%     plot(1:length(SR_bins)-1, currMouseRTs(1,:), 'LineWidth', .5, 'Color', highProbColor)
%     plot(1:length(SR_bins)-1, currMouseRTs(2,:), 'LineWidth', .5, 'Color', lowProbColor)
% end


% Annotate plot with significance stars
for j = 1:length(pRTperSRbin_H_vs_L)
    if pRTperSRbin_H_vs_L(j) < 0.001
        text(j, max(currMeanRT(1,j) + currMeanSE(1,j), currMeanRT(2,j) + currMeanSE(2,j)) * 1.05, '* * *', 'FontSize', 18, 'HorizontalAlignment', 'center');
    elseif pRTperSRbin_H_vs_L(j) < 0.01
        text(j, max(currMeanRT(1,j) + currMeanSE(1,j), currMeanRT(2,j) + currMeanSE(2,j)) * 1.05, '* *', 'FontSize', 18, 'HorizontalAlignment', 'center');
    elseif pRTperSRbin_H_vs_L(j) < 0.05
        text(j, max(currMeanRT(1,j) + currMeanSE(1,j), currMeanRT(2,j) + currMeanSE(2,j)) * 1.05, '*', 'FontSize', 18, 'HorizontalAlignment', 'center');
    end
    
end
hold off;set(gca, 'FontSize', 18);box off;
end




