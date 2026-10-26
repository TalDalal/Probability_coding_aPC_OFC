clear;clc
load('allRecs_M3_PC_tetrodes.mat')

allAuROCtraces = [];
% waitWin = [-0.4 0];
waitWin = [-1, 0];
allWaitPeriodROCvals = [];
c = 0;
for recInd = 1:size(allRecs,2)
    params = allRecs(recInd).data;
    
    bgWin = [-params.odor_duration-params.ISIbetweenOdors-2000 ...
        -params.odor_duration-params.ISIbetweenOdors]./1000;
    fgTrials = params.Atrials;
    
    for unitInd = 1:size(params.firingRates,2)
        c = c+1;
        currFRmat = params.firingRates(unitInd).firingRateByBIn;
        

        [auROC, timeBins] = compute_auROC(params, currFRmat, bgWin, fgTrials, 300);
        
        allAuROCtraces(end+1,:) = auROC;
        
        allWaitPeriodROCvals(end+1) = mean(auROC(find(timeBins >= waitWin(1) & timeBins < waitWin(2))));
    end
end
%Sort the auROC responses
[~,locs] = sort(allWaitPeriodROCvals, 'descend');
%% Hie. clustreing
%Data before the behavioral decision of the animal
beforeDecisionIndices = find(timeBins >= -3 & timeBins < 0);
trimmedAllAuROCtraces = allAuROCtraces(:,beforeDecisionIndices);
%PCA
[coeff,score,latent] = pca(trimmedAllAuROCtraces);
%Linkage analysis
numOfPCs = 3;
tree = linkage(score(:,1:numOfPCs),'complete','euclidean');
cutoff = 1.2;
% plot
figure;

subplot(1,3,1)
imagesc(timeBins,1:length(allAuROCtraces), allAuROCtraces(locs,:))
caxis([0 1])
hold all
%first odor
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtraces,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtraces,1)  1], 'k--')

%second odor
plot(zeros(1,2), [size(allAuROCtraces,1)  1], 'k--')
plot((params.odor_duration.*ones(1,2))./1000, [size(allAuROCtraces,1)  1], 'k--')
set(gca, 'FontSize', 15);box off;
xlabel('Times (sec)');ylabel('Neurons')
title('auROC')
xlim([bgWin(1)+1 0.2])
colormap('default')
colorbar


subplot(1,3,2)
imagesc(score(locs,1:numOfPCs))
colormap('default')
% caxis([-3 3])
title('score')
colorbar
set(gca, 'FontSize', 15);box off;
xlabel('PCs');


subplot(1,3,3)
[h,T] = dendrogram(tree,0,'ColorThreshold',cutoff,'Orientation','right');


