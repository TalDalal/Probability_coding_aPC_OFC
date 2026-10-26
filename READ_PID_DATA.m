function [params] = READ_PID_DATA(fullFileName)
%If we ran to the PID the trial structure of the two odors or one odor in
%each trial.
params.Two_or_one_odor_data = 'one';

%% read the data from the file
global waterDelayTime odorDuration 

%%%%%% Insert the working directory path %%%%
% dirPath = pwd;
% if ismac
%     dirPath = [dirPath '/'];
% else
%     dirPath = [dirPath '\'];
% end
params.fullFileName = fullFileName;
fid = fopen([params.fullFileName '.txt']);
% params.setupType = setupType;% Head-fixed or freely moving.
params.SingleOdorsExp = 1;

%% %%%% Assign params %%%%%
format long
cell_data= textscan(fid,'%s%f','Delimiter','=','headerLines',1);
parameters=cell_data{2};
params.odor_duration=parameters(1);%ms
params.delay_to_water=parameters(2);%ms
params.water_duration=parameters(3);%ms
params.ITI=parameters(4);% ITI
params.ISIbetweenOdors=parameters(5);
params.lickTh=parameters(6);

waterDelayTime = params.delay_to_water; % 1 second in 1000 sampling rate
odorDuration=params.odor_duration;

% if strcmpi(params.setupType, 'freely')
%     params.odorTh = 2;
%     params.lickTh = 0.2;%%%%%% CHANGE IF NEEDED
% else
    params.odorTh = 0;
    params.lickTh = 3.62;%%%%%% CHANGE IF NEEDED
% end

params.lickAnalysisWindow = waterDelayTime + odorDuration;

params.NChanels=3;
params.windowStartLickAnalaysis = 100;%ms
params.minimalNumLicks = 3;


fclose(fid);

%Extract indices from the text file
stimVec = cell_data{1}(17:end);
signVar = 1;trialsIndex = [];
for ind = 1:length(stimVec)
    
    if strcmpi(stimVec{ind}(1), '-')
        trialsIndex(end+1) = str2num(stimVec{ind}(1:2));
    elseif isequal(stimVec{ind}(1),'0')
        continue;
    else
       trialsIndex(end+1) = str2num(stimVec{ind}(1)); 
    end
end

% Assign the trials
params.targetTrials.A = find(trialsIndex==1);
params.targetTrials.B = find(trialsIndex==2);
params.targetTrials.C = find(trialsIndex==3);
params.targetTrials.T = find(trialsIndex==4);

params.tMinusTrials.A = find(trialsIndex==-1);
params.tMinusTrials.B = find(trialsIndex==-2);
params.tMinusTrials.C = find(trialsIndex==-3);

params.trialsIndex = trialsIndex;
params.TotalNumTrials = length(trialsIndex);
params.targetOdorIndices = trialsIndex;
    
%% %%% Read the data %%%%%%%%
[params] = analyzePIDdata([params.fullFileName '.dat'], params);

