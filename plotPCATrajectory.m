function [mahalDist, dimPerTime, varExplained] = plotPCATrajectory(neuralData, timeVector, refTimeRange)
    % Function to plot PCA trajectory of neural data with time-based color coding
    % and lines connecting points
    %
    % Inputs:
    %   neuralData - A matrix of Neurons x Time, where each entry is the
    %                firing rate within a 200ms bin.
    %   timeVector - A vector representing the time corresponding to each column in neuralData.
    %
    % Example:
    %   neuralData = rand(100, 50); % Example data
    %   timeVector = linspace(0, 10, 50); % Time in seconds
    %   plotPCATrajectory(neuralData, timeVector);

    % Validate inputs
    if isempty(neuralData) || ~ismatrix(neuralData)
        error('Input neuralData must be a non-empty matrix of size Neurons x Time.');
    end
    if length(timeVector) ~= size(neuralData, 2)
        error('timeVector must have the same length as the number of columns in neuralData.');
    end

    % Perform PCA
    [coeff, score, latent, ~, explained] = pca(neuralData', 'Centered', true); % Time x Neurons for PCA

    % Extract the first three PCs
    pc1 = score(:, 1);
    pc2 = score(:, 2);
    pc3 = score(:, 3);
    
    % Variance explained by PC1 + PC2
    varExplained = sum(explained(1:2));  % in percent
    
    % Find indices for reference time range
    refIdx = timeVector >= refTimeRange(1) & timeVector <= refTimeRange(2);
    
    % Compute reference mean and covariance
    refData = [pc1(refIdx), pc2(refIdx) ];
    mu_ref = mean(refData, 1);
    Sigma_ref = cov(refData);
    
    % Compute Mahalanobis distance for all time points
    allData = [pc1, pc2];
    mahalDist = sqrt(sum((allData - mu_ref) / Sigma_ref .* (allData - mu_ref), 2));
    
    
    % Compute dimensionality at each time point (PCs explaining 80% variance)
    cumulativeVariance = cumsum(latent) / sum(latent);
    dimPerTime = arrayfun(@(t) find(cumulativeVariance >= 0.8, 1), 1:length(timeVector));
    
    


    % Create a color map for the time points
    cmap = jet(length(timeVector)); % Use jet colormap
%     figure;
    hold on;

    % Plot lines connecting points, with color-coding
    for i = 1:length(timeVector) - 1
        % Use the current and next time point's color for smooth transition
        plot3(pc1(i:i+1), pc2(i:i+1), pc3(i:i+1), '-', 'Color', cmap(i, :), 'LineWidth', 1.5);
    end

    % Overlay scatter points
    scatter3(pc1, pc2, pc3, 36, timeVector, 'filled'); % Color-coded points
    colormap(jet); % Use the jet colormap for smooth color transitions
    colorbar; % Add a color bar
    c = colorbar;
    c.Label.String = 'Time relative to CS (sec)'; % Label the color bar

    % Customize the plot
    xlabel('PC1', 'FontSize', 12);
    ylabel('PC2', 'FontSize', 12);
    zlabel('PC3', 'FontSize', 12);
%     title('Trajectory in Principal Component Space', 'FontSize', 14);
%     grid on;
    set(gca, 'FontSize', 10);
    axis tight;

    % Enhance the view
%     view(3); % Set a 3D view
    view(0, 90)
    hold off;
end
 
%function plotPCATrajectory(neuralData, timeVector)
%     % Function to plot PCA trajectory of neural data with time-based color coding
%     %
%     % Inputs:
%     %   neuralData - A matrix of Neurons x Time, where each entry is the
%     %                firing rate within a 200ms bin.
%     %   timeVector - A vector representing the time corresponding to each column in neuralData.
%     %
%     % Example:
%     %   neuralData = rand(100, 50); % Example data
%     %   timeVector = linspace(0, 10, 50); % Time in seconds
%     %   plotPCATrajectory(neuralData, timeVector);
% 
%     % Validate inputs
%     if isempty(neuralData) || ~ismatrix(neuralData)
%         error('Input neuralData must be a non-empty matrix of size Neurons x Time.');
%     end
%     if length(timeVector) ~= size(neuralData, 2)
%         error('timeVector must have the same length as the number of columns in neuralData.');
%     end
% 
%     % Perform PCA
%     [coeff, score, ~] = pca(neuralData', 'Centered', true); % Time x Neurons for PCA
% 
%     % Extract the first three PCs
%     pc1 = score(:, 1);
%     pc2 = score(:, 2);
%     pc3 = score(:, 3);
% 
%     % Create 3D trajectory plot with color coding
%     figure;
%     scatter3(pc1, pc2, pc3, 36, timeVector, 'filled'); % Color points by time
%     colormap(jet); % Use the jet colormap for smooth color transitions
%     colorbar; % Add a color bar
%     c = colorbar;
%     c.Label.String = 'Time relative to CS (sec)'; % Label the color bar
% 
%     % Customize the plot
%     xlabel('PC1', 'FontSize', 12);
%     ylabel('PC2', 'FontSize', 12);
%     zlabel('PC3', 'FontSize', 12);
%     title('Trajectory in Principal Component Space', 'FontSize', 14);
%     grid on;
%     set(gca, 'FontSize', 10);
%     axis tight;
% 
%     % Enhance the view
%     view(3); % Set a 3D view
% end



