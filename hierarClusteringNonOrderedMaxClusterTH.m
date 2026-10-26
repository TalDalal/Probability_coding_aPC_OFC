function [T] = hierarClusteringNonOrderedMaxClusterTH(allAuROCtracesA, allAuROCtracesC, score, numOfPCs, maxClusters)


tree = linkage(score(:,1:numOfPCs),'complete','euclidean');
propOfMaxDistance = 0.3;
cutoff = max(tree(:,3))*propOfMaxDistance;
maxClusters = 7;
T = cluster(tree,'maxclust',maxClusters);
[sortClusID, sortedClusterInd] = sort(T);


%% plot
figure;

subplot(1,4,4)
[~,~,leafInd] = dendrogram(tree,0,'ColorThreshold',cutoff,'Orientation','right');
title(['Cutoff: ' num2str(cutoff)])
leafInd = fliplr(leafInd);
hold all;
plot([cutoff cutoff], [0 size(allAuROCtracesA,1)], 'k--')
title(['Th is ' num2str(propOfMaxDistance) ' of max dist.;  = ' num2str(cutoff)])


subplot(1,4,1)
imagesc(timeBins,1:length(allAuROCtracesA), allAuROCtracesA(leafInd,:))
caxis([0.2 1])
hold all
%first odor
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')

%second odor
plot(zeros(1,2), [size(allAuROCtracesA,1)  1], 'k--')
plot((params.odor_duration.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
set(gca, 'FontSize', 15);box off;
xlabel('Times (sec)');ylabel('Neurons')
title('A - auROC')
xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
colormap('default')
colorbar

subplot(1,4,2)
imagesc(timeBins,1:length(allAuROCtracesC), allAuROCtracesC(leafInd,:))
caxis([0.2 1])
hold all
%first odor
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')

%second odor
plot(zeros(1,2), [size(allAuROCtracesC,1)  1], 'k--')
plot((params.odor_duration.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')
set(gca, 'FontSize', 15);box off;
xlabel('Times (sec)');%ylabel('Neurons')
title('C - auROC')
xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
colormap('default')
colorbar

subplot(1,4,3)
imagesc(score(leafInd,1:numOfPCs))
colormap('default')
% caxis([-3 3])
title('PCA')
colorbar
set(gca, 'FontSize', 15);box off;
xlabel('PCs');

% %% Plot the clusters
% Acolor = 'r';
% Ccolor = 'm';
% figure
% % suptitle('Clusters PSTHs')
% for ind = 1:length(unique(T))
%     subplot(2,4,ind)
%     k=ind;
%     hold all
%     %     plot(trimmedAllAuROCtracesA(find(T==k),:)', 'b')
%     currTracesA = trimmedAllAuROCtracesA(find(T==k),:);
%     if size(currTracesA,1) == 1
%         plot(timeBins(clusteringIndices), currTracesA)
%     else
%         errorbar_patch(timeBins(clusteringIndices), mean(currTracesA), std(currTracesA)./sqrt(size(currTracesA,1)),Acolor)
%     end
%     
%     % C trials
%     currTracesC = trimmedAllAuROCtracesC(find(T==k),:);
%     if size(currTracesC,1) == 1
%         plot(timeBins(clusteringIndices), currTracesC)
%     else
%         hold all
%         errorbar_patch(timeBins(clusteringIndices),mean(currTracesC),std(currTracesC)./sqrt(size(currTracesC,1)),Ccolor)
%         title(['Cluster ' num2str(ind) '; N = ' num2str(length(find(T==k)))])
%     end
%     
%     %first odor
%     plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [0.5  .6], 'k--')
%     plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [.5  .6], 'k--')
%     %Second odor
%     plot(zeros(1,2), [0.5  .6], 'k--')
%     plot((params.odor_duration.*ones(1,2))./1000, [0.5  0.6], 'k--')
%     xlim([timeWinToCluster(1)-.5 timeWinToCluster(2) + .5])
% 
%     if ind==1
%         legend('A (0=.75%)', '','C (0=.25%)')
%     end
%     set(gca, 'FontSize', 14);box off;
%     xlabel('Time (sec)');ylabel('auROC')
%     
% end