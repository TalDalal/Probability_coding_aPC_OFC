function [] = plotLickPSTHforgivenMouse(allRecs)

kernelSTD = 0.07;
CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
numSubPlots = [4 ceil(size(allRecs,2)./4)];

figure;
for recInd = 1:size(allRecs,2)
    subplot(numSubPlots(1), numSubPlots(2), recInd)
    if allRecs(recInd).sessionNum > 0
        [R,t,E] = mypsth(allRecs(recInd).data.LickRaster.hit.A, kernelSTD, 'n');
        errorbar_patch(t, R, E, AColor)
        
        
        hold on;
        [R,t,E] = mypsth(allRecs(recInd).data.LickRaster.hit.C, kernelSTD, 'n');
        errorbar_patch(t, R, E, CColor)
        xlabel('Time from CS+ (sec)');ylabel('Average number of licks');
        set(gca, 'FontSize', 14');box off;
    end
    
end