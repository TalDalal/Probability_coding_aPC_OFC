function [] = decode_identity_high_vs_Low_odors_Early_VS_Late_sessions(analysisTimeWin, sessionPercentileORcriterionMethod, respondingNeuronsOnly)

%Prepare the data
[allTrialsMatrix,mouse_session_vec, SR_vec, minNumTrials, binaryResponseMat] = prepareDataForHighLowDecoding(analysisTimeWin, 0.01);
%Neurons that responded to both codors
both_Response = find(binaryResponseMat(:,1) > 0 & binaryResponseMat(:,2) > 0);


% Labels (High or low probaiblity odor)
labels = [zeros(1,minNumTrials), ones(1,minNumTrials)]';
%Shuffled
shuffLabels = randsample(labels, length(labels));

%--------------------Divide the data for naive and expert either by
%'sessionPercentile' = according to the percentile of sessions, or by
%'criterionMethod' = neurons that were recorded above or below criterion.
if strcmpi(sessionPercentileORcriterionMethod, 'sessionPercentile')
    
    %find the percentile of the seesions from all neurons and mice.
    percentileSessionsVec = [];
    miceInAnalysis = unique(mouse_session_vec(:,1));
    for sessInd = 1:length(miceInAnalysis)
        %Find the relevant seesiosn
        tmpSessions = mouse_session_vec(find(mouse_session_vec(:,1) == miceInAnalysis(sessInd)),2);
        %Normalize by the maximal # sessions
        tmpSessions = tmpSessions./max(tmpSessions);
        %Assign
        percentileSessionsVec  = [percentileSessionsVec ; tmpSessions];
    end
    firstSessions = find(percentileSessionsVec < 0.3);
    lateSessions = find(percentileSessionsVec >= 0.7);
    
    if true(respondingNeuronsOnly)
        firstSessions = intersect(firstSessions, both_Response);
        lateSessions = intersect(lateSessions, both_Response);
    end
    
    
    earlyLateArray{1} = firstSessions;
    earlyLateArray{2} = lateSessions;
    
elseif strcmpi(sessionPercentileORcriterionMethod, 'criterionMethod')
    
    %Neurons recorded in naive and expert performance
    srCriterion = 0.8;
    meanSuccessRates = mean([SR_vec(:,2)';SR_vec(:,3)']);
    naiveInds = find( meanSuccessRates< srCriterion)';
    expertInds = find(meanSuccessRates >= srCriterion)';
    
    if true(respondingNeuronsOnly)
        naiveInds = intersect(naiveInds, both_Response);
        expertInds = intersect(expertInds, both_Response);
    end
        
    
    earlyLateArray{1} = naiveInds;
    earlyLateArray{2} = expertInds;
end
% Find the min # neurons to equalize
minNeuronsInCondition = min(length(earlyLateArray{1}), length(earlyLateArray{2}));



%Number of bootstrap reps.
bootstrapIterNum = 1000;
meanSRandSTD_SHUFF = [];meanSRandSTD = [];

for earlyLateInd = 1:size(earlyLateArray,2)
    
    for bootInd = 1:bootstrapIterNum
        
        currIndices = earlyLateArray{earlyLateInd};
        
        %In case the the number of neurons is not equal, equalize it.
%             currIndices = randsample(currIndices,minNeuronsInCondition);

        currTrialsMat = allTrialsMatrix(:,currIndices);
        data = currTrialsMat(:,randsample(size(currTrialsMat,2), size(currTrialsMat,2), 'true'));
        
        %Decode
        [successRate, ~] = leaveOneOut_cross_validation_high_or_low_odors(data, labels, 100);
        allSRs(bootInd) = successRate;
        
        %Shuffled
        [successRateSHUFF, ~] = leaveOneOut_cross_validation_high_or_low_odors(data, shuffLabels, 100);
        allSRsSHUFF(bootInd) = successRateSHUFF;
        
        
        
    end
    
    meanSRandSTD(earlyLateInd,:) = [mean(allSRs) ; std(allSRs)];
    
    meanSRandSTD_SHUFF(earlyLateInd,:) = [mean(allSRsSHUFF) ; std(allSRsSHUFF)];
end
%% Plot
classifColor = [2,0,121]./255;
figure;
e1 = errorbar(1:2,meanSRandSTD(:,1), meanSRandSTD(:,2), 'ko-', 'LineWidth', 2);
e1.Color = classifColor;

hold all;
e2 = errorbar(1:2,meanSRandSTD_SHUFF(:,1), meanSRandSTD_SHUFF(:,2), 'ko--', 'LineWidth', 2);
e2.Color = [.5 .5 .5];

plot([0 3], [.5 .5], 'k--')
set(gca, 'FontSize', 14');box off;
legend('High vs. Low prob.', 'shuffled', 'chance')
set(gca, 'XTickLabel', '')
title(['N = ' num2str(minNeuronsInCondition)])
ylim([0 1])