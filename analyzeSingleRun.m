function [params] = analyzeSingleRun(labViewTxtName, clusName, lickTh, reAnalyze)

%labViewTxtName = the labview file name which is outside the cheetah
%directory.
%clusName = 'TT5_SS_XX';
%lickTh = 'check in the xls of the mouse what is the th for this session.
%reAnalyze = 1

expParam.dirPath = pwd;
spikesPath = expParam.dirPath;

%% Reanalyzing the cheetah data
if reAnalyze == 1
    
    %% Extract and plot the behavioral data
    [params] = READ_PROB_EXP([expParam.dirPath(1:end-20) '/' labViewTxtName], 'Head-fixed', lickTh);
    
    %% Extract the events from chhetah and cal the time diffrence
    expParam.TetrodeTimeFactor = 10^6;expParam.expStartTime = 0;
    
    [expParam] = event_Extract(expParam);
    if ~isempty(params.removedTrials)
        expParam.nlxOdorEventsTime(:,params.removedTrials) = [];
    end
    params.NeuralData.Events = expParam.nlxOdorEventsTime;
    
    % compare clocks between cheetah and labview
    cheethaExpDuration = (expParam.nlxOdorEventsTime(2,end)-expParam.nlxOdorEventsTime(1,1))/60;
    labviewExpDuration = (params.odorTimes(2,end)-params.odorTimes(1,1))/1000/60;
    clockDiff = abs(60*(cheethaExpDuration-labviewExpDuration));
    disp(['clock difference is ' num2str(clockDiff) ' sec'])
    
    %% Extract the spikes
    [expParam] = spikes_Extract(expParam, 'nlx', 'TT');
    params.NeuralData.Spikes = expParam.neuronSpikeTime;
%     params.clusNum = clusNum;
    
    %% read the LFP from all CSCs
    % [LFPmat] = readLFPdataFromCSC();
    % params.LFPmat = LFPmat;
    
    %% Read the respiration signal
    sniffFileName = 'CSC33_RESPIRATION_SNIFF_.mat';
    if isfile('CSC33_RESPIRATION_SNIFF_.mat')
        load(sniffFileName)
    else
        [sniffPeakVals, inhaleTimes, exhaleTimes] = extractSniffFromCSC('CSC33_RESPIRATION.ncs',0);
    end
    params.SniffData.InhaleExhale = [inhaleTimes;exhaleTimes];
    params.SniffData.sniffAmplitudes = sniffPeakVals;
else
    %% Extract and plot the behavioral data
    %% Load the mat file
    cd(expParam.dirPath(1:end-20))
    loadName = [expParam.dirPath(end-18:end) '_updated'];
    load(loadName);
    READ_PROB_EXP([expParam.dirPath(1:end-20) '/' labViewTxtName], 'Head-fixed', lickTh);
    cd(expParam.dirPath)
end

%% Build the raster plots for all clusters from all tetrodes
[params] = buildRasterPlot(params);

%% Convert the name of the TT to its number in the structure
[params] = convertTTnameToNum(params, clusName);

%% Compute the firing rate per trial for all clusters from all tetrodes
% [params] = computeFiringRatePerUnit(params);
[params] = computeFiringRatePerUnitBINNING(params);

%Plot a specific cluster only if we request a specified name
if ~isempty(params.clusNum)
    %% sort the firing rates and rasterplots by trial type and outcome
    [params] = sortSpikingActivityByTrialType(params);
    
    %% Divide the data plot the spiking activity according to trial outcome
    [params] = plotSpikesByBehavior(params);
    
end
%% Save the struct in the directory
if reAnalyze == 1
    save([pwd '_updated'], 'params')
end
