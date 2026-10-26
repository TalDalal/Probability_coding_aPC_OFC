function [] = RT_A_or_C_odors_as_H(allMiceData)

lowColor = [171,62,143]./255;%purple
highColor = [0,169,137]./255;%green

naiveTH = 0.7; expertTH = 0.7;

curr_H_RT_A = [];curr_L_RT_C = [];curr_H_RT_C = [];curr_L_RT_A = [];SR_H_A = [];SR_H_C = [];
for mouseInd = 1:size(allMiceData,2)
    
    allRecs = allMiceData(mouseInd).allRecs;
    for recInd = 1:size(allRecs,2)
        if allRecs(recInd).sessionNum > 0% ONLY experiment sessions and not pretraining
            
            if allRecs(recInd).data.probability.A > allRecs(recInd).data.probability.C
                curr_H_RT_A(end+1) = mean(allRecs(recInd).data.firstLickLatency.A);
                curr_L_RT_C(end+1) = mean(allRecs(recInd).data.firstLickLatency.C);
                
                SR_H_A(end+1) = mean([allRecs(recInd).data.successRate.A allRecs(recInd).data.successRate.C]);

            else
                curr_H_RT_C(end+1) = mean(allRecs(recInd).data.firstLickLatency.C);
                curr_L_RT_A(end+1) = mean(allRecs(recInd).data.firstLickLatency.A);
                
                SR_H_C(end+1) = mean([allRecs(recInd).data.successRate.A allRecs(recInd).data.successRate.C]);
            end

            

            else
                
        end
    end
    
end
%% Plot
%Naive
naiveHigh_A = curr_H_RT_A(find(SR_H_A <= naiveTH));
naiveHigh_C = curr_H_RT_C(find(SR_H_C <= naiveTH ));

naiveLow_A = curr_L_RT_A(find(SR_H_C <= naiveTH));
naiveLow_C = curr_L_RT_C(find(SR_H_A <= naiveTH ));

expertHigh_A = curr_H_RT_A(find(SR_H_A >= expertTH));
expertHigh_C = curr_H_RT_C(find(SR_H_C >= expertTH ));

expertLow_A = curr_L_RT_A(find(SR_H_C >= expertTH));
expertLow_C = curr_L_RT_C(find(SR_H_A >= expertTH ));



% lickData{1} = naiveHigh_A;
% lickData{2} = naiveLow_C;
% lickData{3} = naiveHigh_C;
% lickData{4} = naiveLow_A;

lickData{1} = expertHigh_A;
lickData{2} = expertLow_C;
lickData{3} = expertHigh_C;
lickData{4} = expertLow_A;


% Stat
[~,pExpert_A_H] = ttest(expertHigh_A, expertLow_C);
[~,pExpert_C_H] = ttest(expertHigh_C, expertLow_A);
[~,p_A_or_C_L] = ttest2(expertLow_A, expertLow_C);
[~,p_A_or_C_H] = ttest2(expertHigh_C, expertHigh_A);

%% Plot
%Hit
figure;
% Generate example data
categories = {'2-hep: H', 'EA: L', 'EA: H', '2-hep: L', };
colors = [highColor; lowColor; highColor; lowColor];  % Optional custom colors

% Call the function
violinplot_with_mean_single_side(lickData, categories, colors, 1, 0);
ylabel('First lick latency (S)')




