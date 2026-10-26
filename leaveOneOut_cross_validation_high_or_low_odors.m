function [successRate, confusionMatrix] = leaveOneOut_cross_validation_high_or_low_odors(data, labels, numIterations)
    numDataPoints = size(data,1);
    successCount = 0;
    confusionMatrix = zeros(2,2);
    allTestsLabels = nan(1, numIterations);
    
    distFunction = 'euclidean';
    
    for i = 1:numIterations
        testIndex = randi(numDataPoints);
        testData = data(testIndex,:);
        testLabel = labels(testIndex);
        allTestsLabels(i) = testLabel;

        % Remove the test data point from the dataset
        trainingData = data([1:testIndex-1, testIndex+1:end],:);
        trainingLabels = labels([1:testIndex-1, testIndex+1:end]);

        % Compute centroids for each group
        centroid0 = (mean(trainingData(trainingLabels == 0,:)));
        centroid1 = (mean(trainingData(trainingLabels == 1,:)));
        
        switch distFunction
            case 'euclidean'
                
                % Calculate Euclidean distances
                dist0 = sqrt(sum((testData - centroid0) .^ 2));%mean(abs(testData - centroid0));
                dist1 = sqrt(sum((testData - centroid1) .^ 2));%mean(abs(testData - centroid1));
                
                
                % Assign the label based on the closest centroid
                if dist0 < dist1
                    predictedLabel = 0;
                else
                    predictedLabel = 1;
                end
                
            case 'correlation'
                [r0,~] = corr(testData', centroid0');
                [r1,~] = corr(testData', centroid1');
                
                if r0 > r1
                    predictedLabel = 0;
                else
                    predictedLabel = 1;
                end
                
                
        end


        % Check if the predicted label matches the actual label
        if predictedLabel == testLabel
            successCount = successCount + 1;
            
            %Update the condusion matrix
            if predictedLabel == 0
                confusionMatrix(2,2) = confusionMatrix(2,2)+1;
            else
                confusionMatrix(1,1) = confusionMatrix(1,1)+1;
            end
        else
            if predictedLabel == 0
                confusionMatrix(2,1) = confusionMatrix(2,1)+1;
            else
                confusionMatrix(1,2) = confusionMatrix(1,2)+1;
            end
        end
        

    end
    
    %Norm the confusion matrix
    confusionMatrix(:,1) = confusionMatrix(:,1)./length(find(allTestsLabels==1));
    confusionMatrix(:,2) = confusionMatrix(:,2)./length(find(allTestsLabels==0));
    

    successRate = successCount / numIterations;
    stdDev = sqrt(successRate * (1 - successRate) / numIterations);
%     clc
end

