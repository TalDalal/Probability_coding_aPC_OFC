function [params] =  analyzeSuccRates(filePath, params)

global lickTh waterDelayTime odorDuration


%%  Channels to read
if strcmpi(params.setupType, 'freely')
    
    params.lickChnl = 1;
    
    
    params.pokeChannel = 2;
    
    
    params.odorsChnl = 3;
    
else
    
    params.sniffChnl = 1;
    
    if strcmpi(params.lickMethod, 'IR')
        params.lickChnl = 2;% IR
    elseif strcmpi(params.lickMethod,'Elect')
         params.lickChnl = 4;% elect;
    end
        
    
    params.odorsChnl = 3;
    
%     params.lickElectricChnl = 4;
end

%% open the Dat file to get all channels data
startEndTime = [0 10^10];
startTime = startEndTime(1);
endTime = startEndTime(2);
[fid, NumOfChan, sampleRate]  = openDAQfile(filePath);
params.sampleRate = sampleRate;
startPoint = startTime*sampleRate;
endPoint= endTime*sampleRate;
% seek to startPoint
readSize = startPoint;

% read to the end point
channelsData=[];
readSize = endPoint - startPoint+1;

%%%% IMPORTANT FLAGS %%%%%%
%Correction of noise in lick activity params
params.correctFalseHitTrialsFlag = 1;
params.maximalPercentOflicksActivity = 0.45;

%Correct the RT of prior licking trials
params.correctRTinPriorLicksFlag = 1;

params.NChanels = NumOfChan;

while readSize > 0
    [readData] = readDAQfileChuncks(fid, 1:params.NChanels, max(10^10,readSize) , NumOfChan );
    if isempty(readData)
        break;
    end
    channelsData = [channelsData readData];
    acum_channelsData = size(channelsData);
    
end
% calculate the time we are
df = 1/sampleRate;

% Since the signal is negative, we multiply it by -1.
if strcmpi(params.lickMethod,'Elect')
    channelsData(4,:) = channelsData(4,:).*-1;% elect;
    params.lickTh =  params.lickTh.*-1;
end

params.allChnls = channelsData;
%% get the odor start end times

%Check if this is a pretraining session
params.pretrainingFlag = 0;
if ~ismember(3, params.trialsIndex) & ~ismember(1, params.trialsIndex)
    params.pretrainingFlag = 1;
end
% extract odor time stamps
[odorTimes] = odorTimeStamps(params);
% targetOdor = odorTimes(:,2:2:end);% the first odor is the predicting odor

%Until M4 the experiment started imediatly (no baseline period) so it
%earased the first odor pulse from the signal. If it was a single odor
%(such as in 4 and 5 cases) we lost the event.
removedTrials = [];
if params.trialsIndex(1) == 4 | params.trialsIndex(1) == 5
    if sum(odorTimes(:,1)) == 0
        removedTrials = 1;
        odorTimes(:,removedTrials) = [];params.trialsIndex(removedTrials) = [];
        
        disp('Removed the first event as it was a single odor')
    end
end
params.removedTrials = removedTrials;
params.odorTimes = odorTimes;
% FInd the second odor in case we have single\double odors per trial
trialNum = 0;targetOdorIndices = [];
targetOdor = [];% the first odor is the predicting odor
for trialInd = 1:length(params.trialsIndex)
    if params.trialsIndex(trialInd) < 4 % 4 and 5 are the T+ and - respectively.
        trialNum = trialNum+2;
    else
        trialNum = trialNum+1;
    end
    targetOdor(:,end+1) = odorTimes(:, trialNum);
    targetOdorIndices = [targetOdorIndices trialNum];
end
params.targetOdor = targetOdor;
params.targetOdorIndices = targetOdorIndices;

%% Assign the trials
params.targetTrials.A = find(params.trialsIndex==1);
params.targetTrials.B = find(params.trialsIndex==2);
params.targetTrials.C = find(params.trialsIndex==3);
params.targetTrials.T = find(params.trialsIndex==4);

