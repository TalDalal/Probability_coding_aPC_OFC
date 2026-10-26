function [] = percent_task_related_activity_modulation(allMiceData, pValueTH, analysisTimeWin)

lowColor = [171,62,143]./255;%purple
highColor = [0,169,137]./255;%green
CSplusColor = [153 51 51]./255;
CSminusColor = [153 102 51]./255;

% Compute the binary response matrix for each odor
% col1: H, col2: L, col3: CS+, col4: CS-
[taskResponsiveNeuronsMat] = computeBinaryResponseMatrix(allMiceData, pValueTH, analysisTimeWin);

% Plot % response bar graphs for exc and inh
colorMatrix = [highColor;lowColor;CSplusColor;CSminusColor];
plotOnesAndMinusOnesPercentageWithError(taskResponsiveNeuronsMat, colorMatrix)


plotActiveNeuronsWithSigns(taskResponsiveNeuronsMat)
end
function [taskResponsiveNeuronsMat] = computeBinaryResponseMatrix(allMiceData, pValueTH, analysisTimeWin)
c = 0;

%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            
            Atrials = mouseData(recInd).data.Atrials;
            Ctrials = mouseData(recInd).data.Ctrials;
                        
            CS_plus_trials = [mouseData(recInd).data.targetTrials.A mouseData(recInd).data.targetTrials.B mouseData(recInd).data.targetTrials.C];
            CS_minus_trials = [mouseData(recInd).data.tMinusTrials.A mouseData(recInd).data.tMinusTrials.B mouseData(recInd).data.tMinusTrials.C];
            

            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;

            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;

                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= analysisTimeWin(1,1) & timeBins < analysisTimeWin(1,2));
                firstOdorDuration = find(timeBins >= analysisTimeWin(2,1) & timeBins < analysisTimeWin(2,2));
                CSDuration = find(timeBins >= analysisTimeWin(3,1) & timeBins < analysisTimeWin(3,2));
                
                %---------------------- Predicting odors --------------------------
                taskResponsiveNeuronsMat(c,:) = nan(1,4);
                
                Amat = currFRmat(Atrials,:);
                Cmat = currFRmat(Ctrials,:);
                
                %Baseline
                bgFR = mean(currFRmat(:,baselineDuration),2);
                
                % first Odor
                firstOdorFR_A = mean(Amat(:,firstOdorDuration),2);
                [h_A,~] = ttest2(bgFR, firstOdorFR_A, 'alpha', pValueTH);
                if mean(firstOdorFR_A) < mean(bgFR)
                    h_A = h_A*-1;
                end
                
                firstOdorFR_C = mean(Cmat(:,firstOdorDuration),2);
                [h_C,~] = ttest2(bgFR, firstOdorFR_C, 'alpha', pValueTH);
                if mean(firstOdorFR_C) < mean(bgFR)
                    h_C = h_C*-1;
                end
                
                %Check if this odor was H or L
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    taskResponsiveNeuronsMat(c,1) = h_A; taskResponsiveNeuronsMat(c,2) = h_C;
                else
                    taskResponsiveNeuronsMat(c,1) = h_C; taskResponsiveNeuronsMat(c,2) = h_A;
                end
                
                
                % CS + Odor
                csPlusOdorFR = mean(currFRmat(CS_plus_trials,CSDuration),2);
                [h,~] = ttest2(bgFR, csPlusOdorFR, 'alpha', pValueTH);
                if mean(csPlusOdorFR) < mean(bgFR)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat(c,3) = h;
                
                % CS - Odor
                csMinusOdorFR = mean(currFRmat(CS_minus_trials,CSDuration),2);
                [h,~] = ttest2(bgFR, csMinusOdorFR, 'alpha', pValueTH);
                if mean(csMinusOdorFR) < mean(bgFR)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat(c,4) = h;
                
            end
        end
    end
end
%Avoid nans
taskResponsiveNeuronsMat(isnan(taskResponsiveNeuronsMat)) = 0;
taskResponsiveNeuronsMat(isnan(taskResponsiveNeuronsMat)) = 0;
end



