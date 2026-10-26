function [activityMatrix, highRasters, lowRasters] = computeH_L_odorsActivity(allMiceData, bgPeriod, fgPeriod, srCriterion, brainRegion)

c = 0;
activityMatrix = [];highRasters = {};lowRasters = {};numOfRespondingNeurons = [];realOdorsFiringRates = [];

highProbColor = [0,169,137]./255;
lowProbsColor = [171,62,143]./255;

%%
%Run across mice
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
           
            Atrials = mouseData(recInd).data.Atrials;
            Ctrials = mouseData(recInd).data.Ctrials;
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
            currSuccessRate = mean([mouseData(recInd).data.successRate.A mouseData(recInd).data.successRate.A]);
            
            

            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                allSRs(c) = currSuccessRate;
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= bgPeriod(1) & timeBins <= bgPeriod(2));
                fgDuration = find(timeBins >= fgPeriod(1) & timeBins <= fgPeriod(2));
                
%%                      %A
                        odorDuration_fr_A = mean(currFRmat(Atrials,fgDuration),2);
                        
                        baselineActivityfr_A = mean(currFRmat(Atrials,baselineDuration),2);
                        

                         %C                      
                        odorDuration_fr_C = mean(currFRmat(Ctrials,fgDuration),2);
                        
                        baselineActivityfr_C = mean(currFRmat(Ctrials,baselineDuration),2);
                
                
                %--- Stat ----
                                
                csPlus_response = [];csMinus_response = [];
                % Test for odor response
                [A_response,~] = ttest(odorDuration_fr_A, baselineActivityfr_A);
                [C_response,~] = ttest(odorDuration_fr_C, baselineActivityfr_C);
                
                if isequal(A_response,1) | isequal(C_response,1)
                    
                    
                    A_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(Atrials);
                    C_raster = mouseData(recInd).data.allRasterPlots(unitInd).data(Ctrials);
                    
                    % Compute evoked z-score
                    [zA] = computeZscorefromRaster(A_raster, bgPeriod, fgPeriod);
                    [zC] = computeZscorefromRaster(C_raster, bgPeriod, fgPeriod);
                    
                    % The vector is arranged as H L and success rate values
                    if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                        activityMatrix(end+1,:) = [zA zC currSuccessRate 1];
                        highRasters{end+1} = A_raster;
                        lowRasters{end+1} = C_raster;
                        numOfRespondingNeurons(end+1,:) = [A_response C_response];
                        realOdorsFiringRates(end+1,:) = [zA zC 1];
                    else
                        activityMatrix(end+1,:) = [zC zA currSuccessRate 0];
                        highRasters{end+1} = C_raster;
                        lowRasters{end+1} = A_raster;
                        numOfRespondingNeurons(end+1,:) = [C_response A_response];
                        realOdorsFiringRates(end+1,:) = [zA zC 0];
                    end
                end

               
                
                
                
                
            end
        end
    end
end

%% divide to naive and expert
infLocs = isinf(activityMatrix);
 activityMatrix(infLocs,:) = [];
 realOdorsFiringRates(infLocs,:) = [];
 numOfRespondingNeurons(infLocs,:) = [];
 highRasters(infLocs) = [];
 lowRasters(infLocs) = [];

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

pooled{1} = abs([excData{1} ; inhData{1}]);
pooled{2} = abs([excData{2} ; inhData{2}]);
pooled{3} = abs([excData{3} ; inhData{3}]);
pooled{4} = abs([excData{4} ; inhData{4}]);
%% Stat
%naive
[~,pNaiveExc] = ttest2(excData{1}, excData{2});
[~,pExpertExc] = ttest2(excData{3}, excData{4});
%Expert
[~,pNaiveInh] = ttest2(inhData{1}, inhData{2});
[~,pExpertInh] = ttest2(inhData{3}, inhData{4});

%naive vs expert
[~,pNaive_expert_H_Exc] = ttest2(excData{1}, excData{3});
[~,pNaive_expert_L_Exc] = ttest2(excData{2}, excData{4});

[~,pNaive_expert_H_Inh] = ttest2(inhData{1}, inhData{3});
[~,pNaive_expert_L_Inh] = ttest2(inhData{2}, inhData{4});

