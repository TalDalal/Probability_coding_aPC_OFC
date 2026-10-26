function [y_pred] = regressionAnalysis(x_train, y_train, x_new)
% Training data
% x_train = [1, 2, 3, 4, 5];
% y_train = [2.2, 4.1, 5.9, 8.0, 10.1];
% x_new = [6, 7, 8];

% Build the regression model and get coefficients
b = regressionModel(x_train, y_train);

% Predict for new data

y_pred = predictRegression(b, x_new);

% Display predictions
disp('Predicted values for new data:');
disp(table(x_new', y_pred, 'VariableNames', {'X', 'Y_Predicted'}));


    function y_pred = predictRegression(b, x_new)
        % Ensure x_new is a column vector
        x_new = x_new(:);
        
        % Predict y values
        y_pred = b(1) + b(2) * x_new;
    end


    function b = regressionModel(x, y)
        % Ensure inputs are column vectors
        x = x(:); % Convert x to a column vector
        y = y(:); % Convert y to a column vector
        
        % Validate input lengths
        if length(x) ~= length(y)
            error('Input vectors x and y must have the same length.');
        end
        
        % Perform linear regression
        X = [ones(length(x), 1), x]; % Design matrix for linear regression
        b = X \ y; % Coefficients (intercept and slope)
        
        % Plot the data and regression line
        y_fit = X * b; % Fitted values
        figure;
        scatter(x, y, 'filled', 'MarkerFaceColor', [0.2, 0.6, 0.8]);
        hold on;
        plot(x, y_fit, 'r-', 'LineWidth', 2);
        xlabel('X', 'FontSize', 14);
        ylabel('Y', 'FontSize', 14);
        title('Linear Regression', 'FontSize', 16);
        legend('Data', 'Regression Line', 'Location', 'Best');
        grid on;
        hold off;
        
        % Display results
        fprintf('Regression Coefficients:\n');
        fprintf('Intercept (b0): %.4f\n', b(1));
        fprintf('Slope (b1): %.4f\n', b(2));
    end
end