params.tMinusTrials.A = find(params.trialsIndex==-1);
params.tMinusTrials.B = find(params.trialsIndex==-2);
params.tMinusTrials.C = find(params.trialsIndex==-3);
params.tMinusTrials.Tminus = find(params.trialsIndex==5);
%% Extract lick data

    
[lickTimes, ~] = lickTimeStamps(params);
params.lickTimes = lickTimes;


%% Extract sniffs from Daq

[sniffTimes, ~, inhExhTimes] = sniffsTimeStamps(params);
params.inhExhTimes = inhExhTimes;
%% Compute success rates

if params.newAnalysisMethodFlag==1
    
    %% assess the behavior in each trial
    if strcmpi(params.lickMethod, 'IR')
        lickSignal = channelsData(2,:);% IR
    elseif strcmpi(params.lickMethod,'Elect')
        lickSignal = channelsData(4,:);%Elect
    end
    trialInd = [];lickIndicator = nan(1,length(targetOdor));
    firstLickLatency = lickIndicator;
    antLickRate = lickIndicator;
    percentLicksPerTrial = lickIndicator;
    priorLickTrials = [];
    extraTimeBinForLicks = 2000;
    anticLickWindow = [-1 1];% a window to compute the anticipitory lick rate
    windowForExtraTimeOutsideTrial = 4000;
    
    for trialInd = 1:length(targetOdor)
        
        % [1.the first odor onset and the wait between the odors before T,
        %  2.T
        %  3. the end of the licking window]
        odorAnalysisWin = [targetOdor(1,trialInd) - params.ISIbetweenOdors-params.odor_duration, ...
            targetOdor(1,trialInd) , ....
            targetOdor(1,trialInd) + params.lickAnalysisWindow-1] + params.windowStartLickAnalaysis;
        
        % Licks starting from the target odor onset
        trialLicks = length(find(lickTimes(1,:) >= odorAnalysisWin(2) & lickTimes(1,:) < odorAnalysisWin(end)));
        
        %trials sniffs
        trialSniffs = length(find(sniffTimes(1,:) >= odorAnalysisWin(2) & sniffTimes(1,:) < odorAnalysisWin(end)));
        
        % check if there were XX licks in each trial (0 or 1)
        if trialLicks < params.minimalNumLicks
            lickIndicator(trialInd) = 0;
        else
            lickIndicator(trialInd) = 1;
        end
        
        
        ignoreThisTrial = 0;
        %Compute the first lick latency
        currLickLatency = (lickTimes(1, find(lickTimes(1,:) >= odorAnalysisWin(1) & lickTimes(1,:) < odorAnalysisWin(end))) - odorAnalysisWin(2))/1000;
        
        if ~isempty(currLickLatency)
            firstLickLatency(trialInd) = currLickLatency(1);
            antLickRate(trialInd) = length(find(currLickLatency >= anticLickWindow(1) & currLickLatency < anticLickWindow(2)));
            
            %---------Handeling special cases of paws activity during trial or licks
            %prior to trial initiation ------------
            
            % check for cases the mouse hits the port with its paws (it
            % count as IR crossing but this are no licks).
            if odorAnalysisWin(1) > 0
                currTrialLick = (lickSignal(odorAnalysisWin(1):odorAnalysisWin(end)+params.delay_to_water));
                percentLicksPerTrial(trialInd) = length(find(currTrialLick > params.lickTh))./length(currTrialLick);
                
                % Correct these trials by applying nan to the RT
                if percentLicksPerTrial(trialInd) > params.maximalPercentOflicksActivity & params.correctFalseHitTrialsFlag
                    ignoreThisTrial = 1;
                    lickIndicator(trialInd) = 0;
                    firstLickLatency(trialInd) = nan;
                    disp('A "hit" trial following paws activity was removed')
                end
            end
        end
        
        
        %---------Handeling special cases of paws activity during trial or licks
        %prior to trial initiation ------------
        % ---- cases the mouse started to lick before the trial
        priorLicks = length(find(lickTimes(1,:) >= odorAnalysisWin(1)-1000 & lickTimes(1,:) < odorAnalysisWin(1)));
        
        if priorLicks >= params.minimalNumLicks & lickIndicator(trialInd) == 1 & firstLickLatency(trialInd) < 0
            
            %correct the RT ij this trial
            if params.correctRTinPriorLicksFlag
                ignoreThisTrial = 1;
                firstLickLatency(trialInd) = currLickLatency(find(currLickLatency > 0,1));
                disp(['Corrected the RT following Prior licking from ' num2str(currLickLatency(1)) ' to ' num2str(firstLickLatency(trialInd)) ' in condition ' num2str(params.trialsIndex(trialInd))])
            end
            
            % save the trial inex, trial time, how many prior licks, which
            % condition and before and after correction RTs.
            priorLickTrials(end+1,:) = [trialInd odorAnalysisWin(1) - params.windowStartLickAnalaysis-1000 odorAnalysisWin(end) priorLicks params.trialsIndex(trialInd) currLickLatency(1) firstLickLatency(trialInd)];
            
        end
        
        if ignoreThisTrial == 0
            % data for lick raster plot
            lickRaster(trialInd).times = (lickTimes(1, find(lickTimes(1,:) >= odorAnalysisWin(1) & lickTimes(1,:) < odorAnalysisWin(end) + extraTimeBinForLicks)) - odorAnalysisWin(2))/1000;
            
            %Sniff raster
            sniffRaster(trialInd).times = (sniffTimes(1, find(sniffTimes(1,:) >= odorAnalysisWin(1)-2000 & sniffTimes(1,:) < odorAnalysisWin(end) + extraTimeBinForLicks+2000)) - odorAnalysisWin(2))/1000;
        else
            lickRaster(trialInd).times = [];
            sniffRaster(trialInd).times = [];
        end
        
        
    end
    params.priorLickTrials = priorLickTrials;
    params.percentLicksPerTrial = percentLicksPerTrial(trialInd);
    %%
