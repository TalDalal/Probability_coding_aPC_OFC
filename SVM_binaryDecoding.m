function [accuracy, percentVec] = SVM_binaryDecoding(data, labels, plotFlag)
% SVM Binary Classification Example with Training and Test Sets

percentOfData = 20;
increment = percentOfData./100;
accuracy = nan(1,100/percentOfData);
percentVec = 1:percentOfData:100;
for percentInd = 1:(100./percentOfData)
    
    r = datasample(1:size(data,1),floor(size(data,1)*increment*percentInd),'Replace',true);
    X = data(r);
    y = labels(r);
    num_observations = size(X,1);
    
    % Step 2: Partition the data into a training set and a test set
    cv = cvpartition(num_observations, 'HoldOut', 0.2); % 80% training, 20% test
    
    X_train = X(training(cv), :);
    y_train = y(training(cv), :);
    
    X_test = X(test(cv), :);
    y_test = y(test(cv), :);
    
    % Step 3: Train the SVM classifier
    svmModel = fitcsvm(X_train, y_train, 'KernelFunction', 'linear', 'Standardize', true);
    
    % Step 4: Predict the labels for the test set
    y_pred = predict(svmModel, X_test);
    
    % Step 5: Calculate the accuracy
    accuracy(percentInd) = sum(y_pred == y_test) / numel(y_test);
    
%     disp(['Accuracy: ', num2str(accuracy)]);
end
if plotFlag
    
    figure;
    plot(percentVec, accuracy, 'b-s');
    hold all;
    plot([0 100], [.5 .5], 'k--');
    ylim([0 1]);set(gca, 'FontSize', 14');box off;
    xlabel('% of trials used');ylabel('Accuracy');
end

