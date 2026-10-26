function [params] =  analyzePIDdata(filePath, params)

global lickTh waterDelayTime odorDuration

Tplustrials = find(params.trialsIndex==4);
Tminustrials = find(params.trialsIndex==5);
Atrials = find(params.trialsIndex==6);
Btrials = find(params.trialsIndex==7);
Ctrials = find(params.trialsIndex==8);

clrArray = [155,41,72 ; 255,114,81 ; 255,205,116 ; 85,51,17 ; 153,102,51]./255;

odorIdentities{1} = '2-heptanone(cue)';%'A'
odorIdentities{2} = 'ethyl-acetate(cue)';%'C'
odorIdentities{3} = 'ethyl-butyrate(CS+)';%'T+'
odorIdentities{4} = 'penthyl-acetate(CS-)';%'T-'

%%  Channels to read
% if strcmpi(params.setupType, 'freely')
%
%     params.lickChnl = 1;
%
%
%     params.pokeChannel = 2;
%
%
%     params.odorsChnl = 3;
%
% else

params.PID = 1;

params.lickChnl = 2;% IR

params.odorsChnl = 3;
% end

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


params.allChnls = channelsData;
%% get the odor start end times

[odorTimes] = odorTimeStamps(params);
params.odorTimes = odorTimes;

if strcmpi(params.Two_or_one_odor_data, 'one')
    
    % PID signal
    PIDsignal = params.allChnls(params.PID, :);
    %Analysis window
    analysisWin = [-1000 0 params.odor_duration*2 + 1000];
    allPIDtrials = [];
    for odorInd = 1:size(odorTimes,2)
        %Current trial signal
        currTrialSignal = PIDsignal(odorTimes(1,odorInd) + analysisWin(1):odorTimes(1,odorInd) + analysisWin(end)-1);
        %Current baseline
        currBG = PIDsignal(odorTimes(1,odorInd) + analysisWin(1):odorTimes(1,odorInd) + analysisWin(2)-1);
        allPIDtrials(odorInd,:) = currTrialSignal - mean(currBG);
    end
    
    Atrials_PID = allPIDtrials(Atrials,:);
    Ctrials_PID = allPIDtrials(Ctrials,:);
    Tplustrials_PID = allPIDtrials(Tminustrials,:);
    Tminustrials_PID = allPIDtrials(Tplustrials,:);
    
    timeVec = [analysisWin(1):1:analysisWin(3)-1]./params.sampleRate;
    
    %Plot the matrix with all signals sorted by odor
    figure;
    subplot(2,4,[1:4])
    imagesc(timeVec,1:size(allPIDtrials,1), [Atrials_PID;Ctrials_PID;Tplustrials_PID;Tminustrials_PID])
    colormap bone
    hold all;
    plot([0 0], [0 0.6], 'y--');
    plot(params.odor_duration./params.sampleRate.*[1 1], [0 0.6], 'y--');
    
    % Plot individual means
    %A
    subplot(2,4,5)
    errorbar_patch(timeVec, mean(Atrials_PID), std(Atrials_PID)./sqrt(size(Atrials_PID,1)), clrArray(1,:))
    title(odorIdentities{1});
    xlabel('Time (sec)');ylabel('Evoked amplitude (V)')
    hold all;
    plot([0 0], [0 0.6], 'y--');
    plot(params.odor_duration./params.sampleRate.*[1 1], [0 0.6], 'y--');


        %C
    subplot(2,4,6)
    errorbar_patch(timeVec, mean(Ctrials_PID), std(Ctrials_PID)./sqrt(size(Ctrials_PID,1)), clrArray(2,:))
    title(odorIdentities{2});
    xlabel('Time (sec)');ylabel('Evoked amplitude (V)')
    hold all;
    plot([0 0], [0 0.6], 'y--');
    plot(params.odor_duration./params.sampleRate.*[1 1], [0 0.6], 'y--');

        %T+
    subplot(2,4,7)
    errorbar_patch(timeVec, mean(Tplustrials_PID), std(Tplustrials_PID)./sqrt(size(Tplustrials_PID,1)), clrArray(4,:))
    title(odorIdentities{3});
    xlabel('Time (sec)');ylabel('Evoked amplitude (V)')
    hold all;
    plot([0 0], [0 0.6], 'y--');
    plot(params.odor_duration./params.sampleRate.*[1 1], [0 0.6], 'y--');

        %T-
    subplot(2,4,8)
    errorbar_patch(timeVec, mean(Tminustrials_PID), std(Tminustrials_PID)./sqrt(size(Tminustrials_PID,1)), clrArray(5,:))
    title(odorIdentities{4});
    xlabel('Time (sec)');ylabel('Evoked amplitude (V)')
    hold all;
    plot([0 0], [0 0.6], 'y--');
    plot(params.odor_duration./params.sampleRate.*[1 1], [0 0.6], 'y--');


    
