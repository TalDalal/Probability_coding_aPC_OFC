clear;clc;
%% load
mouseNum = 'M1_PC_tetrodes';
if ismac
    workingDir = '/Volumes/My Passport/Tal/Experiments/2022/Behavior_Probability/head_fixed/data/';
else
    workingDir = 'F:\Tal\Experiments\2022\Behavior_Probability\head_fixed\data\';
end
load(['allRecs_' mouseNum])
%%
for ind = 1:size(allRecs,2)
    for TTind = 1:size(allRecs(ind).data.allRasterPlots,2)

        %Plot behavior
        labViewFileName = allRecs(ind).data.fullFileName;
        READ_PROB_EXP(labViewFileName, 'Head-fixed', allRecs(ind).data.lickTh);
        
        %TT number
        currTT = allRecs(ind).data.allRasterPlots(TTind).data(1).info;
        
        % Plot the spiking activity
        allRecs(ind).data.PSTHsAndRasters = [];
        [params] = plotSpikesByBehavior(allRecs(ind).data, currTT);
        
        
        %Save the summary figure (only PSTHs)
        cd([workingDir '/' mouseNum '/examples'])
        saveas(gcf, [allRecs(ind).date{:} '_' currTT '_'  num2str(TTind) '.jpg'])
        close;
        
        %save the raster plots in sub figures
        dirName = ['Session # ' num2str(allRecs(ind).sessionNum) '_' allRecs(ind).date{:} '_' currTT];
        mkdir(dirName)
        cd(dirName);
        for saveInd = 1:4
            saveas(gcf, [dirName  '_' num2str(saveInd) '_'  allRecs(ind).brainRegion{:} '.jpg'])
            close;
        end
    end
end