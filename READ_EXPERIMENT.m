function [outputStruct, params] = READ_EXPERIMENT(fileName)
%% read the data from the file
global waterDelayTime odorDuration 

%%%%%% Insert the working directory path %%%%
dirPath = pwd;
if ismac
    dirPath = [dirPath '/'];
else
    dirPath = [dirPath '\'];
end
%%%%%% Insert the .txt file name %%%%
% fileName = 'm1_150922142607';
fid = fopen([dirPath fileName '.txt']);


%% %%%% Assign params %%%%%
format long
cell_data= textscan(fid,'%s%f','Delimiter','=','headerLines',1);
parameters=cell_data{2};
params.odor_duration=parameters(1);%sec
params.delay_to_water=parameters(2);%Sec
params.water_duration=parameters(3);%ms
params.ISI=parameters(4);% ITI

%Extract trials from the text file
newTextDesc = cell_data{1}(12:end);
trialsVec = [];
for i = 1:length(newTextDesc)
    if ~strcmpi(newTextDesc{i}(1), 'T')
        if i < 10
            trialsVec(end+1) = str2double(newTextDesc{i}(3));
        elseif i < 100
            trialsVec(end+1) = str2double(newTextDesc{i}(4));
        elseif i < 1000
            trialsVec(end+1) = str2double(newTextDesc{i}(5)); 
        end
    end
end
params.numOfTrials = length(trialsVec);
params.sPlusTrials = length(find(trialsVec==2));
params.sMinusTrials = length(find(trialsVec==1));       

params.odor_concentration=10^-2;
params.mice_no='M1';
% params.lickThr=0.45;
params.NChanels=4;
fclose(fid);
% lickTh = params.lickThr; %%change this value according to the licking signal.
params.windowStartLickAnalaysis = 100;
params.minimalLicks = 3;
waterDelayTime = params.delay_to_water; % 1 second in 1000 sampling rate
odorDuration=params.odor_duration;
smoothWin = 2;
plotFlag = 0;
NoChannels=params.NChanels;


%% %%% Read the data %%%%%%%%
[outputStruct] = readMouseExpPK([dirPath fileName '.dat'], smoothWin, plotFlag,NoChannels, params);

