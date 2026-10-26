clear;clc
load('allRecs_M3_PC_tetrodes.mat')

allAuROCtracesA = [];
allAuROCtracesC = [];
allWaitPeriodROCvalsA = [];
allWaitPeriodROCvalsC = [];

waitWin = [-1, 0];
c = 0;
for recInd = 1:size(allRecs,2)
    params = allRecs(recInd).data;
    
    % baseline periof for the ROC
    bgWin = [-params.odor_duration-params.ISIbetweenOdors-2000 ...
        -params.odor_duration-params.ISIbetweenOdors]./1000;
    % fg period for the ROC
    AfgTrials = params.Atrials;
    CfgTrials = params.Ctrials;
    
    for unitInd = 1:size(params.firingRates,2)
        c = c+1;
        currFRmat = params.firingRates(unitInd).firingRateByBIn;
        %Compute the ROC for A trials
        [auROC, timeBins] = compute_auROC(params, currFRmat, bgWin, AfgTrials, 300);
        
        %for null cases
        if ~isempty(find(auROC==0))
            auROC(find(auROC==0)) = median(auROC);
        end
        allAuROCtracesA(end+1,:) = auROC;
        allWaitPeriodROCvalsA(end+1) = mean(auROC(find(timeBins >= waitWin(1) & timeBins < waitWin(2))));
        auROC = [];
        
        
        %Compute the ROC for C trials
        [auROC, timeBins] = compute_auROC(params, currFRmat, bgWin, CfgTrials, 300);
        if ~isempty(find(auROC==0))
            auROC(find(auROC==0)) = median(auROC);
        end
        allAuROCtracesC(end+1,:) = auROC;
        allWaitPeriodROCvalsC(end+1) = mean(auROC(find(timeBins >= waitWin(1) & timeBins < waitWin(2))));
        auROC = [];
        
        
    end
end
%Sort the auROC responses
[~,locs] = sort(allWaitPeriodROCvalsA, 'descend');
%% plot sorted by wait firing rate
figure;
subplot(1,2,1)
imagesc(timeBins,1:length(allAuROCtracesA), allAuROCtracesA(locs,:))
caxis([0 1])
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
xlim([bgWin(1)+1 0.2])
colormap('default')
colorbar

subplot(1,2,2)
imagesc(timeBins,1:length(allAuROCtracesC), allAuROCtracesC(locs,:))
caxis([0 1])
hold all
%first odor
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')

%second odor
plot(zeros(1,2), [size(allAuROCtracesC,1)  1], 'k--')
plot((params.odor_duration.*ones(1,2))./1000, [size(allAuROCtracesC,1)  1], 'k--')
set(gca, 'FontSize', 15);box off;
xlabel('Times (sec)');ylabel('Neurons')
title('C - auROC')
xlim([bgWin(1)+1 0.2])
colormap('default')
colorbar
%% Concate matrices
%Data before the behavioral decision of the animal
beforeDecisionIndices = find(timeBins >= -3 & timeBins < 0);
trimmedAllAuROCtracesA = allAuROCtracesA(:,beforeDecisionIndices);
trimmedAllAuROCtracesC = allAuROCtracesC(:,beforeDecisionIndices);
concateMatrices = [trimmedAllAuROCtracesA trimmedAllAuROCtracesC];

%% Hie. clustreing
%PCA
[coeff,score,latent, ~,explained] = pca(concateMatrices);
%Linkage analysis
numOfPCs = 3;
tree = linkage(score(:,1:numOfPCs),'complete','euclidean');
cutoff = 1.02;
maxClusters = 6;
T = cluster(tree,'maxclust',maxClusters);
[sortClusID, sortedClusterInd] = sort(T);

%% Var explanied
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
%% plot
figure;

subplot(1,4,4)
[~,~,leafInd] = dendrogram(tree,0,'ColorThreshold',cutoff,'Orientation','right');
title(['Cutoff: ' num2str(cutoff)])
leafInd = fliplr(leafInd);

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
xlim([bgWin(1)+1 0])
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
xlim([bgWin(1)+1 0])
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





%% Plot the clusters
Acolor = 'r';
Ccolor = 'm';
figure
suptitle('Clusters PSTHs')
for ind = 1:length(unique(T))
    subplot(2,4,ind)
    k=ind;
    hold all
    %     plot(trimmedAllAuROCtracesA(find(T==k),:)', 'b')
    currTracesA = trimmedAllAuROCtracesA(find(T==k),:);
    if size(currTracesA,1) == 1
        plot(timeBins(beforeDecisionIndices), currTracesA)
    else
        errorbar_patch(timeBins(beforeDecisionIndices), mean(currTracesA), std(currTracesA)./sqrt(size(currTracesA,1)),Acolor)
    end
    
    % C trials
    currTracesC = trimmedAllAuROCtracesC(find(T==k),:);
    if size(currTracesC,1) == 1
        plot(timeBins(beforeDecisionIndices), currTracesC)
    else
        hold all
        errorbar_patch(timeBins(beforeDecisionIndices),mean(currTracesC),std(currTracesC)./sqrt(size(currTracesC,1)),Ccolor)
        title(['Cluster ' num2str(ind) '; N = ' num2str(length(find(T==k)))])
    end
    %     ylim([0.5 0.8])
    plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [0.3  1], 'k--')
    plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [.3  1], 'k--')
    if ind==1
        legend('A (0=.75%)', '','C (0=.25%)')
    end
    set(gca, 'FontSize', 14);box off;
    xlabel('Time (sec)');ylabel('auROC')
    
end



