clear;clc
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number
mouseData = allMiceData(1).allRecs;
Aflag = 1;Acolor = 'r';
Cflag = 3;Ccolor = 'm';
winSize = 30;

%% Sort the data by the session number (according to training days)
sessionNum = [];
for recInd = 1:size(mouseData,2)
    sessionNum(recInd) = mouseData(recInd).sessionNum;
end
[~, sessNumInds] = sort(sessionNum);
mouseData = mouseData(sessNumInds);

%% get the trial label and trial outcome
trialTypeOutcome = [];
for recInd = 1:size(mouseData,2)
    trialTypeOutcome = [trialTypeOutcome [mouseData(recInd).data.trialsIndex;mouseData(recInd).data.lickIndicator]];
end

% Sort the data by trial type
csPlusTrialsA = find(trialTypeOutcome(1,:) == Aflag);
csMinusTrialsA = find(trialTypeOutcome(1,:) == -Aflag);

csPlusTrialsC = find(trialTypeOutcome(1,:) == Cflag);
csMinusTrialsC = find(trialTypeOutcome(1,:) == -Cflag);

%% Hit loops
%A
for trialInd = 1:size(csPlusTrialsA,2)-winSize
    currBinHitRateA(trialInd) = length(find(trialTypeOutcome(2,csPlusTrialsA(trialInd:trialInd+winSize-1)) == 1))./winSize;
end

%C
for trialInd = 1:size(csPlusTrialsC,2)-winSize
    currBinHitRateC(trialInd) = length(find(trialTypeOutcome(2,csPlusTrialsC(trialInd:trialInd+winSize-1)) == 1))./winSize;
end

%% Fa loops
%A
for trialInd = 1:size(csMinusTrialsA,2)-winSize
    currBinFARateA(trialInd) = length(find(trialTypeOutcome(2,csMinusTrialsA(trialInd:trialInd+winSize-1)) == 1))./winSize;
end

%C
for trialInd = 1:size(csMinusTrialsC,2)-winSize
    currBinFARateC(trialInd) = length(find(trialTypeOutcome(2,csMinusTrialsC(trialInd:trialInd+winSize-1)) == 1))./winSize;
end

figure;
plot(currBinHitRateA, Acolor)
hold on;
plot(currBinHitRateC, Ccolor)

%%
% movingSuccessRateA = [];movingSuccessRateC = [];
% for trialInd = 1:size(trialTypeOutcome,2)-winSize
%     currTrials = trialInd : trialInd + winSize -1;
%     %A trials in the current window
%     csPlusTrialsA = find(trialTypeOutcome(1,currTrials) == Aflag);
%     currBinHit = sum(trialTypeOutcome(2,currTrials(csPlusTrialsA)) == 1)./length(csPlusTrialsA);
%     
%     csMinusTrialsA = find(trialTypeOutcome(1,currTrials) == -Aflag);
%     currBinFA = sum(trialTypeOutcome(2,currTrials(csMinusTrialsA)) == 1)./length(csMinusTrialsA);
%     
%     %Compute the moving SR
%     movingSuccessRateA(end+1) = (currBinHit + (1 - currBinFA))./2;
%     currBinHit = [];currBinFA = [];
%     %C trials in the current window
%     csPlusTrialsC = find(trialTypeOutcome(1,currTrials) == Cflag);
%     currBinHit = sum(trialTypeOutcome(2,currTrials(csPlusTrialsC)) == 1)./length(csPlusTrialsC);
%     
%     csMinusTrialsC = find(trialTypeOutcome(1,currTrials) == -Cflag);
%     currBinFA = sum(trialTypeOutcome(2,currTrials(csMinusTrialsC)) == 1)./length(csMinusTrialsC);
%     
%     %Compute the moving SR
%     movingSuccessRateC(end+1) = (currBinHit + (1 - currBinFA))./2;
% 
%     
%     
% end
% 
% figure;
% plot(movingSuccessRateA, Acolor)
% hold on;
% plot(movingSuccessRateC, Ccolor)
% find(movingSuccessRateA >= .8,10)
% find(movingSuccessRateC >= .8,10)


