function [] = neuralHierarchClustering(allMiceData, bgPeriod, timeWinToCluster, auROCWinSize, trialType, periodToSort)

% transform the data into auROC (normalization)
[allAuROCtraces_high, allAuROCtraces_low, ~, timeBins, originalPSTH] = ...
    high_low_auROC_matrix(allMiceData,bgPeriod,auROCWinSize, periodToSort, trialType);

%% Concate matrices

%Data before the behavioral decision of the animal
clusteringIndices = find(timeBins >= timeWinToCluster(1) & timeBins < timeWinToCluster(2));
trimmedAllAuROCtraces_high = allAuROCtraces_high(:,clusteringIndices);
trimmedAllAuROCtraces_low = allAuROCtraces_low(:,clusteringIndices);
concateMatrices = [trimmedAllAuROCtraces_high trimmedAllAuROCtraces_low];

% imput
clusteringInput.auROCmat.high = allAuROCtraces_high;
clusteringInput.auROCmat.low = allAuROCtraces_low;
clusteringInput.auROCmat.concatenatedMatrices = concateMatrices;
clusteringInput.auROCmat.timeBins = timeBins;

%% Hierarchical clustering
leafOrderFlag = 1;
if leafOrderFlag
    %Clustering including leaf ordering
    [orderedClustersInds, linesColor] = hierarClusteringOrdered(clusteringInput, 'PCA');
    %Plot the clusters PSTHs
    plotClustersPSTHs(orderedClustersInds, originalPSTH, linesColor, timeWinToCluster)
else
    % no leaf ordering and have to set max # clusters
    [T] = hierarClusteringNonOrderedMaxClusterTH(allAuROCtracesA, allAuROCtracesC, score, numOfPCs, maxClusters);
end

