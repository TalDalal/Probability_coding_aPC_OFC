function [allRecs] = generateMatFilesForAllRecordings(mouseNum, fileName, analyzeSpikingActivity, pathForSave)
% mouseNum = 'M9_h4dmGi_OFC_PC_tetrodes'
% fileName = 'unitsDescription_final_M9'
% analyzeSpikingActivity = 1;
%% load the xls
%Example: mouseNum = 'M9'
%mouseNum = '/unitsDescription_final_M9'
%analyzeSpikingActivity = IF WE RUN ONLY BEHAVIOR WITHOUT RECORDING
%See example on how to build the xls file to be compatible in one of the
%directories in the path.

if nargin  < 4
    pathForSave = [];
end
if ismac
    workingDir = '/Volumes/Tal`s disk/Experiments/2022/Behavior_Probability/head_fixed/data/';
else
    workingDir = 'E:\Tal\Experiments\2022\Behavior_Probability\head_fixed\data\';
end
[num, Raw] = xlsread([workingDir  mouseNum '/' fileName]);

%% Assign params
Raw(1,:) = [];
[recordingDirs,loc] = unique(Raw(:,6));
if ismac
    lickThArray = num(loc,7);
else
    lickThArray = num(loc,5);
end
labViewFileName = Raw(loc,7);
recDates = Raw(loc,2);
brainRegion = Raw(loc,3);

beforeAfterInjection = Raw(loc,15);

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
    
    
    if analyzeSpikingActivity %-------- WITH NEURAL RECORDING
        [params] = analyzeSingleRun(labViewFileName{recInd}, [], lickThArray(recInd), 1);
        close all;
    else
        %-------- IN CASE WE ONLY RUN BEHAVIOR, ANALYZE IT ONLY--------
        if ~isfile([labViewFileName{recInd} '.txt'])
            cd ..
        end
        [params]=READ_PROB_EXP(labViewFileName{recInd}, 'head-fixed', lickThArray(recInd));
        close all;
        
    end

    
    allRecs(recInd).data = params;
    allRecs(recInd).date = recDates(recInd);
    allRecs(recInd).brainRegion = brainRegion(recInd);
    allRecs(recInd).sessionNum = sessionNum(recInd);
    allRecs(recInd).mouseNum = mouseNum;
    
    if ~isempty(beforeAfterInjection(1))
        allRecs(recInd).beforeAfterInjection = beforeAfterInjection(recInd);
    end
    
end
%% save
generalFileName = ['allRecs_' mouseNum];

if ~isempty(pathForSave)
    cd(pathForSave)
else
    cd([workingDir mouseNum])
end
save(generalFileName, 'allRecs')

