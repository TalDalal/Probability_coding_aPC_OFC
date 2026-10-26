function [params] = readExpText_assignParams(params)

global waterDelayTime odorDuration 
fid = fopen([params.fullFileName '.txt']);

%% %%%% Assign params %%%%%
format long
cell_data= textscan(fid,'%s%f','Delimiter','=','headerLines',1);
parameters=cell_data{2};
params.odor_duration=parameters(1);%ms
params.delay_to_water=parameters(2);%ms
params.water_duration=parameters(3);%ms
params.ITI=parameters(4);% ITI
params.ISIbetweenOdors=parameters(5);
params.probability.A = parameters(9);
params.probability.B  = parameters(11);
params.probability.C  = parameters(13);

%Adjaust the color by the probability (high is always green).
params.highProbColor = [0,169,137]./255;%green
params.lowProbColor = [171,62,143]./255;%purple

if params.probability.A > params.probability.C
    params.Ccolor = params.lowProbColor;
    params.Acolor = params.highProbColor;
elseif params.probability.A < params.probability.C
    params.Acolor = params.lowProbColor;
    params.Ccolor = params.highProbColor;
end
params.Bcolor = [2,0,121]./255;%blue
params.Tcolor = 'm';

% # channels
% params.NChanels=4;
params.windowStartLickAnalaysis = 100;%ms
params.minimalNumLicks = 3;% the minimal # licks that counts as behavior

waterDelayTime = params.delay_to_water; % 1 second in 1000 sampling rate
odorDuration=params.odor_duration;
params.lickAnalysisWindow = waterDelayTime + odorDuration;

% Thresholds
if strcmpi(params.setupType, 'freely')
    params.odorTh = 2;
%     params.lickTh = lickTh;
else
    params.odorTh = 0;
%     params.lickTh = lickTh;
    params.sniffTh = -.78;
end

fclose(fid);

%% Extract indices of the trials from the text file
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

params.trialsIndex = trialsIndex;
params.TotalNumTrials = length(trialsIndex);
