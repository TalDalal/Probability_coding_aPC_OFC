function [expParam] = spikes_Extract(expParam, spikeFomratFlag, type)
% expParam- structure with the experiment parameters
% 'spikeFomratFlag'- 'nlx' or 'mclust'
% 'type'- electrode type: 'SE'- single channels, 'TT'- tetrodes


%import the nuerons
fileList = expParam.dirPath; % full path to the cheetah directory
cd(fileList)
neuronSpikeTimes = [];
switch (lower(spikeFomratFlag))  % if from spike3d
    case {'nlx'}
        
        if strcmp(type,'TT')
            txtFileList = ls ('TT*.txt'); %tetrodes
        else
            txtFileList = ls ('SE*.txt'); %single channels
        end
        
        for i=1:size(txtFileList,1)
            nlxTSfile = [expParam.dirPath '\' txtFileList(i,:)];
            t = importdata(nlxTSfile)/expParam.TetrodeTimeFactor;  % spike times in sec      
            t = t - expParam.expStartTime;
            neuronSpikeTimes{i}.t = t;
            neuronSpikeTimes{i}.tetrode = txtFileList(i,:);
        end
        
    case {'mclust'}      % read the spike times from MCLUST
        
        txtFileList = ls ('TT*.mat');
        
        for i=1:size(txtFileList,1)
            nlxTSfile = [expParam.dirPath '\' txtFileList(i,:)];
            disp('OOOOOOOOOOOOOO  LOADING Mclust Cluster OOOOOOOOOOOOOOOOO')
            load(nlxTSfile); 
            TS = TS*100/expParam.TetrodeTimeFactor;

            TS = TS - expParam.expStartTime;

            neuronSpikeTimes{i}.t = TS;
        end
        
    otherwise
        error('no file format')
end

expParam.neuronSpikeTime = neuronSpikeTimes;

