function [taskResponsiveNeuronsMat_A, taskResponsiveNeuronsMat_C] = quantifyTaskResponsiveNeurons(allMiceData, pValueTH, analysisTimeWin, bgPeriod)

c = 0;
% pValueTH = 0.01;
CColor = [171,62,143]./255;%purple
AColor = [0,169,137]./255;%green
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
            A_CS_plus_trials = mouseData(recInd).data.targetTrials.A;
            A_CS_minus_trials = mouseData(recInd).data.tMinusTrials.A;
            
            Ctrials = mouseData(recInd).data.Ctrials;
            C_CS_plus_trials = mouseData(recInd).data.targetTrials.C;
            C_CS_minus_trials = mouseData(recInd).data.tMinusTrials.C;
            
            timeBins = mouseData(recInd).data.firingRateAnalysisBins;
            
%             analysisTimeWin = [-ISI-odorDuration -ISI 0 odorDuration];
%             ISIdurationFactor = 0.6;
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                
                %Current trial X time firing rate mat
                currFRmat = mouseData(recInd).data.firingRates(unitInd).firingRateByBIn;
                
                baselineDuration = find(timeBins >= bgPeriod(1) & timeBins < bgPeriod(2));
                firstOdorDuration = find(timeBins >= analysisTimeWin(1,1) & timeBins < analysisTimeWin(1,2));
                ISIDuration = find(timeBins >= analysisTimeWin(2,1) & timeBins < analysisTimeWin(2,2));
                CSDuration = find(timeBins >= analysisTimeWin(3,1) & timeBins < analysisTimeWin(3,2));
                
                %---------------------- A trials--------------------------
                taskResponsiveNeuronsMat_A(c,:) = nan(1,4);
                Amat = currFRmat(Atrials,:);
                
                %Baseline
                bgFR_A = mean(Amat(:,baselineDuration),2);
                bgFR_CSPlus_A = mean(currFRmat(A_CS_plus_trials,baselineDuration),2);
                bgFR_CSMinus_A = mean(currFRmat(A_CS_minus_trials,baselineDuration),2);
                
                % first Odor
                firstOdorFR_A = mean(Amat(:,firstOdorDuration),2);
                [h,~] = ttest(bgFR_A, firstOdorFR_A, 'alpha', pValueTH);
                if mean(firstOdorFR_A) < mean(bgFR_A)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat_A(c,1) = h;
                
                % ISI activity
                isiFR_A = mean(Amat(:,ISIDuration),2);
                [h,~] = ttest(bgFR_A, isiFR_A, 'alpha', pValueTH);
                if mean(isiFR_A) < mean(bgFR_A)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat_A(c,2) = h;
                
                % CS + Odor
                csPlusOdorFR_A = mean(currFRmat(A_CS_plus_trials,CSDuration),2);
                [h,~] = ttest(bgFR_CSPlus_A, csPlusOdorFR_A, 'alpha', pValueTH);
                if mean(csPlusOdorFR_A) < mean(bgFR_CSPlus_A)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat_A(c,3) = h;
                
                % CS - Odor
                csMinusOdorFR_A = mean(currFRmat(A_CS_minus_trials,CSDuration),2);
                [h,~] = ttest(bgFR_CSMinus_A, csMinusOdorFR_A, 'alpha', pValueTH);
                if mean(csMinusOdorFR_A) < mean(bgFR_CSMinus_A)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat_A(c,4) = h;
                
                
                
                
                %----------------- C trials------------------------
                 taskResponsiveNeuronsMat_C(c,:) = nan(1,4);
                Cmat = currFRmat(Ctrials,:);
                
                %Baseline
                bgFR_C = mean(Cmat(:,baselineDuration),2);
                bgFR_CSPlus_C = mean(currFRmat(C_CS_plus_trials,baselineDuration),2);
                bgFR_CSMinus_C = mean(currFRmat(C_CS_minus_trials,baselineDuration),2);
                
                % first Odor
                firstOdorFR_C = mean(Cmat(:,firstOdorDuration),2);
                [h,~] = ttest(bgFR_C, firstOdorFR_C, 'alpha', pValueTH);
                if mean(firstOdorFR_C) < mean(bgFR_C)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat_C(c,1) = h;
                
                % ISI activity
                isiFR_C = mean(Cmat(:,ISIDuration),2);
                [h,~] = ttest(bgFR_C, isiFR_C, 'alpha', pValueTH);
                if mean(isiFR_C) < mean(bgFR_C)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat_C(c,2) = h;
                
                % CS + Odor
                csPlusOdorFR_C = mean(currFRmat(C_CS_plus_trials,CSDuration),2);
                [h,~] = ttest(bgFR_CSPlus_C, csPlusOdorFR_C, 'alpha', pValueTH);
                if mean(csPlusOdorFR_C) < mean(bgFR_CSPlus_C)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat_C(c,3) = h;
                
                % CS - Odor
                csMinusOdorFR_C = mean(currFRmat(C_CS_minus_trials,CSDuration),2);
                [h,~] = ttest(bgFR_CSMinus_C, csMinusOdorFR_C, 'alpha', pValueTH);
                if mean(csMinusOdorFR_C) < mean(bgFR_CSMinus_C)
                    h = h*-1;
                end
                taskResponsiveNeuronsMat_C(c,4) = h;
            end
        end
    end
