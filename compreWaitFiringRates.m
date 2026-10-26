clear;clc
fileName = 'allRecs_M3_PC_tetrodes';
load(fileName)
waitFiringRates = [];
rampingNeurons = [];
analysisWinWait = [-.4 0];
analysisWinBG = (-allRecs(1).data.ISIbetweenOdors-allRecs(1).data.odor_duration)./1000;
numOfNeurons = 0;
for dateInd = 1:size(allRecs,2)
    params = allRecs(dateInd).data;
    
    for unitNum = 1:size(params.allRasterPlots,2)
        numOfNeurons = numOfNeurons + 1;
        %%
        % Comapre the ramping values between A and C
        bgActivity = mean(params.firingRates(unitNum).firingRateByBIn(:,find( params.firingRateAnalysisBins < analysisWinBG))');
        
        A = params.firingRates(unitNum).firingRateByBIn(params.Atrials,:);
        waitA = mean(A(:,find(params.firingRateAnalysisBins >= analysisWinWait(1) &  params.firingRateAnalysisBins < analysisWinWait(2)))') - mean(bgActivity);
        
        C = params.firingRates(unitNum).firingRateByBIn(params.Ctrials,:);
        waitC = mean(C(:,find(params.firingRateAnalysisBins >= analysisWinWait(1) &  params.firingRateAnalysisBins < analysisWinWait(2)))') - mean(bgActivity);
        
        
        [h,p] = ttest2(waitA, waitC);
        
        if h
            waitFiringRates(end+1, :) = [mean(waitA) mean(waitC)];
        end
        
        %Quantify how many ramping neurons there are
        [hBG_vs_WaitA,~] = ttest2(bgActivity, waitA, 'tail', 'left');
        [hBG_vs_WaitC,~] = ttest2(bgActivity, waitC, 'tail', 'left');
        
        if hBG_vs_WaitA | hBG_vs_WaitC
            rampingNeurons(end+1,:) = [mean(waitA) mean(waitC)];
        end
    end
end
figure;
scatter(waitFiringRates(:,2), waitFiringRates(:,1))
[~,p] = ttest(waitFiringRates(:,2), waitFiringRates(:,1))
disp([num2str(100*(length(find(waitFiringRates(:,1) > waitFiringRates(:,2)))./size(waitFiringRates,1))) '%'])