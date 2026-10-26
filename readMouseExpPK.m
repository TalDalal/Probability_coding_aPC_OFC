function [outputStruct] = readMouseExpPK(filePath, smoothWin, plotFlag,NoChannels, params)

global lickTh waterDelayTime odorDuration  

if nargin < 3
    plotFlag = 1;
end

%%  Channels to read
lickChnl = 1;
pokeChnl = 2;% IR
odorChnl1 = 3;
odorChnl2 = 4;% Usually the target odor

%% open the Dat file to get all channels data
startEndTime = [0 10^10];
startTime = startEndTime(1);
endTime = startEndTime(2);
[fid, NumOfChan, sampleRate]  = openDAQfile(filePath);
outputStruct.sampleRate = sampleRate;
startPoint = startTime*sampleRate;
endPoint= endTime*sampleRate;
% seek to startPoint
readSize = startPoint;

% read to the end point
channelsData=[];
readSize = endPoint - startPoint+1;


while readSize > 0
    [readData] = readDAQfileChuncks(fid, 1:NoChannels, max(10^10,readSize) , NumOfChan );
    if isempty(readData)
        break;
    end
    channelsData = [channelsData readData];
    acum_channelsData = size(channelsData);
    
end
% calculate the time we are
df = 1/sampleRate;

allChnls = channelsData;
outputStruct.allChnls = allChnls;
%% get the two odors start end times
%----------------------------------------------
[odorOn odorOff] = getOdorOnOffTimes(allChnls(odorChnl1,:), 0, params.sMinusTrials);
odor1OnOff =[odorOn; odorOff];


[odorOn odorOff] = getOdorOnOffTimes(allChnls(odorChnl2,:), 0, params.sPlusTrials);
odor2OnOff =[odorOn; odorOff];

% concate both odors
odorOnOff = [odor1OnOff(:,:) odor2OnOff(:,:)];
odorIndex = [ones(1,size(odor1OnOff,2)) 2.*ones(1,size(odor2OnOff,2))];
outputStruct.odorOnOff = odorOnOff;

%% Extract lick data

lickRes = allChnls(lickChnl,:);
[lickTimes, lickRes] = getLickTimes(lickRes,lickTh);
outputStruct.lickTimes = lickTimes;

%% find lick latencies

delay_duration = waterDelayTime + odorDuration;
outputStruct.delay_duration = delay_duration;
lickBaseline = 1000;%how far to analyze before the odor (ms)
windowStartLickAnalaysis=params.windowStartLickAnalaysis;

odor2Latency = [];lickData = [];
% get licks latency for odor 2 (S+)
for lickIndx = 1:size(odor2OnOff,2)
    % window for assesing hit\FA
    behaviorAnalysistime = [odor2OnOff(1,lickIndx) : odor2OnOff(1,lickIndx) + waterDelayTime+odorDuration];
    
    % Window for licks raster plot
    if odor2OnOff(1,lickIndx) < lickBaseline% in case the first lick was just when the recording started.
          lickRasterPlotTime = [odor2OnOff(1,lickIndx) : odor2OnOff(1,lickIndx) + waterDelayTime+odorDuration];  
    else
    lickRasterPlotTime = [odor2OnOff(1,lickIndx) - lickBaseline : odor2OnOff(1,lickIndx) + waterDelayTime+odorDuration];
    end
    % Lick signal in the current trual
    currTrial = lickRes(behaviorAnalysistime);
    
    %Only valid if there were more than XX licks
    validTrial = length(find(diff(currTrial) == 1)) > params.minimalLicks;
    if validTrial
        odor2Latency(end+1) = find(diff(currTrial) == 1,1)./sampleRate;
        
        % create the data for lick raster plot
        lickData(end+1).times = find(diff(lickRes(lickRasterPlotTime)) == 1)./sampleRate;
    end
end
% Co,pute the hit rate
newHitRate =  length(odor2Latency)/size(odor2OnOff,2);
% save the data
outputStruct.hitLickData = lickData;
outputStruct.hitRate=newHitRate;
outputStruct.lickBaseline = lickBaseline;

odor1Latency = []; lickData = []; lickRasterPlotTime = [];currTrial = [];validTrial = [];
% get licks latency for odor 1 (S-)
for lickIndx = 1:size(odor1OnOff,2)
     % window for assesing hit\FA
    behaviorAnalysistime = [odor1OnOff(1,lickIndx) : odor1OnOff(1,lickIndx) + waterDelayTime+odorDuration];
    
    % Window for licks raster plot
    if odor1OnOff(1,lickIndx) < lickBaseline% in case the first lick was just when the recording started.
          lickRasterPlotTime = [odor1OnOff(1,lickIndx) : odor1OnOff(1,lickIndx) + waterDelayTime+odorDuration];  
    else
    lickRasterPlotTime = [odor1OnOff(1,lickIndx) - lickBaseline : odor1OnOff(1,lickIndx) + waterDelayTime+odorDuration];
    end
    % Lick signal in the current trual
    currTrial = lickRes(behaviorAnalysistime);
    
    %Only valid if there were more than XX licks
    validTrial = length(find(diff(currTrial) == 1)) > params.minimalLicks;
    if validTrial
        odor1Latency(end+1) = find(diff(currTrial) == 1,1)./sampleRate;
        
        % create the data for lick raster plot
        lickData(end+1).times = find(diff(lickRes(lickRasterPlotTime)) == 1)./sampleRate;
    end
end

newFARate =   length(odor1Latency)/size(odor1OnOff,2);
outputStruct.FARate=newFARate;

%final_success=hit+1-fa/2
finalSucc= (newHitRate +(1-newFARate))/2;
outputStruct.finalSucc=finalSucc;



