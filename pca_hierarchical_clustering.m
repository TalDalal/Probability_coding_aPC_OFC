% Input: matrix X (each column is a time series)
% K: number of clusters

function [clusterLabels, Z, T] = pca_hierarchical_clustering(X, K)

    % Step 1: Standardize the data (zero mean, unit variance)
    X_std = zscore(X);

    % Step 2: Perform PCA
    [coeff, score, ~, ~, explained] = pca(X_std);  % coeff: eigenvectors, score: transformed data
    
    % Optional: decide how many principal components to retain
    cumulativeExplained = cumsum(explained);
    numComponents = find(cumulativeExplained >= 95, 1); % Retain 95% variance
    
    % Step 3: Use the reduced dimensionality data (score) for clustering
    reducedData = score(:, 1:numComponents);

    % Step 4: Perform hierarchical clustering
    % Calculate the pairwise distances
    distanceMatrix = pdist(reducedData);  

    % Create hierarchical cluster tree
    Z = linkage(distanceMatrix, 'ward');  % 'ward' linkage minimizes the variance

    % Step 5: Form K clusters from the hierarchical tree
    T = cluster(Z, 'maxclust', K);

    % Output the cluster labels
    clusterLabels = T;

    % Step 6: Plotting (Optional)
    figure;
    subplot(1,2,1);
    plot(cumulativeExplained);
    title('Explained Variance by Components');
    xlabel('Number of Principal Components');
    ylabel('Cumulative Explained Variance (%)');
    
    subplot(1,2,2);
    dendrogram(Z);
    title('Hierarchical Clustering Dendrogram');
    xlabel('Data Points');
    ylabel('Distance');

end
