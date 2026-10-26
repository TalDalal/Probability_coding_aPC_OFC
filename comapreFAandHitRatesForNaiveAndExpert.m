function [] = comapreFAandHitRatesForNaiveAndExpert(miceData, expertCriterion)
% Plot the learning curve per mouse


lowColor = [171,62,143]./255;%purple
highColor = [0,169,137]./255;%green
;probExpCounter = 0;

highHit_naive = [];lowHit_naive = [];highFA_naive = [];lowFA_naive = [];
highHit_expert = [];lowHit_expert = [];highFA_expert = [];lowFA_expert = [];


for miceInd = 1:size(miceData,2)
    for recInd = 1:size(miceData(miceInd).allRecs,2)
        
        if miceData(miceInd).allRecs(recInd).sessionNum > 0
            
            probExpCounter = probExpCounter + 1;
            
            %Compute the mean SR
            currSR = mean([miceData(miceInd).allRecs(recInd).data.successRate.A miceData(miceInd).allRecs(recInd).data.successRate.C]);
            
            if currSR < expertCriterion%Naive
                
                if miceData(miceInd).allRecs(recInd).data.probability.A > miceData(miceInd).allRecs(recInd).data.probability.C
                    
                    %HIT
                    highHit_naive(end+1) = miceData(miceInd).allRecs(recInd).data.hitRate.A;
                    lowHit_naive(end+1) = miceData(miceInd).allRecs(recInd).data.hitRate.C;
                    %FA
                    highFA_naive(end+1) = miceData(miceInd).allRecs(recInd).data.FA.A;
                    lowFA_naive(end+1) = miceData(miceInd).allRecs(recInd).data.FA.C;
                    
                else
                    %HIT
                    highHit_naive(end+1) = miceData(miceInd).allRecs(recInd).data.hitRate.C;
                    lowHit_naive(end+1) = miceData(miceInd).allRecs(recInd).data.hitRate.A;
                    %FA
                    highFA_naive(end+1) = miceData(miceInd).allRecs(recInd).data.FA.C;
                    lowFA_naive(end+1) = miceData(miceInd).allRecs(recInd).data.FA.A;
                end
                
            else%Expert
                
                if miceData(miceInd).allRecs(recInd).data.probability.A > miceData(miceInd).allRecs(recInd).data.probability.C
                    
                    %HIT
                    highHit_expert(end+1) = miceData(miceInd).allRecs(recInd).data.hitRate.A;
                    lowHit_expert(end+1) = miceData(miceInd).allRecs(recInd).data.hitRate.C;
                    %FA
                    highFA_expert(end+1) = miceData(miceInd).allRecs(recInd).data.FA.A;
                    lowFA_expert(end+1) = miceData(miceInd).allRecs(recInd).data.FA.C;
                    
                else
                    %HIT
                    highHit_expert(end+1) = miceData(miceInd).allRecs(recInd).data.hitRate.C;
                    lowHit_expert(end+1) = miceData(miceInd).allRecs(recInd).data.hitRate.A;
                    %FA
                    highFA_expert(end+1) = miceData(miceInd).allRecs(recInd).data.FA.C;
                    lowFA_expert(end+1) = miceData(miceInd).allRecs(recInd).data.FA.A;
                end
                
            end
            
        end
    end
end

hitData{1} = highHit_naive;
hitData{2} = lowHit_naive;
hitData{3} = highHit_expert;
hitData{4} = lowHit_expert;

faData{1} = highFA_naive;
faData{2} = lowFA_naive;
faData{3} = highFA_expert;
faData{4} = lowFA_expert;
%% Stat
[~,pNaive_FA] = ttest2(highFA_naive, lowFA_naive);
[~,pExpert_FA] = ttest2(highFA_expert, lowFA_expert);

disp(['Pnaive_FA = ' num2str(pNaive_FA) ', Pexpert_FA = ' num2str(pExpert_FA)]) 

%% Plot
figure;
% Generate example data
categories = {'High naive', 'Low naive', 'High expert', 'Low expert'};
colors = [highColor; lowColor; highColor; lowColor;];  % Optional custom colors

% Call the function
subplot(1,2,1)
violinplot_with_mean_single_side(hitData, categories, colors, 1, 0);
title('Hit');set(gca, 'FontSize', 18);box off;ylabel('Hit rate')


% Generate example data
categories = {'High naive', 'Low naive', 'High expert', 'Low expert'};
colors = [highColor; lowColor; highColor; lowColor;];  % Optional custom colors

% Call the function
subplot(1,2,2)
violinplot_with_mean_single_side(faData, categories, colors, 1, 0);
title('FA');set(gca, 'FontSize', 18);box off;ylabel('FA rate')


