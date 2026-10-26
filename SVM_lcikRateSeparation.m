minNumTrials = min(length(params.firstLickLatency.A), length(params.firstLickLatency.C));
for reps = 1:100
    
    ArandInds = randsample(length(params.firstLickLatency.A), minNumTrials);
    CrandInds = randsample(length(params.firstLickLatency.C), minNumTrials);
    
    feature1 = [params.firstLickLatency.A(ArandInds)'; params.firstLickLatency.C(CrandInds)']; % Feature 1
    feature2 = [params.anticipitoryLickRate.A(ArandInds)'; params.anticipitoryLickRate.C(CrandInds)']; % Feature 2
    classLabel = [zeros(minNumTrials, 1); ones(minNumTrials, 1)]; % Class labels (0 and 1)
    
    % Combine the features into a matrix
    X = [feature1, feature2];
    
    % Split the data into training (70%) and testing sets (30%)
    cv = cvpartition(classLabel, 'HoldOut', 0.3);
    XTrain = X(training(cv), :);
    yTrain = classLabel(training(cv));
    XTest = X(test(cv), :);
    yTest = classLabel(test(cv));
    
    % Train a Support Vector Machine (SVM) classifier
    SVMModel = fitcsvm(XTrain, yTrain, 'KernelFunction', 'linear', 'Standardize', true);
    
    % Make predictions on the test set
    yPred = predict(SVMModel, XTest);
    
    % Evaluate the performance using accuracy
    accuracy = sum(yPred == yTest) / length(yTest) * 100;
    fprintf('Accuracy: %.2f%%\n', accuracy);
    
    allAccuracyRates(reps) = accuracy;
end
mean(allAccuracyRates)
% Plot the decision boundary
d = 0.02; % Step size for the grid
[x1Grid, x2Grid] = meshgrid(min(X(:, 1)):d:max(X(:, 1)), min(X(:, 2)):d:max(X(:, 2)));
xGrid = [x1Grid(:), x2Grid(:)];
[~, scores] = predict(SVMModel, xGrid);

% Plot the data
figure;
gscatter(X(:, 1), X(:, 2), classLabel, 'rb', 'ox');
hold on;
% Plot the decision boundary
contour(x1Grid, x2Grid, reshape(scores(:, 2), size(x1Grid)), [0, 0], 'k');
title('SVM Classification with Decision Boundary');
xlabel('Feature 1');
ylabel('Feature 2');
legend('Class 0', 'Class 1', 'Decision Boundary');
hold off;
