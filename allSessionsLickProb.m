function [] = allSessionsLickProb(allMiceData)

lickSmoothKernel = 0.07;
highLickRaster_Hit = [];lowLickRaster_Hit = [];
highLickRaster_FA = [];lowLickRaster_FA = [];

for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    
    for recInd = 1:size(allRecs,2)
        
        
        if allRecs(recInd).sessionNum > 0 & ...
                allRecs(recInd).data.successRate.A > .6 & ...
                allRecs(recInd).data.successRate.C > .6 % ONLY experiment sessions and not pretraining
            
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                %Hit
                highLickRaster_Hit = [highLickRaster_Hit  allRecs(recInd).data.LickRaster.hit.A];
                lowLickRaster_Hit = [lowLickRaster_Hit  allRecs(recInd).data.LickRaster.hit.C];
                %FA
                highLickRaster_FA = [highLickRaster_FA  allRecs(recInd).data.LickRaster.FA.A];
                lowLickRaster_FA = [lowLickRaster_FA  allRecs(recInd).data.LickRaster.FA.C];
            else
                %Hit
                highLickRaster_Hit = [highLickRaster_Hit  allRecs(recInd).data.LickRaster.hit.C];
                lowLickRaster_Hit = [lowLickRaster_Hit  allRecs(recInd).data.LickRaster.hit.A];
                %FA
                highLickRaster_FA = [highLickRaster_FA  allRecs(recInd).data.LickRaster.FA.C];
                lowLickRaster_FA = [lowLickRaster_FA  allRecs(recInd).data.LickRaster.FA.A];
            end
            
            
        end
    end
    
end
%% plot

highColor = [0,169,137]./255;%green
lowColor = [171,62,143]./255;%purple

%Hit
figure;
hold all;
mypsth(highLickRaster_Hit, lickSmoothKernel, highColor);
mypsth(lowLickRaster_Hit, lickSmoothKernel, lowColor);
set(gca, 'FontSize', 18);box off;xlabel('Time relative to CS+ (S)');ylabel('Lick rate (Hz)')

%FA
figure;
hold all;
mypsth(highLickRaster_FA, lickSmoothKernel, highColor);
mypsth(lowLickRaster_FA, lickSmoothKernel, lowColor);
set(gca, 'FontSize', 18);box off;xlabel('Time relative to CS+ (S)');ylabel('Lick rate (Hz)')