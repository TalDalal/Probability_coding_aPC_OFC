function [activityMatrix] = computeCSodorsActivity(allMiceData, bgPeriod, fgPeriod, srCriterion, brainRegion)


if nargin < 5
    brainRegion = 'PC';
end

c = 0;
activityMatrix = [];

%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
           
            CS_plus_trials = [mouseData(recInd).data.targetTrials.A  mouseData(recInd).data.targetTrials.C];
            CS_minus_trials = [mouseData(recInd).data.tMinusTrials.A mouseData(recInd).data.tMinusTrials.C];
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
            currSuccessRate = mean([mouseData(recInd).data.successRate.A mouseData(recInd).data.successRate.A]);

            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= bgPeriod(1) & timeBins <= bgPeriod(2));
                fgDuration = find(timeBins >= fgPeriod(1) & timeBins <= fgPeriod(2));
                
%%                      %CS+
                        odorDuration_fr_CSplus = mean(currFRmat(CS_plus_trials,fgDuration),2);
                        
                        baselineActivityfr_CSplus = mean(currFRmat(CS_plus_trials,baselineDuration),2);
                        

                         %CS-                       
                        odorDuration_fr_CSminus = mean(currFRmat(CS_minus_trials,fgDuration),2);
                        
                        baselineActivity_fr_CSminus = mean(currFRmat(CS_minus_trials,baselineDuration),2);
                
                
                %--- Stat ----
                                
                csPlus_response = [];csMinus_response = [];
                % Test for odor response
                [csPlus_response,~] = ttest(odorDuration_fr_CSplus, baselineActivityfr_CSplus);
                [csminus_response,~] = ttest(odorDuration_fr_CSminus, baselineActivity_fr_CSminus);
                
                if isequal(csPlus_response,1) | isequal(csminus_response,1)
                    numOfRespondingNeurons(c) = 1;
                    
                    CS_plus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(CS_plus_trials);
                    CS_minus_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(CS_minus_trials);
                    
                    % Compute evoked z-score
                    [zCSplus] = computeZscorefromRaster(CS_plus_raster, bgPeriod, fgPeriod);
                    [zCSminus] = computeZscorefromRaster(CS_minus_raster, bgPeriod, fgPeriod);
                    
                    activityMatrix(end+1,:) = [zCSplus zCSminus currSuccessRate];
                end

               
                
                
                
                
            end
        end
    end
end

%% divide to naive and expert
 activityMatrix(isinf(activityMatrix),:) = [];

naiveMatrix = activityMatrix(find(activityMatrix(:,3) < srCriterion),1:2);
expertMatrix = activityMatrix(find(activityMatrix(:,3) > srCriterion),1:2);

%Divide to exc and inh
excData{1} = naiveMatrix(find(naiveMatrix(:,1) > 0),1);
excData{2} = naiveMatrix(find(naiveMatrix(:,2) > 0),2);
excData{3} = expertMatrix(find(expertMatrix(:,1) > 0),1);
excData{4} = expertMatrix(find(expertMatrix(:,2) > 0),2);

inhData{1} = naiveMatrix(find(naiveMatrix(:,1) < 0),1);
inhData{2} = naiveMatrix(find(naiveMatrix(:,2) < 0),2);
inhData{3} = expertMatrix(find(expertMatrix(:,1) < 0),1);
inhData{4} = expertMatrix(find(expertMatrix(:,2) < 0),2);

%% Stat
%naive
[~,pNaiveExc] = ttest2(excData{1}, excData{2});
[~,pExpertExc] = ttest2(excData{3}, excData{4});
%Expert
[~,pNaiveInh] = ttest2(inhData{1}, inhData{2});
[~,pExpertInh] = ttest2(inhData{3}, inhData{4});

%naive vs expert
[~,pNaive_expert_csPlus_Exc] = ttest2(excData{1}, excData{3});
[~,pNaive_expert_cMinus_Exc] = ttest2(excData{2}, excData{4});

[~,pNaive_expert_csPlus_Inh] = ttest2(inhData{1}, inhData{3});
[~,pNaive_expert_cMinus_Inh] = ttest2(inhData{2}, inhData{4});

disp(['P naive exc = ' num2str(pNaiveExc) '; P expert exc = ' num2str(pExpertExc) '; P naive inh = ' num2str(pNaiveInh) '; P expert inh = ' num2str(pExpertInh) ...
    ';P naiveVSexpert CS+ exc = ' num2str(pNaive_expert_csPlus_Exc) '; P naiveVSexpert CS- exc = ' num2str(pNaive_expert_cMinus_Exc) ...
    'P naiveVSexpert CS+ inh = ' num2str(pNaive_expert_csPlus_Inh) '; P naiveVSexpert CS- inh = ' num2str(pNaive_expert_cMinus_Inh)])
%%
figure;
subplot(1,2,1)
title('Excitation')
CSplusColor = [154,52,52]./255;
CSminusColor = [153,102,51]./255;

categories = {'Naive - CS+', 'Naive - CS-', 'Expert - CS+', 'Expert - CS-'};
colors = [CSplusColor; CSminusColor; CSplusColor; CSminusColor];  % Optional custom colors

violinplot_with_mean_single_side(excData, categories, colors, 1, 0);
ylabel('Firing rate (Z-score)');

subplot(1,2,2)
title('Inhibition')
CSplusColor = [154,52,52]./255;
CSminusColor = [153,102,51]./255;

categories = {'Naive - CS+', 'Naive - CS-', 'Expert - CS+', 'Expert - CS-'};
colors = [CSplusColor; CSminusColor; CSplusColor; CSminusColor];  % Optional custom colors

violinplot_with_mean_single_side(inhData, categories, colors, 1, 0);
ylabel('Firing rate (Z-score)');


