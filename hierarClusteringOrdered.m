function [T, H] = hierarClusteringOrdered(clusteringInput, compMethod)

concateMatrices = clusteringInput.auROCmat.concatenatedMatrices;
if strcmpi(compMethod, 'PCA')
    %% PCA
    [~,score,~, ~,explained] = pca(concateMatrices);
    numOfPCs = 3;
    % ---------Var explanied------------
    figure;
    hold on
    yyaxis left
    bar(explained)
    ylim([0 100])
    ylabel('Individual PC variance explained')
    
    yyaxis right
    plot(1:numel(explained), cumsum(explained), 'o-', 'MarkerFaceColor', 'r')
    
    h = gca;
    h.YAxis(2).Limits = [0 100];
    % h.YAxis(2).Color = h.YAxis(1).Color;
    h.YAxis(2).TickLabel = strcat(h.YAxis(2).TickLabel, '%');
    ylabel('CDF');xlabel('Principal components');
    set(gca, 'FontSize', 15);box off;
    
    dataForDsitanceMatrix = score(:,1:numOfPCs);
    
    
else% Perform clustering on the auROC data without PCA
    
    dataForDsitanceMatrix = concateMatrices;
end
    %% Compute the distances, and build the tree
    D = pdist(dataForDsitanceMatrix,'euclidean');
    tree = linkage(D,'complete');
    leafOrder = optimalleaforder(tree,D);
    propOfMaxDistance = 0.3;
    C=propOfMaxDistance*max(tree(:,3));
    T = cluster(tree,'cutoff',C,'Criterion','distance');


%% Plot
figure

subplot(1,4,4)
[H,~,outperm] = dendrogram(tree,size(concateMatrices,1),'ColorThreshold',C,'Orientation','right','reorder',leafOrder);
set(gca,'yticklabel',[])
set(gca,'ytick',[])
hold on;
plot([C C], [0 size(concateMatrices,1)], 'k--')
title(['Th is ' num2str(propOfMaxDistance) ' of max dist.;  = ' num2str(C)])



subplot(1,4,3)
pcaData=dataForDsitanceMatrix(outperm,:);
pcaData(end+1,end+1)=NaN;
k=pcolor(pcaData);
set(k,'EdgeColor','none');
title('PCA');xlabel('PCs');
set(gca, 'FontSize', 15);box off;

subplot(1,4,1)
high_auROC_mat=clusteringInput.auROCmat.high;
high_auROC_mat_ordered=high_auROC_mat(outperm,:);
% WRo(end+1,end+1)=NaN;
h=pcolor(clusteringInput.auROCmat.timeBins, 1:size(high_auROC_mat_ordered,1), high_auROC_mat_ordered); 
hold all
% plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
% plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
set(gca,'YAxisLocation','left');
set(h,'EdgeColor','none');
ylabel('Neurons')
xlabel('time (sec)')
title('High')
caxis([0.2 1])
colorbar
set(gca, 'FontSize', 15);box off;


subplot(1,4,2)
low_auROC_mat=clusteringInput.auROCmat.low;
low_auROC_mat_ordered=low_auROC_mat(outperm,:);
% WRo(end+1,end+1)=NaN;
h=pcolor(clusteringInput.auROCmat.timeBins, 1:size(low_auROC_mat_ordered,1), low_auROC_mat_ordered); 
hold all
% plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
% plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
set(gca,'YAxisLocation','left');
set(h,'EdgeColor','none');
ylabel('Neurons')
xlabel('time (sec)')
title('Low')
caxis([0.2 1])
colorbar
set(gca, 'FontSize', 15);box off;




% subplot(1,2,1)
% A=concateMatrices(outperm,:);
% A(end+1,end+1)=NaN;
% k=pcolor(A);
% set(k,'EdgeColor','none');
% title('Concat matrix');xlabel('Time ');ylabel('Neurons')
% set(gca, 'FontSize', 15);box off;
% colormap(bone)