%     trialsWin = 40;
%     trialsJump = 10;
%     trialBins = 1:trialsJump:length(params.trialsIndex)-trialsWin;
%     currBin_RT_A = [];currBin_RT_C = [];
%     
%     for trialBinInd = trialBins
%         allCurrentRTs = firstLickLatency(find(lickIndicator(trialBinInd:trialBinInd+trialsWin-1)));
%         allCurrenttrialInds = params.trialsIndex(find(lickIndicator(trialBinInd:trialBinInd+trialsWin-1)));
%         
%         currBin_RT_A(end+1) = nanmean(allCurrentRTs(find(allCurrenttrialInds==1)));
%         currBin_RT_C(end+1) = nanmean(allCurrentRTs(find(allCurrenttrialInds==3)));
%     end
%     
%     figure
%     plot(trialBins, currBin_RT_A);
%     hold all;
%     plot(trialBins, currBin_RT_C);
    %% %% trials indices by outcome
    %-----------------Hit + Miss------------------
    params.trialOutcome.hit.A = [];params.trialOutcome.miss.A = [];
    if ~isempty(params.targetTrials.A)
        params.trialOutcome.hit.A = find(lickIndicator == 1 & params.trialsIndex == 1);
        params.trialOutcome.miss.A = find(lickIndicator == 0 & params.trialsIndex == 1);
    end
    params.trialOutcome.hit.B = [];params.trialOutcome.miss.B = [];
    if ~isempty(params.targetTrials.B)
        params.trialOutcome.hit.B = find(lickIndicator == 1 & params.trialsIndex == 2);
        params.trialOutcome.miss.B = find(lickIndicator == 0 & params.trialsIndex == 2);
    end
    
    params.trialOutcome.hit.C = [];params.trialOutcome.miss.C = [];
    if ~isempty(params.targetTrials.C)
        params.trialOutcome.hit.C = find(lickIndicator == 1 & params.trialsIndex == 3);
        params.trialOutcome.miss.C = find(lickIndicator == 0 & params.trialsIndex == 3);
    end
    
    params.trialOutcome.hit.T = [];params.trialOutcome.miss.T = [];
    if ~isempty(params.targetTrials.T)
        params.trialOutcome.hit.T = find(lickIndicator == 1 & params.trialsIndex == 4);
        params.trialOutcome.miss.T = find(lickIndicator == 0 & params.trialsIndex == 4);
    end
    
    %------------FA + CR------------------
    params.trialOutcome.FA.A = [];params.trialOutcome.CR.A = [];
    if ~isempty(params.tMinusTrials.A)
        params.trialOutcome.FA.A = find(lickIndicator == 1 & params.trialsIndex == -1);
        params.trialOutcome.CR.A = find(lickIndicator == 0 & params.trialsIndex == -1);
    end
    
    params.trialOutcome.FA.B = [];params.trialOutcome.CR.B = [];
    if ~isempty(params.tMinusTrials.B)
        params.trialOutcome.FA.B = find(lickIndicator == 1 & params.trialsIndex == -2);
        params.trialOutcome.CR.B = find(lickIndicator == 0 & params.trialsIndex == -2);
    end
    params.trialOutcome.FA.C = [];params.trialOutcome.CR.C = [];
    if ~isempty(params.tMinusTrials.C)
        params.trialOutcome.FA.C = find(lickIndicator == 1 & params.trialsIndex == -3);
        params.trialOutcome.CR.C = find(lickIndicator == 0 & params.trialsIndex == -3);
    end
    params.trialOutcome.FA.Tminus = [];params.trialOutcome.CR.Tminus = [];
    if ~isempty(params.tMinusTrials.Tminus)
        params.trialOutcome.FA.Tminus = find(lickIndicator == 1 & params.trialsIndex == 5);
        params.trialOutcome.CR.Tminus = find(lickIndicator == 0 & params.trialsIndex == 5);
    end
    %% assign data
    %-----------A----------
    % Compute success rates
    params.LickRaster.allTrials = lickRaster;
    params.SniffRaster.allTrials = sniffRaster;
    params.lickIndicator = lickIndicator;
    params.hitRate.A = [];params.FA.A = [];params.successRate.A = [];params.firstLickLatency.A = [];
    params.LickRaster.hit.A = [];params.LickRaster.FA.A = [];
    if ~isempty(params.targetTrials.A) & ~isempty(params.tMinusTrials.A)
        params.hitRate.A = length(params.trialOutcome.hit.A)/length(params.targetTrials.A);
        params.FA.A = length(params.trialOutcome.FA.A)/length(params.tMinusTrials.A);
        params.successRate.A = (params.hitRate.A + (1 - params.FA.A))/2;
        %         params.dPrime.A = dprime_simple(params.hitRate.A, params.FA.A);
        
        % licks data
        params.firstLickLatency.all = firstLickLatency;
        params.LickRaster.hit.A = lickRaster(params.trialOutcome.hit.A);
        params.LickRaster.FA.A = lickRaster(params.trialOutcome.FA.A);
        params.firstLickLatency.A = firstLickLatency(params.trialOutcome.hit.A);
        params.anticipitoryLickRate.A = antLickRate(params.trialOutcome.hit.A);
        params.AnticipitoryLicksPercent.A = length(find(params.firstLickLatency.A < 0))./length(params.firstLickLatency.A);
        params.Atrials = sort([params.targetTrials.A params.tMinusTrials.A]);
        
        params.SniffRaster.A = sniffRaster(params.Atrials);
    end
    
    %-----------B----------
    % Compute success rates
    params.hitRate.B = [];params.FA.B = [];params.successRate.B = [];params.firstLickLatency.B = [];
    params.LickRaster.hit.B = [];params.LickRaster.FA.B = [];
    if ~isempty(params.targetTrials.B) & ~isempty(params.tMinusTrials.B)
        params.hitRate.B = length(params.trialOutcome.hit.B)/length(params.targetTrials.B);
        params.FA.B = length(params.trialOutcome.FA.B)/length(params.tMinusTrials.B);
        params.successRate.B = (params.hitRate.B + (1 - params.FA.B))/2;
        %         params.dPrime.B = dprime_simple(params.hitRate.B, params.FA.B);
        
        % licks data
        params.LickRaster.hit.B = lickRaster(params.trialOutcome.hit.B);
        params.LickRaster.FA.B = lickRaster(params.trialOutcome.FA.B);
        params.firstLickLatency.B = firstLickLatency(params.trialOutcome.hit.B);
        params.anticipitoryLickRate.B = antLickRate(params.trialOutcome.hit.B);
        params.AnticipitoryLicksPercent.B = length(find(params.firstLickLatency.B < 0))./length(params.firstLickLatency.B);
        params.Btrials = sort([params.targetTrials.B params.tMinusTrials.B]);
        
        params.SniffRaster.B = sniffRaster(params.Btrials);
    end
    
    %-----------C----------
    % Compute success rates
    params.hitRate.C = [];params.FA.C = [];params.successRate.C = [];params.firstLickLatency.C = [];
    params.LickRaster.hit.C = [];params.LickRaster.FA.C = [];
    if ~isempty(params.targetTrials.C) & ~isempty(params.tMinusTrials.C)
        params.hitRate.C = length(params.trialOutcome.hit.C)/length(params.targetTrials.C);
        params.FA.C = length(params.trialOutcome.FA.C)/length(params.tMinusTrials.C);
        params.successRate.C = (params.hitRate.C + (1 - params.FA.C))/2;
        %         params.dPrime.C = dprime_simple(params.hitRate.C, params.FA.C);
        
        % licks data
        params.LickRaster.hit.C = lickRaster(params.trialOutcome.hit.C);
        params.LickRaster.FA.C = lickRaster(params.trialOutcome.FA.C);
        params.firstLickLatency.C = firstLickLatency(params.trialOutcome.hit.C);
        params.anticipitoryLickRate.C = antLickRate(params.trialOutcome.hit.C);
        params.AnticipitoryLicksPercent.C = length(find(params.firstLickLatency.C < 0))./length(params.firstLickLatency.C);
        params.Ctrials = sort([params.targetTrials.C params.tMinusTrials.C]);
        
        params.SniffRaster.C = sniffRaster(params.Ctrials);
    end
    
    %-----------T----------
    % Compute success rates
    params.hitRate.T = [];params.FA.T = [];params.successRate.T = [];params.LickRaster.hit.T = [];
    params.LickRaster.hit.T = [];params.LickRaster.FA.T = [];
    if ~isempty(params.targetTrials.T) & ~isempty(params.tMinusTrials.Tminus)
        params.hitRate.T = length(params.trialOutcome.hit.T)/length(params.targetTrials.T);
        params.FA.T = length(params.trialOutcome.FA.Tminus)/length(params.tMinusTrials.Tminus);
        params.successRate.T = (params.hitRate.T + (1 - params.FA.T))/2;
        %         params.dPrime.T = dprime_simple(params.hitRate.T, params.FA.T);
        
        % licks data
        params.LickRaster.hit.T = lickRaster(params.trialOutcome.hit.T);
        params.LickRaster.FA.T = lickRaster(params.trialOutcome.FA.Tminus);
        params.firstLickLatency.T = firstLickLatency(params.trialOutcome.hit.T);
        params.anticipitoryLickRate.T = antLickRate(params.trialOutcome.hit.T);
        params.AnticipitoryLicksPercent.T = length(find(params.firstLickLatency.T < 0))./length(params.firstLickLatency.T);
        params.Ttrials = sort([params.targetTrials.T params.tMinusTrials.Tminus]);
        
        params.SniffRaster.T = sniffRaster(params.Ttrials);
    end
    
