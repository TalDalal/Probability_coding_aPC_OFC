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
%% Concate matrices
%Data before the behavioral decision of the animal
beforeDecisionIndices = find(timeBins >= -3 & timeBins < 0);
trimmedAllAuROCtracesA = allAuROCtracesA(:,beforeDecisionIndices);
trimmedAllAuROCtracesC = allAuROCtracesC(:,beforeDecisionIndices);
concateMatrices = [trimmedAllAuROCtracesA trimmedAllAuROCtracesC];

numOfPCs = 3;
collect_units = concateMatrices;
[coeff,score,latent] = pca(collect_units);
PCAcollect_units=score(:,1:numOfPCs);

%%
figure
subplot(1,4,4)
D = pdist(PCAcollect_units,'euclidean');
tree = linkage(D,'complete');
leafOrder = optimalleaforder(tree,D);
propOfMaxDistance = 0.3;
C=propOfMaxDistance*max(tree(:,3));
[~,~,outperm] = dendrogram(tree,size(collect_units,1),'ColorThreshold',C,'Orientation','right','reorder',leafOrder);
set(gca,'yticklabel',[])
set(gca,'ytick',[])
hold on;
plot([C C], [0 size(collect_units,1)], 'k--')
title(['Th is ' num2str(propOfMaxDistance) ' of max dist.;  = ' num2str(C)])


subplot(1,4,3)
A=PCAcollect_units(outperm,:);
A(end+1,end+1)=NaN;
k=pcolor(A);
set(k,'EdgeColor','none');
title('PCA');xlabel('PCs');
set(gca, 'FontSize', 15);box off;

subplot(1,4,1)
WR=trimmedAllAuROCtracesA;
WRo=WR(outperm,:);
% WRo(end+1,end+1)=NaN;
h=pcolor(timeBins(beforeDecisionIndices), 1:size(WRo,1), WRo); 
hold all
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
set(gca,'YAxisLocation','left');
set(h,'EdgeColor','none');
ylabel('Neurons')
xlabel('time (sec)')
title('A - auROC')
caxis([0.25 0.95])
colorbar
set(gca, 'FontSize', 15);box off;


subplot(1,4,2)
WR=trimmedAllAuROCtracesC;
WRo=WR(outperm,:);
% WRo(end+1,end+1)=NaN;
h=pcolor(timeBins(beforeDecisionIndices), 1:size(WRo,1), WRo); 
hold on
plot((-params.odor_duration-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
plot((-params.ISIbetweenOdors.*ones(1,2))./1000, [size(allAuROCtracesA,1)  1], 'k--')
set(gca,'YAxisLocation','left');
set(h,'EdgeColor','none');
% ylabel('units')
xlabel('time (sec)')
title('C - auROC')
caxis([0.25 0.95])
colorbar
set(gca, 'FontSize', 15);box off;