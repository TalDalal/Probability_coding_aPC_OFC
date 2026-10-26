function [allRecs] = readXLSPassiveOdors(fileName)
passiveOdorDirName = 'passive_odor_stimulation';
if ismac
    workingDir = '/Volumes/My Passport/Tal/Experiments/2022/Behavior_Probability/head_fixed/data/';
else
    workingDir = 'F:\Experiments\2022\Behavior_Probability\head_fixed\data\';
end
[num, Raw] = xlsread([workingDir passiveOdorDirName '/' fileName]);

%% Assign params
Raw(1,:) = [];
[recordingDirs,loc] = unique(Raw(:,6));
unitID = Raw(loc,5);
labViewFileName = Raw(loc,7);
recDates = Raw(loc,2);
brainRegion = Raw(loc,3);
if ismac
    sessionNum = num(loc,13);
else
    sessionNum = num(loc,11);
end
%% Run over all recording days and generate the file mat containing the data
for recInd = 1:length(recordingDirs)
    
    % get into the directory
    if ismac
        macRecDir = recordingDirs{recInd};
        macRecDir(strfind(macRecDir,'\'))='/';
        cd([workingDir macRecDir])
    else
        cd([workingDir recordingDirs{recInd}])
    end
    
    
    [params]=analyzePassiveOdorsExp(labViewFileName{recInd}, unitID{recInd});
    close all;
    
    
    allRecs(recInd).data = params;
    allRecs(recInd).date = recDates(recInd);
    allRecs(recInd).brainRegion = brainRegion(recInd);
    allRecs(recInd).sessionNum = sessionNum(recInd);
    
end
%% save
generalFileName = ['allRecs_PassiveOdorStimulation_' fileName];
cd([workingDir '/' passiveOdorDirName])
save(generalFileName, 'allRecs')