elseif strcmpi(params.Two_or_one_odor_data, 'two')
    
    
    %% Extract PID data
    startingOdor  = odorTimes(:,1:2:end);% the first odor is the predicting odor
    PIDsignal = params.allChnls(params.PID, :);
    analysisWin = [-1000 params.ISIbetweenOdors + params.odor_duration*2 + 1000];
    allPIDtrials = [];
    for odorInd = 1:length(startingOdor)
        if odorInd==1
            allPIDtrials(odorInd,:) = nan(1,length([analysisWin(1):analysisWin(2)-1]));
        else
            allPIDtrials(odorInd,:) = PIDsignal(startingOdor(1,odorInd) + analysisWin(1):startingOdor(1,odorInd) + analysisWin(2)-1);
        end
    end
    %% Compute the mean PID signal per condition
    %----------- ANALYZE A TRIALS ----------------
    timeVec = [analysisWin(1):1:analysisWin(2)-1]./params.sampleRate;
    divideNum = 5;
    clrVec = {'b', 'r', 'g', 'm', 'c', 'y'};
    % figure;
    if ~isempty(params.targetTrials.A)
        A_T_trials = allPIDtrials(params.targetTrials.A,:);
        A_T_Minus_trials = allPIDtrials(params.tMinusTrials.A,:);
        %     subplot(3,4,1)
        %     hold all;
        %     patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        %     patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        %     errorbar_patch(timeVec, nanmean(A_T_trials), nanstd(A_T_trials)./sqrt(size(A_T_trials,1)), 'k');
        %     title('A -> T')
        %
        %     subplot(3,4,3)
        %     hold all;
        %     patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        %     patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        %     errorbar_patch(timeVec, nanmean(A_T_Minus_trials), nanstd(A_T_Minus_trials)./sqrt(size(A_T_Minus_trials,1)), 'k');
        %     title('A -> T-')
        
        subplot(3,2,1)
        hold all;
        patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        runPart = 1:length(params.targetTrials.A)/divideNum:length(params.targetTrials.A);
        for partInd = 1:length(runPart)-1
            errorbar_patch(timeVec, nanmean(A_T_trials(runPart(partInd):runPart(partInd+1),:)), nanstd(A_T_trials(runPart(partInd):runPart(partInd+1),:))./sqrt(size(A_T_trials(runPart(partInd):runPart(partInd+1),:),1)), clrVec{partInd});
            hold on;
        end
        title('A -> T')
        
        subplot(3,2,2)
        hold all;
        patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        runPart = 1:length(params.tMinusTrials.A)/divideNum:length(params.tMinusTrials.A);
        for partInd = 1:length(runPart)-1
            errorbar_patch(timeVec, nanmean(A_T_Minus_trials(runPart(partInd):runPart(partInd+1),:)), nanstd(A_T_Minus_trials(runPart(partInd):runPart(partInd+1),:))./sqrt(size(A_T_Minus_trials(runPart(partInd):runPart(partInd+1),:),1)), clrVec{partInd});
            hold on;
        end
        title('A -> T-')
    end
    %----------- ANALYZE B TRIALS ----------------
    if ~isempty(params.targetTrials.B)
        B_T_trials = allPIDtrials(params.targetTrials.B,:);
        B_T_Minus_trials = allPIDtrials(params.tMinusTrials.B,:);
        %     subplot(3,4,5)
        %     hold all;
        %     patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        %     patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        %     errorbar_patch(timeVec, nanmean(B_T_trials), nanstd(B_T_trials)./sqrt(size(B_T_trials,1)), 'k');
        %     title('B -> T')
        %
        %     subplot(3,4,6)
        %     hold all;
        %     patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        %     patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        %     errorbar_patch(timeVec, nanmean(B_T_Minus_trials), nanstd(B_T_Minus_trials)./sqrt(size(B_T_Minus_trials,1)), 'k');
        %     title('B -> T-')
        subplot(3,2,3)
        hold all;
        patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        runPart = 1:length(params.targetTrials.B)/divideNum:length(params.targetTrials.B);
        for partInd = 1:length(runPart)-1
            errorbar_patch(timeVec, nanmean(B_T_trials(runPart(partInd):runPart(partInd+1),:)), nanstd(B_T_trials(runPart(partInd):runPart(partInd+1),:))./sqrt(size(B_T_trials(runPart(partInd):runPart(partInd+1),:),1)), clrVec{partInd});
            hold on;
        end
        title('B -> T')
        
        subplot(3,2,4)
        hold all;
        patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        runPart = 1:length(params.tMinusTrials.B)/divideNum:length(params.tMinusTrials.B);
        for partInd = 1:length(runPart)-1
            errorbar_patch(timeVec, nanmean(B_T_Minus_trials(runPart(partInd):runPart(partInd+1),:)), nanstd(B_T_Minus_trials(runPart(partInd):runPart(partInd+1),:))./sqrt(size(B_T_Minus_trials(runPart(partInd):runPart(partInd+1),:),1)), clrVec{partInd});
            hold on;
        end
        title('B -> T-')
    end
    %----------- ANALYZE C TRIALS ----------------
    if ~isempty(params.targetTrials.A)
        C_T_trials = allPIDtrials(params.targetTrials.C,:);
        C_T_Minus_trials = allPIDtrials(params.tMinusTrials.C,:);
        %     subplot(3,4,9)
        %     hold all;
        %     patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        %     patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        %     errorbar_patch(timeVec, nanmean(C_T_trials), nanstd(C_T_trials)./sqrt(size(C_T_trials,1)), 'k');
        %     title('C -> T')
        %
        %     subplot(3,4,10)
        %     hold all;
        %     patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        %     patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        %     errorbar_patch(timeVec, nanmean(C_T_Minus_trials), nanstd(C_T_Minus_trials)./sqrt(size(C_T_Minus_trials,1)), 'k');
        %     title('C -> T-')
        subplot(3,2,5)
        hold all;
        patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        runPart = 1:length(params.targetTrials.C)/divideNum:length(params.targetTrials.C);
        for partInd = 1:length(runPart)-1
            errorbar_patch(timeVec, nanmean(C_T_trials(runPart(partInd):runPart(partInd+1),:)), nanstd(C_T_trials(runPart(partInd):runPart(partInd+1),:))./sqrt(size(C_T_trials(runPart(partInd):runPart(partInd+1),:),1)), clrVec{partInd});
            hold on;
        end
        title('C -> T')
        
        subplot(3,2,6)
        hold all;
        patch([2 3 3 2], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1)
        patch([0 1 1 0], [-1.4 -1.4 -0.2 -0.2],'k', 'FaceAlpha', 0.1);
        runPart = 1:length(params.tMinusTrials.C)/divideNum:length(params.tMinusTrials.C);
        for partInd = 1:length(runPart)-1
            errorbar_patch(timeVec, nanmean(C_T_Minus_trials(runPart(partInd):runPart(partInd+1),:)), nanstd(C_T_Minus_trials(runPart(partInd):runPart(partInd+1),:))./sqrt(size(C_T_Minus_trials(runPart(partInd):runPart(partInd+1),:),1)), clrVec{partInd});
            hold on;
        end
        title('C -> T-')
        
    end
end






