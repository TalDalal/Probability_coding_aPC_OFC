function [] = hierarchClusteringROC(allRecsStruct, periodToSort, timeWinToCluster, auROCWinSize, trialOutcome)

if nargin < 5
    trialOutcome = [];
end

leafOrderFlag = 1;

%% A
[allAuROCtracesA, ROCvalsPeriodToSort, timeBins, originalPSTH] = createAuROCMatrix(allRecsStruct,auROCWinSize, 'Atrials', periodToSort, trialOutcome);
%Sort the auROC responses
[~,locs] = sort(ROCvalsPeriodToSort, 'descend');

%% C
[allAuROCtracesC, ~] = createAuROCMatrix(allRecsStruct,auROCWinSize, 'Ctrials', periodToSort, trialOutcome);

%% plot the matrices sorted by the firing rate in the 'periodToSort' window.
params = allRecsStruct(1).data;
figure;
subplot(1,2,1)
imagesc(timeBins,1:length(allAuROCtracesA), allAuROCtracesA(locs,:))
caxis([0.2 1])
hold all
%first odor
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')

%second odor 
plot(zeros(1,2), [size(allAuROCtracesA,1)  1], 'k--')
plot((params.odor_duration.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
set(gca, 'FontSize', 15);box off;
xlabel('Time (sec)');ylabel('Neurons')
title('H - auROC')
xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
colormap('bone')
% colorbar

subplot(1,2,2)
imagesc(timeBins,1:length(allAuROCtracesC), allAuROCtracesC(locs,:))
caxis([0.2 1])
hold all
%first odor
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')

%second odor
plot(zeros(1,2), [size(allAuROCtracesC,1)  1], 'k--')
plot((params.odor_duration.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')
set(gca, 'FontSize', 15);box off;
xlabel('Time (sec)');ylabel('Neurons')
title('L - auROC')
xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
colormap(flipud(bone))
ylabel('')
set(gca, 'YTickLabel', '')
colorbar

%% Concate matrices
%Data before the behavioral decision of the animal
clusteringIndices = find(timeBins >= timeWinToCluster(1) & timeBins < timeWinToCluster(2));
trimmedAllAuROCtracesA = allAuROCtracesA(:,clusteringIndices);
trimmedAllAuROCtracesC = allAuROCtracesC(:,clusteringIndices);
concateMatrices = [trimmedAllAuROCtracesA trimmedAllAuROCtracesC];

%% Hierarchical clustering

if leafOrderFlag
    %Clustering including leaf orderingclc
    [orderedClustersInds, linesColor] = hierarClusteringOrdered(concateMatrices, 'auROC');
    %Plot the clusters PSTHs
    plotClusters(orderedClustersInds, originalPSTH, linesColor)
else
    % no leaf ordering and have to set max # clusters
    [T] = hierarClusteringNonOrderedMaxClusterTH(allAuROCtracesA, allAuROCtracesC, score, numOfPCs, maxClusters);
end