end
%Avoid nans
taskResponsiveNeuronsMat_A(isnan(taskResponsiveNeuronsMat_A)) = 0;
taskResponsiveNeuronsMat_C(isnan(taskResponsiveNeuronsMat_C)) = 0;


figure;
dataForBar = [sum(abs(taskResponsiveNeuronsMat_A))./size(taskResponsiveNeuronsMat_A,1) ; ...
    sum(abs(taskResponsiveNeuronsMat_C))./size(taskResponsiveNeuronsMat_C,1)]';
    
b = bar(dataForBar);
b(1).FaceColor = 'flat';
b(1).CData = ones(size(dataForBar,1),3).*AColor;
b(2).FaceColor = 'flat';
b(2).CData = ones(size(dataForBar,1),3).*CColor;
set(gca, 'XTickLabel', {'High\Low', 'Delay', 'CS+', 'CS-'})
ylabel('Active neurons (%)');set(gca, 'FontSize', 14');box off;
percentResponsiveNeurons = 1-(length(find(sum(abs(taskResponsiveNeuronsMat_A)+abs(taskResponsiveNeuronsMat_C),2)==0))./size(taskResponsiveNeuronsMat_A,1));
disp(['Overall % task responsive neurons is ' num2str(percentResponsiveNeurons)])



% %---VENN DIAGRAM----------
% highOdor_A = taskResponsiveNeuronsMat_A(:,1);
% isiPeriod_A = taskResponsiveNeuronsMat_A(:,2);
% csPlus_A = taskResponsiveNeuronsMat_A(:,3);
% csMinus_A = taskResponsiveNeuronsMat_A(:,4);

% vennData_A = [sum(taskResponsiveNeuronsMat_A), ...
%     sum(highOdor_A.*isiPeriod_A), ...
%     sum(highOdor_A.*csPlus_A), ...
%     sum(highOdor_A.*csMinus_A), ...
%     sum(isiPeriod_A.*csPlus_A), ...
%     sum(isiPeriod_A.*csMinus_A), ...
%     sum(csPlus_A.*csMinus_A), ...
%     sum(csPlus_A.*csMinus_A), ...
%     sum(highOdor_A.*isiPeriod_A.*csPlus_A), ...
%     sum(highOdor_A.*isiPeriod_A.*csMinus_A), ...
%     sum(highOdor_A.*csPlus_A.*csMinus_A), ...
%     sum(isiPeriod_A.*csPlus_A.*csMinus_A), ...
%     sum(highOdor_A.*isiPeriod_A.*csPlus_A.*csMinus_A)];
% 
% mysets = ["H" "ISI" "CS+" "CS-"];
% vennColor = summer(4);
% venn(4,'sets',mysets,'labels',vennData_A','colors',vennColor,'alpha',0.5,'edgeC',[1 1 1],'edgeW',3);
                
            
    