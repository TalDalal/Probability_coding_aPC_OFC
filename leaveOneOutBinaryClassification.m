function [successRate, stdDev] = leaveOneOutBinaryClassification(data, labels, numIterations)
    numDataPoints = length(data);
    successCount = 0;

    for i = 1:numIterations
        testIndex = randi(numDataPoints);
        testData = data(testIndex);
        testLabel = labels(testIndex);

        % Remove the test data point from the dataset
        trainingData = data([1:testIndex-1, testIndex+1:end]);
        trainingLabels = labels([1:testIndex-1, testIndex+1:end]);

        % Compute centroids for each group
        centroid0 = mean(trainingData(trainingLabels == 0));
        centroid1 = mean(trainingData(trainingLabels == 1));

        % Calculate Euclidean distances
        dist0 = abs(testData - centroid0);
        dist1 = abs(testData - centroid1);

        % Assign the label based on the closest centroid
        if dist0 < dist1
            predictedLabel = 0;
        else
            predictedLabel = 1;
        end

        % Check if the predicted label matches the actual label
        if predictedLabel == testLabel
            successCount = successCount + 1;
        end
    end

    successRate = successCount / numIterations;
    stdDev = sqrt(successRate * (1 - successRate) / numIterations);
    clc
end

