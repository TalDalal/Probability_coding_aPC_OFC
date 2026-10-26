function [alltrialsActivity, responseMatPredOdor] = testTrialPartsSignificance(allMiceData, analysisTimeWin, pValueTH)
% [allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

responseMatPredOdor = [];
responseMatWait = [];
FRmatPredOdor = [];
c = 0;
srCriterion = 0.8;
beforeTrialStartTime = -2;
CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
% pValueTH = 0.01;
%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            ISI = mouseData(recInd).data.ISIbetweenOdors./1000;
            odorDuration = mouseData(recInd).data.odor_duration./1000;
            Atrials = mouseData(recInd).data.Atrials;
            Ctrials = mouseData(recInd).data.Ctrials;
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                %Record the session num
                alltrialsActivity(c).sessionNum  = [miceInd mouseData(recInd).sessionNum];
                alltrialsActivity(c).successRates  = [miceInd mouseData(recInd).data.successRate.A ...
                    mouseData(recInd).data.successRate.C];
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                FRmatPredOdor(c,:) = nan(1,2);
                
                
                % A trials
                Amat = currFRmat(Atrials,:);
                %Baseline
                bgFR = mean(Amat(:,find(timeBins < beforeTrialStartTime)),2);
                % PredictingOdor
                predictingOdorFR = mean(Amat(:,find(timeBins >= analysisTimeWin(1) & timeBins < analysisTimeWin(2))),2);
%                 predictingOdorFR = mean(Amat(:,find(timeBins >= -(ISI+odorDuration) & timeBins < -ISI)),2);
%                 %ISI
%                 waitBetweenOdors = mean(Amat(:,find(timeBins >= -ISI & timeBins < 0)),2);
                
                %Save the evoked FR
                FRmatPredOdor(c,1) = mean(predictingOdorFR - mean(bgFR));
                
                % Save the firing rate in each trials
                alltrialsActivity(c).A = predictingOdorFR - bgFR;
                
                %STAT
                [predOdorA] = signrank(bgFR, predictingOdorFR);
%                 [waitA] = signrank(bgFR, waitBetweenOdors);
                bgFR = [];predictingOdorFR = [];waitBetweenOdors = [];
                
                % C trials
                Cmat = currFRmat(Ctrials,:);
                %Baseline
                bgFR = mean(Cmat(:,find(timeBins < beforeTrialStartTime)),2);
                % PredictingOdor
                predictingOdorFR = mean(Cmat(:,find(timeBins >= analysisTimeWin(1) & timeBins < analysisTimeWin(2))),2);
%                 predictingOdorFR = mean(Cmat(:,find(timeBins >= -(ISI+odorDuration) & timeBins < -ISI)),2);
%                 %ISI
%                 waitBetweenOdors = mean(Cmat(:,find(timeBins >= -ISI & timeBins < 0)),2);
                
                %Save the evoked FR
                FRmatPredOdor(c,2) = mean(predictingOdorFR - mean(bgFR));
                
                % Save the firing rate in each trials
                alltrialsActivity(c).C = predictingOdorFR - bgFR;
                
                %STAT
                [predOdorC] = signrank(bgFR, predictingOdorFR);
%                 [waitC] = signrank(bgFR, waitBetweenOdors);
                 bgFR = [];predictingOdorFR = [];waitBetweenOdors = [];
                
                 % Assign the response into the matrix
                 responseMatPredOdor(c,:) = zeros(1,2);
                if predOdorA < pValueTH
                    responseMatPredOdor(c,1) = -log10(predOdorA);
                end
                if predOdorC < pValueTH
                    responseMatPredOdor(c,2) = -log10(predOdorC);
                end
                
                % Assign the response into the matrix
%                  responseMatWait(c,:) = zeros(1,2);
%                 if waitA < pValueTH
%                     responseMatWait(c,1) = -log10(waitA);
%                 end
%                 if waitC < pValueTH
%                     responseMatWait(c,2) = -log10(waitC);
%                 end
            end
        end
    end
end

% Sort the predicting odor responses by classes.
noResponse = find(sum(responseMatPredOdor,2) == 0);
A_Response = find(responseMatPredOdor(:,1) > 0 & responseMatPredOdor(:,2) == 0);
C_Response = find(responseMatPredOdor(:,1) == 0 & responseMatPredOdor(:,2) > 0);
both_Response = find(responseMatPredOdor(:,1) > 0 & responseMatPredOdor(:,2) > 0);

% sortedIndsPredOdor = [noResponse;A_Response;C_Response;both_Response];
sortedMat = [responseMatPredOdor(noResponse,:) ; sort(responseMatPredOdor(A_Response,:)); ...
    sort(responseMatPredOdor(C_Response,:)); sort(responseMatPredOdor(both_Response,:))];

percentresponseA = (length(find(responseMatPredOdor(:,1) > 0))./size(responseMatPredOdor,1));
percentresponseC = (length(find(responseMatPredOdor(:,2) > 0))./size(responseMatPredOdor,1));

%----------- Divide for naive and expert trials -------
for trialsInd = 1:size(alltrialsActivity,2)
    SR_vec(trialsInd,:) = alltrialsActivity(trialsInd).successRates;
end

meanSuccessRates = mean([SR_vec(:,2)';SR_vec(:,3)']);
naiveInds = find( meanSuccessRates< srCriterion)';
expertInds = find(meanSuccessRates >= srCriterion)';

naiveResponseMat = responseMatPredOdor(naiveInds,:);
expertResponseMat = responseMatPredOdor(expertInds,:);

%------ % responding cells for naive and expert --------
percentResponseNaiveA = (length(find(naiveResponseMat(:,1) > 0))./size(naiveResponseMat,1));
percentResponseNaiveC = (length(find(naiveResponseMat(:,2) > 0))./size(naiveResponseMat,1));
%stat
[~,pNaive]=prop_test([length(find(naiveResponseMat(:,1) > 0)) length(find(naiveResponseMat(:,2) > 0))], ...
    [size(naiveResponseMat,1) size(naiveResponseMat,1)], false)

percentResponseExpertA = (length(find(expertResponseMat(:,1) > 0))./size(expertResponseMat,1));
percentResponseExpertC = (length(find(expertResponseMat(:,2) > 0))./size(expertResponseMat,1));
%stat
[~,pExpert]=prop_test([length(find(expertResponseMat(:,1) > 0)) length(find(expertResponseMat(:,2) > 0))], ...
    [size(expertResponseMat,1) size(expertResponseMat,1)], false)

%stat high naive VS high expert
[~,pHighNaiveVSexpert]=prop_test([length(find(expertResponseMat(:,1) > 0)) length(find(naiveResponseMat(:,1) > 0))], ...
    [size(expertResponseMat,1) size(naiveResponseMat,1)], false)

%stat low naive VS high expert
[~,pLowNaiveVSexpert]=prop_test([length(find(expertResponseMat(:,2) > 0)) length(find(naiveResponseMat(:,2) > 0))], ...
    [size(expertResponseMat,1) size(naiveResponseMat,1)], false)

disp(['P high VS low naive = ' num2str(pNaive) ', P high VS low expert = ' num2str(pExpert) ...
    ', P high naive VS high expert = ' num2str(pHighNaiveVSexpert) ', P low naive VS high expert = ' num2str(pLowNaiveVSexpert)])
performaceTitles = {'naive', 'expert'};
%---------- Significance map ------------
figure;
subplot(1,4,1)
% imagesc(responseMatPredOdor(sortedIndsPredOdor,:))
imagesc(sortedMat);
% colormap('pink')
crameri oslo
% title('Predicting odor')
hcb = colorbar;
set(get(hcb,'label'),'string','-Log (P)','Rotation',270);
set(gca, 'XTickLabel', {'High ', 'Low'});
set(gca, 'FontSize', 14');box off;
ylabel('Neurons')
title(['Analysis window: ' num2str(analysisTimeWin(1)) ' ' num2str(analysisTimeWin(2)) ' sec'])
caxis([-log10(pValueTH) max(max(sortedMat))])

%---------Percent responding neurons for naive and expert ----------
subplot(1,4,2:3)
naiveSE = [sqrt(size(naiveResponseMat,1)*percentResponseNaiveA*(1-percentResponseNaiveA))./100 ...
    sqrt(size(naiveResponseMat,1)*percentResponseNaiveC*(1-percentResponseNaiveC))./100];
naivePercent = [percentResponseNaiveA percentResponseNaiveC];


expertSE = [sqrt(size(expertResponseMat,1)*percentResponseExpertA*(1-percentResponseExpertA))./100 ...
    sqrt(size(expertResponseMat,1)*percentResponseExpertC*(1-percentResponseExpertC))./100];
expertPercent = [percentResponseExpertA percentResponseExpertC];

% dataForBar = [naivePercent ; expertPercent].*100;
% b = bar(dataForBar);
% b(1).FaceColor = 'flat';
% b(1).CData = ones(size(dataForBar,1),3).*AColor;
% b(2).FaceColor = 'flat';
% b(2).CData = ones(size(dataForBar,1),3).*CColor;
% set(gca, 'XTickLabel', {'Naive', 'Expert'})

barwitherr([naiveSE expertSE], [naivePercent expertPercent])
ylabel('Active neurons (%)');set(gca, 'FontSize', 18);box off;


% barwitherr([naiveSE expertSE], [naivePercent expertPercent]);
% set(gca, 'XTickLabel', {'High ', 'Low '});
% set(gca, 'FontSize', 14');box off;
% ylabel('Prop. responding neurons')
% ylim([0 1])
% title(['P naive = ' num2str(pNaive) '; P = ' num2str(pExpert)])
% xlabel('Naive')


bothOdrsResponded = FRmatPredOdor(both_Response,:);

bothOdrsRespondedNaive = FRmatPredOdor(intersect(naiveInds,  both_Response),:);
bothOdrsRespondedExpert = FRmatPredOdor(intersect(expertInds,  both_Response),:);

% naiveExcInds = find(bothOdrsRespondedNaive(:,2) > 0 |  bothOdrsRespondedNaive(:,1) > 0);
% excitatoryNaiveDelta = bothOdrsRespondedNaive(naiveExcInds,1) - bothOdrsRespondedNaive(naiveExcInds,2);
% 
% expertExcInds = find(bothOdrsRespondedExpert(:,2) > 0 |  bothOdrsRespondedExpert(:,1) > 0);
% excitatoryExpertDelta = bothOdrsRespondedExpert(expertExcInds,1) - bothOdrsRespondedExpert(expertExcInds,2);

naiveColor = [72, 105, 225]./255;
expertColor = [255, 192, 161]./255;

subplot(1,4,4)
lineCoors = [-15 25];
hold all;
% scatter(bothOdrsResponded(:,2), bothOdrsResponded(:,1),20, 'k', 'filled')
scatter(bothOdrsRespondedNaive(:,2), bothOdrsRespondedNaive(:,1),20, 'filled', 'MarkerFaceColor', naiveColor, 'MarkerEdgeColor', naiveColor)
% hl = lsline;hl.Color = naiveColor;
scatter(bothOdrsRespondedExpert(:,2), bothOdrsRespondedExpert(:,1),20, 'filled', 'MarkerFaceColor', expertColor, 'MarkerEdgeColor', expertColor)
% hl2 = lsline;hl2.Color = expertColor;
plot(lineCoors, lineCoors, 'k--')
set(gca, 'FontSize', 14');box off;
xlabel('Low (25%) (Hz) ');
ylabel(' High (75%) (Hz)');
xlim(lineCoors);ylim(lineCoors)


%Perform stats over excitatory and inhibitory odor responses
excInds = find(bothOdrsResponded(:,2) > 0 | bothOdrsResponded(:,1) > 0);
excitatoryBothResponses = bothOdrsResponded(excInds,:);

[~,pExc] = ttest(excitatoryBothResponses(:,1), excitatoryBothResponses(:,2));

inhInds = find(bothOdrsResponded(:,2) <= 0 | bothOdrsResponded(:,1) <= 0);
inhibitoryBothResponses = bothOdrsResponded(inhInds,:);

[~,pInh] = ttest(inhibitoryBothResponses(:,1), inhibitoryBothResponses(:,2));

title(['N = ' num2str(length(both_Response)) ', P-exc = ' num2str(pExc) ', inh = ' num2str(pInh)])


                
                
            
    