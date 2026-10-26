function [] = responseBreakdown(allMiceData, bgPeriod, fgPeriod, pValueTH, trialsIncluded,equalizeTrialNum)

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green

%% Get the sessions vals
[successRates] = getSuccessRatesForEachNeuron(allMiceData);
% Neurons recorded in naive and expert performance
srCriterion = 0.7;
meanSuccessRates = mean([successRates(:,2)';successRates(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';

%% Compute moving response rate

[activityMat_High, activityMat_Low, allTrialsActivity, ~, highFlag] = responondingNeuronsWithinATimeWindow(allMiceData, pValueTH, bgPeriod, fgPeriod, trialsIncluded, equalizeTrialNum);
close;

allActivityNaive = abs([activityMat_High(naiveInds);activityMat_Low(naiveInds)]);
allActivityExpert = abs([activityMat_High(expertInds);activityMat_Low(expertInds)]);

% Naive
noResponseRateNaive = length(find(sum(allActivityNaive)==0))./length(activityMat_High(naiveInds));
naiveOneOdorResponse = length(find(sum(allActivityNaive)==1))./length(activityMat_High(naiveInds));
naiveTwoOdorResponse = length(find(sum(allActivityNaive)==2))./length(activityMat_High(naiveInds));
SEnaive = binoDistSE([naiveOneOdorResponse naiveTwoOdorResponse], [length(activityMat_High(naiveInds)) length(activityMat_High(naiveInds))]);

%Expert
noResponseRateExpert = length(find(sum(allActivityExpert)==0))./length(activityMat_High(expertInds));
expertOneOdorResponse = length(find(sum(allActivityExpert)==1))./length(activityMat_High(expertInds));
expertTwoOdorResponse = length(find(sum(allActivityExpert)==2))./length(activityMat_High(expertInds));
SEexpert = binoDistSE([expertOneOdorResponse expertTwoOdorResponse], [length(activityMat_High(naiveInds)) length(activityMat_High(naiveInds))]);

SEnoResponse = binoDistSE([noResponseRateNaive noResponseRateExpert], [length(activityMat_High(naiveInds)) length(activityMat_High(naiveInds))]);


[~,PoneOdor] = prop_test([naiveOneOdorResponse.*length(activityMat_High(naiveInds)) expertOneOdorResponse.*length(activityMat_High(expertInds))], ...
    [length(activityMat_High(naiveInds)) length(activityMat_High(expertInds))], 'true');

[~,PtwoOdors] = prop_test([naiveTwoOdorResponse.*length(activityMat_High(naiveInds)) expertTwoOdorResponse.*length(activityMat_High(expertInds))], ...
    [length(activityMat_High(naiveInds)) length(activityMat_High(expertInds))], 'true');

% [p] = myChi2gof([49 62], [naiveOneOdorResponse naiveTwoOdorResponse])

figure;
errorbar([naiveOneOdorResponse naiveTwoOdorResponse], SEnaive)
hold on;
errorbar([expertOneOdorResponse expertTwoOdorResponse], SEexpert)
xlim([0.5 2.5]);set(gca, 'FontSize', 14);box off;set(gca, 'XTickLabel', {'One odor', 'Both odor'});xtickangle(45);
ylabel('Active neurons (%)')
title(['P-oneOdor = ' num2str(PoneOdor) ', P-twoOdors = ' num2str(PtwoOdors)])



figure;
errorbar([noResponseRateNaive noResponseRateExpert], SEnoResponse)
xlim([0.5 2.5]);set(gca, 'FontSize', 14);box off;set(gca, 'XTickLabel', {'One odor', 'Both odor'});xtickangle(45);
ylabel('Active neurons (%)')

%% Discriminative Neurons
binaryOdorResponseVec = logical(sum(abs([activityMat_High;activityMat_Low])));
discrimNeuronsVec = [];highDiscrimAmp = zeros(1, size(allTrialsActivity,2));
for trialInd = 1:size(allTrialsActivity,2)
    [hDiscrim,~] = ttest2(allTrialsActivity(trialInd).A, allTrialsActivity(trialInd).C);
    discrimNeuronsVec(trialInd) = hDiscrim.*binaryOdorResponseVec(trialInd);
    
    if discrimNeuronsVec(trialInd) > 0
        meanFRdiff = mean(abs(allTrialsActivity(trialInd).A)) - mean(abs(allTrialsActivity(trialInd).C));
        if meanFRdiff > 0
            if strcmpi(highFlag(trialInd), 'A')
                highDiscrimAmp(trialInd) = 1;
            end
        end
    end
    
    
end
naiveDiscrimRate = sum(discrimNeuronsVec(naiveInds))./length(naiveInds);
expertDiscrimRate = sum(discrimNeuronsVec(expertInds))./length(expertInds);

favorHighDiscrimRateNaive = length(intersect(find(highDiscrimAmp==1), naiveInds))./length(naiveInds);
favorHighDiscrimRateExpert = length(intersect(find(highDiscrimAmp==1), naiveInds))./length(naiveInds);



barData = [favorHighDiscrimRateNaive naiveDiscrimRate-favorHighDiscrimRateNaive;
        favorHighDiscrimRateExpert expertDiscrimRate-favorHighDiscrimRateExpert];


% Create the stacked bar plot
figure;
bar(barData, 'stacked');
xlim([0.5 2.5]);set(gca, 'FontSize', 14);box off;set(gca, 'XTickLabel', {'Naive', 'Expert'});xtickangle(45);
ylabel('Discriminative neurons (%)');
ylim([0 .4])


SEdicrimNaiveExpert = binoDistSE([naiveDiscrimRate expertDiscrimRate], [length(naiveInds) length(expertInds)]);

figure;
errorbar([naiveDiscrimRate expertDiscrimRate], SEdicrimNaiveExpert)
xlim([0.5 2.5]);set(gca, 'FontSize', 14);box off;set(gca, 'XTickLabel', {'Naive', 'Expert'});xtickangle(45);
ylabel('Discriminative neurons (%)');
ylim([0 .4])


x=(discrimNeuronsVec(expertInds).*sum(allActivityExpert))
y=(discrimNeuronsVec(naiveInds).*sum(allActivityNaive))

