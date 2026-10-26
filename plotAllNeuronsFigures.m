clear;clc;
%% load
mouseNum = 'M1_PC_tetrodes';
if ismac
    workingDir = '/Volumes/My Passport/Tal/Experiments/2022/Behavior_Probability/head_fixed/data/';
else
    workingDir = 'F:\Tal\Experiments\2022\Behavior_Probability\head_fixed\data\';
end
%load the xls
[num, Raw] = xlsread([workingDir mouseNum '/unitsDescription_final_M1']);
Raw(1,:) = [];
recordingDirs = Raw(:,6);
lickThArray = num(:,7);
TTnum = Raw(:,5);
%%
for recInd = 1:length(recordingDirs)
    % get into the directory
    if ismac
        macRecDir = recordingDirs{recInd};
        macRecDir(strfind(macRecDir,'\'))='/';
        cd([workingDir macRecDir(1:end-20)])
    else
        cd([workingDir recordingDirs{recInd}(1:end-20)])
    end
    %load the data
    if recInd > 1
        if ~strcmpi(recordingDirs{recInd}, recordingDirs{recInd-1})
            dataName= ls ('*.mat');
            if ismac
                dataName(end) = [];
            end
            load(dataName)
        end
    else
        dataName= ls ('*.mat');
        if ismac
            dataName(end) = [];
        end
        load(dataName)
    end
    
    
    % Plot the behavior
    if ismac
        macRecDir = recordingDirs{recInd};
        macRecDir(strfind(macRecDir,'\'))='/';
        cd([workingDir macRecDir(1:end-20)])
    else
        cd([workingDir recordingDirs{recInd}(1:end-20)])
    end
    labViewFileName = ls('*.txt');
    if ismac
        labViewFileName(end) = [];
    end
    labViewFileName = labViewFileName(1:end-4);
    READ_PROB_EXP(labViewFileName, 'Head-fixed', lickThArray(recInd));
    
    % Plot the spiking activity
    [params] = plotSpikesByBehavior(params, TTnum{recInd});
    
    expProbs = num(recInd,9:11);
    %         cd([workingDir '/examples'])
    cd([workingDir '/' mouseNum '/examples'])
    if length(find(expProbs > 0)) == 3
        cd('A_B_C')
    elseif length(find(expProbs > 0)) == 2
        cd('A_B')
    else
        cd('A')
    end
    %Save the summary figure (only PSTHs)
    saveas(gcf, [recordingDirs{recInd}(end-18:end) '_' num2str(TTnum{recInd}) '_'  Raw{recInd,3} '.jpg'])
    close;
    %save the raster plots in sub figures
    mkdir([recordingDirs{recInd}(end-18:end) '_' num2str(TTnum{recInd})])
    cd([recordingDirs{recInd}(end-18:end) '_' num2str(TTnum{recInd})]);
    for saveInd = 1:length(find(expProbs > 0))+1
        saveas(gcf, [recordingDirs{recInd}(end-18:end) '_' num2str(TTnum{recInd})  '_' num2str(saveInd) '_'  Raw{recInd,3} '.jpg'])
        close;
    end
    
end