elseif params.newAnalysisMethodFlag==0
    %----------- ANALYZE A TRIALS ----------------
    if ~isempty(params.targetTrials.A)
        AsuccessVec = [];lickRaster = [];firstLickLatency = [];AmissIndex = [];
        Atrials = sort([params.targetTrials.A params.tMinusTrials.A]);
        
        for trialInd = 1:length(Atrials)
            % [1 sec before T, T and end of T]
            odorAnalysisWin = [targetOdor(1,Atrials(trialInd)) - params.ISIbetweenOdors, ...
                targetOdor(1,Atrials(trialInd)) + params.windowStartLickAnalaysis, ...
                targetOdor(1,Atrials(trialInd)) + params.lickAnalysisWindow-1];
            % Licks starting from the target odor onset
            trialLicks = length(find(lickTimes(1,:) >= odorAnalysisWin(2) & lickTimes(1,:) < odorAnalysisWin(end)));
            
            if trialLicks < params.minimalNumLicks
                AsuccessVec(end+1) = 0;
                if params.trialsIndex(Atrials(trialInd)) == 1
                    AmissIndex(end+1) = trialInd;
                end
            else
                if params.trialsIndex(Atrials(trialInd)) == -1
                    AsuccessVec(end+1) = -1;
                    
                elseif params.trialsIndex(Atrials(trialInd)) == 1
                    AsuccessVec(end+1) = 1;
                    
                    % data for lick raster plot
                    lickRaster(end+1).times = (lickTimes(1, find(lickTimes(1,:) >= odorAnalysisWin(1) & lickTimes(1,:) < odorAnalysisWin(end))) - odorAnalysisWin(2))/1000;
                    %Compute lick latency
                    firstLickLatency(end+1) = (lickTimes(1, find(lickTimes(1,:) >= odorAnalysisWin(1) & lickTimes(1,:) < odorAnalysisWin(end),1)) - odorAnalysisWin(2))/1000;
                end
            end
        end
        
        params.hitRate.A = length(find(AsuccessVec==1))/length(params.targetTrials.A);
        params.FA.A = length(find(AsuccessVec==-1))/length(params.tMinusTrials.A);
        params.successRate.A = (params.hitRate.A + (1 - params.FA.A))/2;
        params.AsuccessVec = AsuccessVec;
        params.LickRaster.A = lickRaster;
        params.firstLickLatency.A = firstLickLatency;
        params.AnticipitoryLicksPercent.A = length(find(firstLickLatency < 0))./length(firstLickLatency);
        params.Atrials = Atrials;
        params.AmissIndex = AmissIndex;
    end
    odorAnalysisWin = [];trialInd = [];firstLickLatency = [];lickRaster = [];
    
    %----------- ANALYZE B TRIALS ----------------
    if ~isempty(params.targetTrials.B)
        BsuccessVec = [];BmissIndex = [];
        Btrials = sort([params.targetTrials.B params.tMinusTrials.B]);
        
        for trialInd = 1:length(Btrials)
            % [1 sec before T, T and end of T]
            odorAnalysisWin = [targetOdor(1,Btrials(trialInd))-params.ISIbetweenOdors, targetOdor(1,Btrials(trialInd)) + params.windowStartLickAnalaysis, targetOdor(1,Btrials(trialInd)) + params.lickAnalysisWindow-1];
            
            trialLicks = length(find(lickTimes(1,:) >= odorAnalysisWin(2) & lickTimes(1,:) < odorAnalysisWin(end)));
            
            if trialLicks < params.minimalNumLicks
                BsuccessVec(end+1) = 0;
                if params.trialsIndex(Btrials(trialInd)) == 2
                    BmissIndex(end+1) = trialInd;
                end
            else
                if params.trialsIndex(Btrials(trialInd)) == -2
                    BsuccessVec(end+1) = -2;
                    
                elseif params.trialsIndex(Btrials(trialInd)) == 2
                    BsuccessVec(end+1) = 2;
                    
                    % data for lick raster plot
                    lickRaster(end+1).times = (lickTimes(1, lickTimes(1,:) >= odorAnalysisWin(1) & lickTimes(1,:) < odorAnalysisWin(end)) - odorAnalysisWin(2))/1000;
                    firstLickLatency(end+1) = (lickTimes(1, find(lickTimes(1,:) >= odorAnalysisWin(1) & lickTimes(1,:) < odorAnalysisWin(end),1)) - odorAnalysisWin(2))/1000;
                    
                end
            end
        end
        
        params.hitRate.B = length(find(BsuccessVec==2))/length(params.targetTrials.B);
        params.FA.B = length(find(BsuccessVec==-2))/length(params.tMinusTrials.B);
        params.successRate.B = (params.hitRate.B + (1 - params.FA.B))/2;
        params.BsuccessVec = BsuccessVec;
        params.LickRaster.B = lickRaster;
        params.firstLickLatency.B = firstLickLatency;
        params.AnticipitoryLicksPercent.B = length(find(firstLickLatency < 0))./length(firstLickLatency);
        params.Btrials = Btrials;
        params.BmissIndex = BmissIndex;
    end
    
    odorAnalysisWin = [];trialInd = [];firstLickLatency = [];lickRaster = [];
    %----------- ANALYZE C TRIALS ----------------
    if ~isempty(params.targetTrials.C)
        CsuccessVec = [];CmissIndex = [];
        Ctrials = sort([params.targetTrials.C params.tMinusTrials.C]);
        
        for trialInd = 1:length(Ctrials)
            % [1 sec before T, T and end of T]
            odorAnalysisWin = [targetOdor(1,Ctrials(trialInd))-params.ISIbetweenOdors, targetOdor(1,Ctrials(trialInd)) + params.windowStartLickAnalaysis, targetOdor(1,Ctrials(trialInd)) + params.lickAnalysisWindow-1];
            
            trialLicks = length(find(lickTimes(1,:) >= odorAnalysisWin(2) & lickTimes(1,:) < odorAnalysisWin(end)));
            
            if trialLicks < params.minimalNumLicks
                CsuccessVec(end+1) = 0;
                
                if params.trialsIndex(Ctrials(trialInd)) == 3
                    CmissIndex(end+1) = trialInd;
                end
            else
                if params.trialsIndex(Ctrials(trialInd)) == -3
                    CsuccessVec(end+1) = -3;
                    
                elseif params.trialsIndex(Ctrials(trialInd)) == 3
                    CsuccessVec(end+1) = 3;
                    
                    % data for lick raster plot
                    lickRaster(end+1).times = (lickTimes(1, find(lickTimes(1,:) >= odorAnalysisWin(1) & lickTimes(1,:) < odorAnalysisWin(end))) - odorAnalysisWin(2))/1000;
                    firstLickLatency(end+1) = (lickTimes(1, find(lickTimes(1,:) >= odorAnalysisWin(1) & lickTimes(1,:) < odorAnalysisWin(end),1)) - odorAnalysisWin(2))/1000;
                    
                end
            end
        end
        
        params.hitRate.C = length(find(CsuccessVec==3))/length(params.targetTrials.C);
        params.FA.C = length(find(CsuccessVec==-3))/length(params.tMinusTrials.C);
        params.successRate.C = (params.hitRate.C + (1 - params.FA.C))/2;
        params.CsuccessVec = CsuccessVec;
        params.LickRaster.C = lickRaster;
        params.firstLickLatency.C = firstLickLatency;
        params.AnticipitoryLicksPercent.C = length(find(firstLickLatency < 0))./length(firstLickLatency);
        params.Ctrials = Ctrials;
        params.CmissIndex = CmissIndex;
    end
    
    
end
