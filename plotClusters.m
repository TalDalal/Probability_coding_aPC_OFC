function [] = plotClusters(orderedClustersInds, originalPSTH, linesColor)
requestedTimeWin = [-3 0];
deltaT = requestedTimeWin(2)-requestedTimeWin(1);
Acolor = 'r';Ccolor = 'm';
figure;
for clusInd = 1:length(unique(orderedClustersInds))
    currInds = find(orderedClustersInds==clusInd);
    
    allPSTHofClusterA = [];allPSTHofClusterC = [];
    for psthInd = 1:length(currInds)
        
        %----A----
        % The current time vec
        currTimeVec = originalPSTH(currInds(psthInd)).A(1,:);
        % Compute the bin size of the PSTH
        psthBinSize = floor((currTimeVec(end)-currTimeVec(1))*1000./(length(currTimeVec)));
        % Find the relevant indices
        indToPlot = [find(currTimeVec >= requestedTimeWin(1),1) :find(currTimeVec >= requestedTimeWin(1),1) + deltaT*1000./psthBinSize-1];
        
        allPSTHofClusterA(psthInd, :) = originalPSTH(currInds(psthInd)).A(2,indToPlot);
        
        currTimeVec = [];indToPlot = [];
        %----C----
        % The current time vec
        currTimeVec = originalPSTH(currInds(psthInd)).C(1,:);
        % Compute the bin size of the PSTH
        psthBinSize = floor((currTimeVec(end)-currTimeVec(1))*1000./(length(currTimeVec)));
        % Find the relevant indices
        indToPlot = [find(currTimeVec >= requestedTimeWin(1),1) :find(currTimeVec >= requestedTimeWin(1),1) + deltaT*1000./psthBinSize-1];
        
        allPSTHofClusterC(psthInd, :) = originalPSTH(currInds(psthInd)).C(2,indToPlot);

        
    end
    subplot(3,3,clusInd)
    errorbar_patch(currTimeVec(indToPlot),mean(allPSTHofClusterA),std(allPSTHofClusterA)./sqrt(size(allPSTHofClusterA,1)),Acolor)
    hold on;
    errorbar_patch(currTimeVec(indToPlot),mean(allPSTHofClusterC),std(allPSTHofClusterC)./sqrt(size(allPSTHofClusterC,1)),Ccolor)
    title(['Cluster ' num2str(clusInd) '; N = ' num2str(length(currInds))], 'Color', linesColor(currInds(1)).Color)
end


    
    
        
        
    