function [params] = READ_PROB_EXP(fullFileName, setupType, lickTh, lickMethod)

%fullFileName = 'labview file name.
%lickTh = check the threshold of this session in the xls in the mouse
%directory.
%setupType = 'head-fixed'
%lickMethod = 'IR' or 'Elect'

if nargin < 4
    lickMethod = 'IR';
end
%% read the data from the file

%%%%%%  working directory path %%%%
params.fullFileName = fullFileName;
params.setupType = setupType;% Head-fixed or freely moving.
params.lickTh = lickTh;
params.lickMethod = lickMethod;

[params] = readExpText_assignParams(params);    
%% %%% Read the data %%%%%%%%
params.newAnalysisMethodFlag = 1;
[params] = analyzeSuccRates([params.fullFileName '.dat'], params);

%% Plot the data
[params] = plotExpResult(params);




