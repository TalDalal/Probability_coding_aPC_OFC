function [responseMat_High, responseMat_Low, allTrialsActivity, auROCstruct, highFlag] = responondingNeuronsWithinATimeWindow(allMiceData, pValueTH,bgPeriod, fgPeriod, trialsType, equalizeTrialNum, brainRegion)

c = 0;

lowProbColor = [171,62,143]./255;%purple
highProbColor = [0,169,137]./255;%green
auROCWinSize = 300;%ms

% lowCount = 0;
% highCount = 0;
%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
            
            Atrials = mouseData(recInd).data.Atrials;
            A_CS_plus_trials = mouseData(recInd).data.targetTrials.A;
            A_CS_minus_trials = mouseData(recInd).data.tMinusTrials.A;
            
            Ctrials = mouseData(recInd).data.Ctrials;
            C_CS_plus_trials = mouseData(recInd).data.targetTrials.C;
            C_CS_minus_trials = mouseData(recInd).data.tMinusTrials.C;
            
            if strcmpi(equalizeTrialNum, 'equalize')
                %-------CS+
                %Find the minimal trialNum
                minCSplusTrialNum = min(length(A_CS_plus_trials), length(C_CS_plus_trials));
                %Rand trials
               A_CS_plus_trials = sort(randsample(A_CS_plus_trials, minCSplusTrialNum));
               C_CS_plus_trials = sort(randsample(C_CS_plus_trials, minCSplusTrialNum));
               
               %-------CS-
                %Find the minimal trialNum
                minCSminusTrialNum = min(length(A_CS_minus_trials), length(C_CS_minus_trials));
                %Rand trials
               A_CS_minus_trials = sort(randsample(A_CS_minus_trials, minCSminusTrialNum));
               C_CS_minus_trials = sort(randsample(C_CS_minus_trials, minCSminusTrialNum));
            end
                
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            

            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= bgPeriod(1) & timeBins < bgPeriod(2));
                fgDuration = find(timeBins >= fgPeriod(1) & timeBins < fgPeriod(2));
                
                %% ---------------------- A trials--------------------------
                
                switch trialsType
                    case 'allTrials'
                        Amat = currFRmat(Atrials,:);
                        
                        %Baseline
                        bgFR_A = mean(Amat(:,baselineDuration),2);
                        % fg period
                        fgFR_A = mean(Amat(:,fgDuration),2);
     
                        
                    case 'CS+'% CS + Odor
                        
                        %Baseline
                        bgFR_A = mean(currFRmat(A_CS_plus_trials,baselineDuration),2);
                        % fg period
                        fgFR_A = mean(currFRmat(A_CS_plus_trials,fgDuration),2);
                        
                    case 'CS-' % CS - Odor
                        
                        %Baseline
                        bgFR_A = mean(currFRmat(A_CS_minus_trials,baselineDuration),2);
                        % fg period
                        fgFR_A = mean(currFRmat(A_CS_minus_trials,fgDuration),2);
                        
                end
                %--- Stat ----
                [h,~] = ttest(bgFR_A, fgFR_A, 'alpha', pValueTH);
                % In case of inhibitory response
                if mean(fgFR_A) < mean(bgFR_A)
                    h = h*-1;
                end
                
                currResponseFlag_A = h;
                allTrialsActivity(c).A = fgFR_A - bgFR_A;
                clear h
                
      
                %% ----------------- C trials------------------------
                
                switch trialsType
                    case 'allTrials'
                        Cmat = currFRmat(Ctrials,:);
                        
                        %Baseline
                        bgFR_C = mean(Cmat(:,baselineDuration),2);
                        % fg period
                        fgFR_C = mean(Cmat(:,fgDuration),2);
  
                        
                    case 'CS+'% CS + Odor
                        %Baseline
                        bgFR_C = mean(currFRmat(C_CS_plus_trials,baselineDuration),2);
                        % fg period
                        fgFR_C = mean(currFRmat(C_CS_plus_trials,fgDuration),2);

                        
                    case 'CS-'% CS - Odor
                        %Baseline
                        bgFR_C = mean(currFRmat(C_CS_minus_trials,baselineDuration),2);
                        % fg period
                        fgFR_C = mean(currFRmat(C_CS_minus_trials,fgDuration),2);

                end
                
                %---- Stat
                [h,~] = ttest(bgFR_C, fgFR_C, 'alpha', pValueTH);
                % In case of inhibitory response
                if mean(fgFR_C) < mean(bgFR_C)
                    h = h*-1;
                end
                
                currResponseFlag_C = h;
                allTrialsActivity(c).C = fgFR_C - bgFR_C;
                clear h
                
                %% ----------- Compute auROC ----------
                params = mouseData(recInd).data;
                
                % baseline period for the ROC
                rocBgWin = [-params.odor_duration-params.ISIbetweenOdors-2000 ...
                    -params.odor_duration-params.ISIbetweenOdors]./1000;
                
                switch trialsType
                    case 'allTrials'
                        rocFgTrialsA = Atrials;
                        rocFgTrialsC = Ctrials;
                    case 'CS+'
                        rocFgTrialsA = A_CS_plus_trials;
                        rocFgTrialsC = C_CS_plus_trials;
                    case 'CS-'
                        rocFgTrialsA = A_CS_minus_trials;
                        rocFgTrialsC = C_CS_minus_trials;
                end
                
                [auROC_A, timeBins] = compute_auROC(params, currFRmat, rocBgWin, rocFgTrialsA, auROCWinSize);
                [auROC_C, timeBins] = compute_auROC(params, currFRmat, rocBgWin, rocFgTrialsC, auROCWinSize);
                

                
                
                %% ------ Assign the response flag by probability ------
                responseMat_High(c) = nan;responseMat_Low(c) = nan;
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    highFlag{c} = 'A';
%                     highCount = highCount + 1;
                    responseMat_High(c) = currResponseFlag_A;
                    responseMat_Low(c) = currResponseFlag_C;
                    
                    auROC_Mat_High(c,:) = auROC_A;
                    auROC_Mat_Low(c,:) = auROC_C;
                    
                    ROCvaluesForSorting_High(c) = mean(auROC_A(find(timeBins >= fgPeriod(1) & timeBins < fgPeriod(2))));
                    ROCvaluesForSorting_Low(c) = mean(auROC_C(find(timeBins >= fgPeriod(1) & timeBins < fgPeriod(2))));
                
                else
                    highFlag{c} = 'C';
