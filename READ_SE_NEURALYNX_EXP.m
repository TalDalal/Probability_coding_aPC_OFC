%% read the experiments into a session object
global ODOR_DELAY_TIME;
global refractoryThreshold;
global ODOR_INHALE_MINDURATION;
refractoryThreshold = 2/1000;
ODOR_DELAY_TIME = 0.05; % seconds
ODOR_INHALE_MINDURATION = 0.05;  % seconds
allSessions = [];

  

% dirPath = 'E:\odor_similarity\kilosort4_data\6.10.24_buzsaki__WT_PC';
dirPath = 'F:\Experiments\2022\Behavior_Probability\head_fixed\data\M4_h4dmGi_OFC\JHU_Validation';
useFile = 1;
plotFlag = 1;
SPIKE_FORMAT_PREFIX = 'SE';
SPIKE_SORTING_TOOL = 'SpikeSort3D';   % 'nlxspikesort3d' or 'nlxkilosort4' or SpikeSort3D or Mclust
session = shared_initSession(dirPath, useFile, plotFlag, SPIKE_FORMAT_PREFIX, SPIKE_SORTING_TOOL)
    
allSessions{end+1} = session;
%% read the neurons of the session
sessId = 1; expId = 1; readFromDisk = 1;
fp=[];
fp.alighnType = 'odorOnset'; %inhalationOnset
fp.plotFlag = plotFlag ;
fp.sniffRng = [-4:7];  % 4 sniffs before and 7 after
fp.timeRange = [-1.5 1.5];  % range to calcute FR in odorOnset and inhaltionOnset
fp.timeBeforeAfterTest = [-1.5 1.5];
fp.numOfsniffsToAnalyze = 3;
fp.morphFlag = 0;
fp.xRange = [-1 3];
fp.yRange = [-20 40];
cd (allSessions{sessId}.expParams{expId}.dirPath)
% [res ] = shared_labPlotExpParamOdor(expParams, neuronId, odorId, fp)
row_labels=[];
neuronVects=[]; neuronInfo=[];  neuronPVects =[];
for neuronId = 1:length(allSessions{sessId}.expParams{expId}.neuronSpikeTime)
    neuronId
    figSavePath = [allSessions{sessId}.expParams{expId}.dirPath '\' 'Results'];
    mkdir(figSavePath);
    [seId, seIdstr] = getSEId(allSessions{sessId}.expParams{expId}.neuronSpikeTime{neuronId}.tetrode)
   
    if readFromDisk == 0
        [odorRes, ~, ~] = shared_plotAllExpOdorsPSTH(allSessions, sessId, expId, neuronId, fp);
    
        fname = ['odorRes_' num2str(neuronId)];
        save(fname, 'odorRes');
        print([figSavePath '\neuron#' num2str(neuronId) ],'-dpng');
    else        
        fname = ['odorRes_' num2str(neuronId)];
        odorRes=load(fname);
        odorRes=odorRes.odorRes;
    end
    resVect=[]; resPVec =[];
    for jj=[3:14 16:24]
        resVect(end+1) = odorRes(jj).res.frDiff;
        resPVec(end+1) = odorRes(jj).res.pValue;
    end
    neuronVects(neuronId,:) = resVect;
    neuronPVects(neuronId,:) = resPVec;
    
    neuronInfo(neuronId,:) = [seId channelDepthMapBuzsaki(seId,:)];
    
    row_labels{end+1} = [seIdstr];
    close;
    
end
allSessions{sessId}.expParams{expId}.results.neuronVects = neuronVects;
allSessions{sessId}.expParams{expId}.results.neuronPVects = neuronPVects;
allSessions{sessId}.expParams{expId}.results.row_labels = row_labels;
allSessions{sessId}.expParams{expId}.results.neuronInfo = neuronInfo;