disp(['P naive exc = ' num2str(pNaiveExc) '; P expert exc = ' num2str(pExpertExc) '; P naive inh = ' num2str(pNaiveInh) '; P expert inh = ' num2str(pExpertInh) ...
    ';P naiveVSexpert H exc = ' num2str(pNaive_expert_H_Exc) '; P naiveVSexpert L exc = ' num2str(pNaive_expert_L_Exc) ...
    'P naiveVSexpert H inh = ' num2str(pNaive_expert_H_Inh) '; P naiveVSexpert L inh = ' num2str(pNaive_expert_L_Inh)])
%%
figure;
subplot(1,2,1)
title('Excitation')


categories = {'Naive - H', 'Naive - L', 'Expert - H', 'Expert - L'};
colors = [highProbColor; lowProbsColor; highProbColor; lowProbsColor];  % Optional custom colors

violinplot_with_mean_single_side(excData, categories, colors, 1, 0);
ylabel('Firing rate (Z-score)');

subplot(1,2,2)
title('Inhibition')

categories = {'Naive - H', 'Naive - L', 'Expert - H', 'Expert - L'};
colors = [highProbColor; lowProbsColor; highProbColor; lowProbsColor];  % Optional custom colors

violinplot_with_mean_single_side(inhData, categories, colors, 1, 0);
ylabel('Firing rate (Z-score)');


%% pooled - abs firing rate
figure;
categories = {'Naive - H', 'Naive - L', 'Expert - H', 'Expert - L'};
colors = [highProbColor; lowProbsColor; highProbColor; lowProbsColor];  % Optional custom colors

violinplot_with_mean_single_side(pooled, categories, colors, 1, 0);
ylabel('|Firing rate (Z-score)|');

[~,pNaive_H_L_pooled] = ttest2(pooled{1}, pooled{2});
[~,pExpert_H_L_pooled] = ttest2(pooled{3}, pooled{4});

title(['Pooled, P naive = ' num2str(pNaive_H_L_pooled) ', P expert = ' num2str(pExpert_H_L_pooled)])


%%%%% counter balance

A_is_higher = realOdorsFiringRates(find(realOdorsFiringRates(:,3)==1),1:2);
C_is_higher = realOdorsFiringRates(find(realOdorsFiringRates(:,3)==0),1:2);

curr_A_is_higher = [];curr_C_is_higher = [];
for ind = 1:100
    minNeurons = min(size(A_is_higher,1), size(C_is_higher,1));

    curr_A_is_higher(ind,:) = mean(A_is_higher(randsample(size(A_is_higher,1), minNeurons),:));
    curr_C_is_higher(ind,:) = mean(C_is_higher(randsample(size(C_is_higher,1), minNeurons),:));
end

plot_two_matrices_mean_sem(curr_A_is_higher, curr_C_is_higher)
end

function plot_two_matrices_mean_sem(mat1, mat2)

% Colors
colA = [0,169,137] ./ 255;
colB = [171,62,143] ./ 255;

figure;

%% -------- Subplot 1 --------
subplot(1,2,1); hold on;

% Mean and SEM
m1 = mean(mat1,1);
sem1 = std(mat1,[],1) ./ sqrt(size(mat1,1));

% Plot bars
b = bar(1:2, m1, 'FaceColor', 'flat');

b.CData(1,:) = colA;
b.CData(2,:) = colB;

% Error bars
errorbar(1:2, m1, sem1, 'k', 'linestyle', 'none', 'LineWidth', 1.5);

% Labels
set(gca, 'XTick', 1:2, 'XTickLabel', {'2-hept','EA'});
xlim([0.5 2.5]);

%% -------- Subplot 2 --------
subplot(1,2,2); hold on;

% Mean and SEM
m2 = mean(mat2,1);
sem2 = std(mat2,[],1) ./ sqrt(size(mat2,1));

% Plot bars
b = bar(1:2, m2, 'FaceColor', 'flat');

% REVERSED colors
b.CData(1,:) = colB;
b.CData(2,:) = colA;

% Error bars
errorbar(1:2, m2, sem2, 'k', 'linestyle', 'none', 'LineWidth', 1.5);

% Labels
set(gca, 'XTick', 1:2, 'XTickLabel', {'2-hept','EA'});
xlim([0.5 2.5]);

end








