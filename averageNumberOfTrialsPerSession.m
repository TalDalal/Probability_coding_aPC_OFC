
two_hept_is_H = [];EA_is_H = [];
% All mice from all experiments
[allMiceData] = concateMiceData([2 3 5 7 12 13 17 18 20 4 9 10 11 14 15 16]);% the number marks the mouse number
c = 0;
for mouseInd = 1:size(allMiceData,2)
    reversalVector = [];
    allRecs = allMiceData(mouseInd).allRecs;
    for recInd = 1:size(allRecs,2)
        if allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
            c = c+1;
            numOfTrials(c) = length(allMiceData(mouseInd).allRecs(recInd).data.trialsIndex);
            
            probData = allMiceData(mouseInd).allRecs(recInd).data.probability;
             if probData.A > probData.C
                 two_hept_is_H(end+1) = 1;
                 reversalVector(end+1) = 1;
             else
                 EA_is_H(end+1) = 1;
                 reversalVector(end+1) = 2;
             end
        end
            
    end
    if length(unique(reversalVector)) > 1
        reversalSession(mouseInd) = 1;
    else
       reversalSession(mouseInd) = 0;
    end
    
end
%% report mean trial number
meanNumTrials = mean(numOfTrials);
seNumOfTrials = std(numOfTrials);
disp(['Average # trials per session is ' num2str(meanNumTrials) ' +- ' num2str(seNumOfTrials) ', N = ' num2str(c) ' sessions'])

%% Report counterbalancing of H and L
disp([num2str(length(two_hept_is_H)) ' sessions with 2-heptanone as H, ' num2str(length(EA_is_H)) ' sessions with EA as H'])

%% Report in how many mice there was reversal
disp(['Reversal occured in ' num2str(sum(reversalSession)) ' mice'])