function plotOnesAndMinusOnesPercentageWithError(binaryMatrix, colorMatrix)
    % Validate input matrix
    if ~ismatrix(binaryMatrix) || ~all(ismember(binaryMatrix(:), [-1, 0, 1]))
        error('Input matrix must contain only -1, 0, and 1 values');
    end
    
    % Validate color matrix
    [numRows, numCols] = size(binaryMatrix);
    if ~ismatrix(colorMatrix) || size(colorMatrix, 1) ~= numCols || size(colorMatrix, 2) ~= 3
        error('Color matrix must be an Nx3 matrix with RGB values for each column');
    end
    
    % Calculate the percentage of 1's in each column
    percentOnes = sum(binaryMatrix == 1) / numRows * 100;
    
    % Calculate the percentage of -1's in each column
    percentMinusOnes = sum(binaryMatrix == -1) / numRows * 100;
    
    % Calculate standard error for 1's
    pOnes = percentOnes / 100;  % Convert to probability
    standardErrorOnes = sqrt(pOnes .* (1 - pOnes) / numRows) * 100;  % Convert back to percentage
    
    % Calculate standard error for -1's
    pMinusOnes = percentMinusOnes / 100;  % Convert to probability
    standardErrorMinusOnes = sqrt(pMinusOnes .* (1 - pMinusOnes) / numRows) * 100;  % Convert back to percentage
    
    % Plot bar graph with error bars for 1's
    figure;
    subplot(1, 2, 1);
    b1 = bar(1:numCols, percentOnes, 'FaceColor', 'flat');  % Enable custom colors
    hold on;
    errorbar(1:numCols, percentOnes, standardErrorOnes, 'k', 'LineStyle', 'none');
    hold off;
    xlabel('Columns');
    ylabel('Active neurons (%)');
    title('Excitation');
    ylim([0, 50]);  % Limit y-axis to 0-50%
    set(gca, 'FontSize', 18); box off;
    set(gca, 'XTickLabel', {'H', 'L', 'CS+', 'CS-'});
    % Apply colors from colorMatrix to each bar
    for i = 1:numCols
        b1.CData(i, :) = colorMatrix(i, :);  % Set color for each bar
    end
    
    % Plot bar graph with error bars for -1's
    subplot(1, 2, 2);
    b2 = bar(1:numCols, percentMinusOnes, 'FaceColor', 'flat');  % Enable custom colors
    hold on;
    errorbar(1:numCols, percentMinusOnes, standardErrorMinusOnes, 'k', 'LineStyle', 'none');
    hold off;
    xlabel('Columns');
    ylabel('Active neurons (%)');
    title('Inhibition');
    ylim([0, 50]);  % Limit y-axis to 0-50%
    set(gca, 'FontSize', 18); box off;
    set(gca, 'XTickLabel', {'H', 'L', 'CS+', 'CS-'});
    % Apply colors from colorMatrix to each bar
    for i = 1:numCols
        b2.CData(i, :) = colorMatrix(i, :);  % Set color for each bar
    end
    
    % Perform statistical tests and add significance markers
    % For Ones (Excitation)
    [p1, stat1] = prop_test(binaryMatrix(:,1), binaryMatrix(:,2), 1);
    [p2, stat2] = prop_test(binaryMatrix(:,3), binaryMatrix(:,4), 1);
    subplot(1, 2, 1);
    hold all
    add_significance_marker(1, 2, percentOnes, p1);
    add_significance_marker(3, 4, percentOnes, p2);

    % For Minus Ones (Inhibition)
    [p3, stat3] = prop_test(binaryMatrix(:,1), binaryMatrix(:,2), -1);
    [p4, stat4] = prop_test(binaryMatrix(:,3), binaryMatrix(:,4), -1);
    subplot(1, 2, 2);
    hold all
    add_significance_marker(1, 2, percentMinusOnes, p3);
    add_significance_marker(3, 4, percentMinusOnes, p4);
end

% Helper function for two-sample proportion test
function [pValue, stat] = prop_test(column1, column2, value)
    % Count occurrences of the target value
    n1 = sum(column1 == value);
    n2 = sum(column2 == value);
    
    % Total number of samples in each column
    N1 = length(column1);
    N2 = length(column2);
    
    % Perform z-test for two proportions
    phat1 = n1 / N1;
    phat2 = n2 / N2;
    phat_pooled = (n1 + n2) / (N1 + N2);
    z = (phat1 - phat2) / sqrt(phat_pooled * (1 - phat_pooled) * (1/N1 + 1/N2));
    pValue = 2 * (1 - normcdf(abs(z)));  % Two-tailed test
    stat = z;
