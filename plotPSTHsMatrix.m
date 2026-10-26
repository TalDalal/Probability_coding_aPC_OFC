clear;clc
load('allRecs_M2_PC_tetrodes.mat')
allPSTHs = [];
for recordInd = 1:size(allRecs,2)
    for ttInd = 1:size(allRecs(recordInd).data.NeuralData.Spikes,2)
        % Load the PSTH of each unit
        currTime = allRecs(recordInd).data.PSTHsAndRasters(ttInd).data.hit.A.PSTH(1,:);
        currResp = allRecs(recordInd).data.PSTHsAndRasters(ttInd).data.hit.A.PSTH(2,:);
        % Compute the bin
        PSTHbin = round(diff(allRecs(recordInd).data.PSTHsAndRasters(ttInd).data.hit.A.PSTH(1,1:5)),4);
        % compute the baselien activity
        endOfBaslinePeriod = (-allRecs(recordInd).data.ISIbetweenOdors-allRecs(recordInd).data.odor_duration)./1000;
        baselineFiring = currResp(find(currTime < endOfBaslinePeriod));
        % Convert to Z-score
        if ~isempty(baselineFiring)
            currResp = (currResp - mean(baselineFiring))./std(baselineFiring);
        end
        % Crop the PSTH for the requested time
        startOfPSTH = (-allRecs(recordInd).data.ISIbetweenOdors-allRecs(recordInd).data.odor_duration*2)./1000;
        endOfPSTH = (allRecs(recordInd).data.odor_duration*3)./1000;
        firstTimePoint = find(currTime >= startOfPSTH,1);
        if length(currResp) < round((endOfPSTH-startOfPSTH)./PSTHbin(1))
            continue;
        else
            currResp = currResp(firstTimePoint : firstTimePoint + round((endOfPSTH-startOfPSTH)./PSTHbin(1)));
        end
        % Save to a matrix of all PSTHs
        allPSTHs(end+1,:) = currResp;
    end
end
%Plot
timeVec = startOfPSTH:PSTHbin(1):endOfPSTH;
figure;
imagesc(timeVec,1:size(allPSTHs,1), allPSTHs)
caxis([-5 10])