%                     lowCount = lowCount + 1;
                    responseMat_High(c) = currResponseFlag_C;
                    responseMat_Low(c) = currResponseFlag_A;
                    
                    auROC_Mat_High(c,:) = auROC_C;
                    auROC_Mat_Low(c,:) = auROC_A;
                    
                    ROCvaluesForSorting_High(c) = mean(auROC_C(find(timeBins >= fgPeriod(1) & timeBins < fgPeriod(2))));
                    ROCvaluesForSorting_Low(c) = mean(auROC_A(find(timeBins >= fgPeriod(1) & timeBins < fgPeriod(2))));
                end
                
                
                
            end
        end
    end
end
%--- auROC struct--
auROCstruct.High = auROC_Mat_High;
auROCstruct.Low = auROC_Mat_Low;
auROCstruct.timeBins = timeBins;
auROCstruct.ROCvaluesForSorting_High = ROCvaluesForSorting_High;
auROCstruct.ROCvaluesForSorting_Low = ROCvaluesForSorting_Low;

%Avoid nans
responseMat_High(isnan(responseMat_High)) = 0;
responseMat_Low(isnan(responseMat_Low)) = 0;

%-Excitation stats
[~,p_exc] = prop_test([length(find(responseMat_High==1)) length(find(responseMat_Low==1))], ...
    [size(responseMat_High,2) size(responseMat_Low,2)], 'true');
%-Inhibition stats
[~,p_inh] = prop_test([length(find(responseMat_High==-1)) length(find(responseMat_Low==-1))], ...
    [size(responseMat_High,2) size(responseMat_Low,2)], 'true');
%-All together stats
[~,p_All] = prop_test([sum(abs(responseMat_High)) sum(abs(responseMat_Low))], ...
    [size(responseMat_High,2) size(responseMat_Low,2)], 'true');

%Compute response rates
%all
allResponseRate_High = sum(abs(responseMat_High))./size(responseMat_High,2);
allResponseRate_Low = sum(abs(responseMat_Low))./size(responseMat_Low,2);

%Excitation
excRate_High = length(find(responseMat_High==1))./size(responseMat_High,2);
excRate_Low = length(find(responseMat_Low==1))./size(responseMat_Low,2);

%Inh
inhRate_High = length(find(responseMat_High==-1))./size(responseMat_High,2);
inhRate_Low = length(find(responseMat_Low==-1))./size(responseMat_Low,2);

[responseRateSE] = binoDistSE([allResponseRate_High, allResponseRate_Low, ... 
                               excRate_High, excRate_Low, ... 
                               inhRate_High, inhRate_Low], ...
                               [size(responseMat_High,2) size(responseMat_Low,2), ...
                               size(responseMat_High,2) size(responseMat_Low,2), ...
                               size(responseMat_High,2) size(responseMat_Low,2)]);
figure;
barwitherr(responseRateSE.*100, [allResponseRate_High, allResponseRate_Low, ... 
                               excRate_High, excRate_Low, ... 
                               inhRate_High, inhRate_Low].*100)
    
% b = bar(dataForBar);
% b.FaceColor = 'flat';
% b.CData(1,:) = highProbColor; b.CData(2,:) = lowProbColor;
% b.CData(3,:) = highProbColor; b.CData(4,:) = lowProbColor;
% b.CData(5,:) = highProbColor; b.CData(6,:) = lowProbColor;
set(gca, 'XTickLabel', {'All_H', 'All_L', 'Exc_H', 'Exc_L', 'Inh_H', 'Inh_L'})
title(['P-All = ' num2str(round(p_All,5)) ', P-Exc = ' num2str(round(p_exc, 5)) ', P-Inh = ' num2str(round(p_inh, 5))])
ylabel('Active neurons (%)');set(gca, 'FontSize', 18);box off;
ylim([0 100])