end

% Helper function to add significance markers
function add_significance_marker(col1, col2, percentData, pValue)
    if pValue < 0.05
        % Plot asterisk and display p-value if significant
        y = max([percentData(col1), percentData(col2)]) + 5;
        plot([col1, col2], [y, y], 'k-', 'LineWidth', 1.5);
        text(mean([col1, col2]), y + 2, '*', 'HorizontalAlignment', 'center', 'FontSize', 18, 'Color', 'k');
        text(mean([col1, col2]), y + 4, sprintf('p=%.3f', pValue), 'HorizontalAlignment', 'center', 'FontSize', 10, 'Color', 'k');
    end
end


function plotActiveNeuronsWithSigns(matrix)
    % Input validation
    [N, numOdors] = size(matrix);
    if numOdors ~= 4
        error('Input matrix must be of size N x 4');
    end

    % --- Subplot 1: Absolute Values ---
    absMatrix = abs(matrix);  % Convert to absolute values (1 if active, 0 if inactive)
    rowSumsAbs = sum(absMatrix, 2);  % Sum of each row in absolute matrix

    % Calculate percentages for each count of active odors (0 to 4) in absolute matrix
    maxOdors = numOdors;
    percentagesAbs = zeros(1, maxOdors + 1); % Include category for zero active responses
    for k = 0:maxOdors
        percentagesAbs(k + 1) = sum(rowSumsAbs == k) / N * 100;
    end

    % Binomial error bars for absolute matrix
    errorsAbs = sqrt((percentagesAbs / 100) .* (1 - percentagesAbs / 100) / N) * 100;

    % --- Subplot 2: Positive and Negative Values ---
    posMatrix = matrix == 1;  % Binary matrix for positive values (1 for positives, 0 otherwise)
    negMatrix = matrix == -1; % Binary matrix for negative values (1 for negatives, 0 otherwise)

    % Sum rows for positive and negative matrices
    rowSumsPos = sum(posMatrix, 2);
    rowSumsNeg = sum(negMatrix, 2);

    % Calculate percentages for each count of positive and negative values (0 to 4)
    percentagesPos = zeros(1, maxOdors + 1); % Include category for zero active responses
    percentagesNeg = zeros(1, maxOdors + 1);
    for k = 0:maxOdors
        percentagesPos(k + 1) = sum(rowSumsPos == k) / N * 100;
        percentagesNeg(k + 1) = sum(rowSumsNeg == k) / N * 100;
    end

    % Binomial error bars for positive and negative matrices
    errorsPos = sqrt((percentagesPos / 100) .* (1 - percentagesPos / 100) / N) * 100;
    errorsNeg = sqrt((percentagesNeg / 100) .* (1 - percentagesNeg / 100) / N) * 100;

    % --- Plotting ---
    figure;

    % Subplot 1: Absolute values
    subplot(1, 2, 1);
    errorbar(0:maxOdors, percentagesAbs, errorsAbs, 'o-', 'MarkerSize', 6, 'LineWidth', 1.5);
    xlabel('Number of Effective Odors', 'FontSize', 14);
    ylabel('Active Neurons (%)', 'FontSize', 14);
    xlim([-0.5, maxOdors + 0.5]);
    ylim([0, 100]);
    xticks(0:maxOdors);
    title('All Active Neurons', 'FontSize', 16);
    grid on;

    % Subplot 2: Positive and Negative values
    subplot(1, 2, 2);
    errorbar(0:maxOdors, percentagesPos, errorsPos, 'o-', 'MarkerSize', 6, 'LineWidth', 1.5, 'DisplayName', 'Exc');
    hold on;
    errorbar(0:maxOdors, percentagesNeg, errorsNeg, 's-', 'MarkerSize', 6, 'LineWidth', 1.5, 'DisplayName', 'Inh');
    hold off;
    xlabel('Number of Effective Odors', 'FontSize', 14);
    ylabel('Active Neurons (%)', 'FontSize', 14);
    xlim([-0.5, maxOdors + 0.5]);
    ylim([0, 100]);
    xticks(0:maxOdors);
    legend('show', 'Location', 'best');
    title('Active Neurons (Exc vs. Inh)', 'FontSize', 16);
    grid on;
end
