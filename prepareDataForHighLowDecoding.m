function [allTrialsMatrix,mouse_session_vec,SR_vec, minNumTrials, binaryResponseMat] = prepareDataForHighLowDecoding(analysisTimeWin, responsePvalTH)

% Assign the evoked trials activity for each condition across all neurons.
[alltrialsActivity, binaryResponseMat] = testTrialPartsSignificance(analysisTimeWin, responsePvalTH);
close;
% Fnd the minimal number of trials across all neurons for the decoder.
for trialsInd = 1:size(alltrialsActivity,2)
    minVal(trialsInd) = min(length(alltrialsActivity(trialsInd).A), length(alltrialsActivity(trialsInd).C)   );
    
    mouse_session_vec(trialsInd,:) = alltrialsActivity(trialsInd).sessionNum;
    
    SR_vec(trialsInd,:) = alltrialsActivity(trialsInd).successRates;

end
minNumTrials = min(minVal);

% Build the trials X neurons matrix, with randed  N trials
allTrialsMatrix = nan(minNumTrials*2, size(alltrialsActivity,2));
for trialsInd = 1:size(alltrialsActivity,2)
    
    randInds = randsample(minVal(trialsInd), minNumTrials);
    allTrialsMatrix(:,trialsInd) = [alltrialsActivity(trialsInd).A(randInds);alltrialsActivity(trialsInd).C(randInds)];
end