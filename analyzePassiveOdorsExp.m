function [params] = analyzePassiveOdorsExp(labViewTxtName, clusName)

%% Read the labview data
% labViewTxtName = 'M6_passive_280623135632';
expParam.dirPath = pwd;

[params]=READ_PID_DATA([expParam.dirPath(1:end-20) '/' labViewTxtName]);

%% Read the neural data

expParam.TetrodeTimeFactor = 10^6;expParam.expStartTime = 0;

[expParam] = event_Extract(expParam);
params.NeuralData.Events = expParam.nlxOdorEventsTime;

%% Extract the spikes
[expParam] = spikes_Extract(expParam, 'nlx', 'TT');
params.NeuralData.Spikes = expParam.neuronSpikeTime;

%% Read the respiration signal

sniffFileName = 'CSC33_RESPIRATION_SNIFF_.mat';
if isfile('CSC33_RESPIRATION_SNIFF_.mat')
    load(sniffFileName)
else
    [sniffPeakVals, inhaleTimes, exhaleTimes] = extractSniffFromCSC('CSC33_RESPIRATION.ncs',0);
end
params.SniffData.InhaleExhale = [inhaleTimes;exhaleTimes];
params.SniffData.sniffAmplitudes = sniffPeakVals;

%% Build the raster plots for all clusters from all tetrodes
[params] = buildRasterPlot(params);

%% Convert the name of the TT to its number in the structure
[params] = convertTTnameToNum(params, clusName);

%% Compute the firing rate per trial for all clusters from all tetrodes
% [params] = computeFiringRatePerUnit(params);
[params] = computeFiringRatePerUnitBINNING(params);

%% Compute evoked response to each odor
[params] = computeEvokeResponsePassiveOdors(params, [-(params.odor_duration/params.sampleRate)*2 0], [0 params.odor_duration/params.sampleRate]);
%% Plot a specific cluster only if we request a specified name
if ~isempty(params.clusNum)
    plotPassiveOdorsExpsResults(params);
end
