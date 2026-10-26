function [] = plotClustersPSTHs(orderedClustersInds, originalPSTH, linesColor, timeWinToCluster)
plotTimeWindow = [timeWinToCluster(1)-.5 timeWinToCluster(2)+.5];
deltaT = plotTimeWindow(2) - plotTimeWindow(1);
lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

%%
figure;
for clusInd = 1:length(unique(orderedClustersInds))
    currInds = find(orderedClustersInds==clusInd);
    
    allPSTHofCluster_high = [];allPSTHofCluster_low = [];

    for psthInd = 1:length(currInds)
        
        %----High----
        % The current time vec
        currTimeVec = originalPSTH(currInds(psthInd)).high(1,:);
        % Compute the bin size of the PSTH
        psthBinSize = floor((currTimeVec(end)-currTimeVec(1))*1000./(length(currTimeVec)));
        % Find the relevant indices
        firstInd = find(currTimeVec >= plotTimeWindow(1),1);
        indToPlot =  [firstInd: firstInd + deltaT*1000./psthBinSize-1];
        
        allPSTHofCluster_high(psthInd, :) = originalPSTH(currInds(psthInd)).high(2,indToPlot);
        
        currTimeVec = [];indToPlot = [];firstInd = [];

        %----Low----
        % The current time vec
        currTimeVec = originalPSTH(currInds(psthInd)).low(1,:);
        % Compute the bin size of the PSTH
        psthBinSize = floor((currTimeVec(end)-currTimeVec(1))*1000./(length(currTimeVec)));
        % Find the relevant indices
        firstInd = find(currTimeVec >= plotTimeWindow(1),1);
        indToPlot =  [firstInd: firstInd + deltaT*1000./psthBinSize-1];      
  
        allPSTHofCluster_low(psthInd, :) = originalPSTH(currInds(psthInd)).low(2,indToPlot);

        
    end
    
    if size(allPSTHofCluster_high,1) == 1
        continue
    end
    subplot(3,3,clusInd)
    errorbar_patch(currTimeVec(indToPlot),mean(allPSTHofCluster_high),std(allPSTHofCluster_high)./sqrt(size(allPSTHofCluster_high,1)),highProbColor)
    hold on;
    errorbar_patch(currTimeVec(indToPlot),mean(allPSTHofCluster_low),std(allPSTHofCluster_low)./sqrt(size(allPSTHofCluster_low,1)),lowProbColor)
    title(['Cluster ' num2str(clusInd) '; N = ' num2str(length(currInds))])%, 'Color', linesColor(currInds(1)).Color)
end


    
    
        
        
    