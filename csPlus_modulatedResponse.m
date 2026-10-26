function [allTimBinsPSTHS_CSplus, allTimBinsPSTHS_CSminus] = csPlus_modulatedResponse(allMiceData, equalizeTrialNum)

timeVec = -3:.1:3;
winSize = .5;
smoothKernel = 0.05;
bgPeriod = [-4 -3];

statAgainstChance_CSplus = nan(1,length(timeVec));
statAgainstChance_CSminus = nan(1,length(timeVec));
statAgainstChance_ALL = nan(1,length(timeVec));

statCSplus_minus = nan(1,length(timeVec));
highPSTHs_CSplus = [];lowPSTHs_CSplus = [];
highPSTHs_CSminus = [];lowPSTHs_CSminus = [];
highFR_CSplus = [];lowFR_CSplus = [];
highFR_CSminus = [];lowFR_CSminus = [];

for timeInd = 1:length(timeVec)
    c = 0;
    highFR_CSplus = [];lowFR_CSplus = [];
    highFR_CSminus = [];lowFR_CSminus = [];
    %Run across mice
    for miceInd = 1:size(allMiceData,2)
        mouseData = allMiceData(miceInd).allRecs;
        % Run over alll recordings
        for recInd = 1:size(mouseData,2)
            
            params = mouseData(recInd).data;
            
            
            if strcmpi(equalizeTrialNum, 'equalize')
                
                %-------CS+
                %Find the minimal trialNum
                minCSplusTrialNum = min(length(params.targetTrials.A), length(params.targetTrials.C));
                %Rand trials
                params.targetTrials.A = sort(randsample(params.targetTrials.A, minCSplusTrialNum));
                params.targetTrials.C = sort(randsample(params.targetTrials.C, minCSplusTrialNum));
                
                %-------CS-
                %Find the minimal trialNum
                minCSminusTrialNum = min(length(params.tMinusTrials.A), length(params.tMinusTrials.C));
                %Rand trials
                params.tMinusTrials.A = sort(randsample(params.tMinusTrials.A, minCSminusTrialNum));
                params.tMinusTrials.C = sort(randsample(params.tMinusTrials.C, minCSminusTrialNum));
            end
            
            %Only PC recordings
            if strcmpi('PC',mouseData(recInd).brainRegion)
                
                %Run across units per recording
                for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                    c = c + 1;
                    
                    
                    currUnitFR = params.firingRates(unitInd).firingRateByBIn;
                    frAnalysisIndices = find(params.firingRateAnalysisBins >= timeVec(timeInd) & params.firingRateAnalysisBins <= timeVec(timeInd)+winSize);
                    %------------ All trials ------------
                    A_fr = mean(currUnitFR([params.targetTrials.A params.tMinusTrials.A], frAnalysisIndices),2);
                    C_fr = mean(currUnitFR([params.targetTrials.C params.tMinusTrials.C], frAnalysisIndices),2);
                    [h_fr_ALL] = ttest2(A_fr, C_fr);
                    A_fr = [];C_fr = [];
                    
                    %------------------CS+---------------
                    % Compare the firing rate - CS+
                    A_fr = mean(currUnitFR(params.targetTrials.A, frAnalysisIndices),2);
                    C_fr = mean(currUnitFR(params.targetTrials.C, frAnalysisIndices),2);
                    [h_fr_CSplus] = ttest2(A_fr, C_fr);
                    
                    % PSTHS
                    if h_fr_CSplus > 0
                        Araster = params.allRasterPlots(unitInd).data(params.targetTrials.A);
                        [A_PSTH, t] = normalizePSTHfromRasterPlot(Araster, smoothKernel, bgPeriod);
                        
                        Craster = params.allRasterPlots(unitInd).data(params.targetTrials.C);
                        [C_PSTH, t] = normalizePSTHfromRasterPlot(Craster, smoothKernel, bgPeriod);
                        
                        if ~isempty(A_PSTH) & ~isempty(C_PSTH)
                            if params.probability.A > params.probability.C
                                highPSTHs_CSplus(end+1,:) = A_PSTH;
                                lowPSTHs_CSplus(end+1,:) = C_PSTH;
                                
                                highFR_CSplus(end+1) = mean(A_fr);
                                lowFR_CSplus(end+1) = mean(C_fr);
                            else
                                highPSTHs_CSplus(end+1,:) = C_PSTH;
                                lowPSTHs_CSplus(end+1,:) = A_PSTH;
                                
                                highFR_CSplus(end+1) = mean(C_fr);
                                lowFR_CSplus(end+1) = mean(A_fr);
                            end
                        end
                    end
                    
                    
                    A_fr = [];C_fr = [];Araster = [];Craster = [];
                    
                    %------------------CS- ---------------
                    A_fr = mean(currUnitFR(params.tMinusTrials.A, frAnalysisIndices),2);
                    C_fr = mean(currUnitFR(params.tMinusTrials.C, frAnalysisIndices),2);
                    [h_fr_CSminus] = ttest2(A_fr, C_fr);
                    
                    % PSTHS
                    if h_fr_CSminus > 0
                        Araster = params.allRasterPlots(unitInd).data(params.tMinusTrials.A);
                        [A_PSTH, t] = normalizePSTHfromRasterPlot(Araster, smoothKernel, bgPeriod);
                        
                        Craster = params.allRasterPlots(unitInd).data(params.tMinusTrials.C);
                        [C_PSTH, t] = normalizePSTHfromRasterPlot(Craster, smoothKernel, bgPeriod);
                        
                        if ~isempty(A_PSTH) & ~isempty(C_PSTH)
                            if params.probability.A > params.probability.C
                                highPSTHs_CSminus(end+1,:) = A_PSTH;
                                lowPSTHs_CSminus(end+1,:) = C_PSTH;
                                
                                highFR_CSminus(end+1) = mean(A_fr);
                                lowFR_CSminus(end+1) = mean(C_fr);
                            else
                                highPSTHs_CSminus(end+1,:) = C_PSTH;
                                lowPSTHs_CSminus(end+1,:) = A_PSTH;
                                
                                highFR_CSminus(end+1) = mean(C_fr);
                                lowFR_CSminus(end+1) = mean(A_fr);
                            end
                        end
                    end
                    
                    A_fr = [];C_fr = [];
                    
                    
                    
                    modulatedResponse_CSplus(c) = h_fr_CSplus;
                    modulatedResponse_CSminus(c) = h_fr_CSminus;
                    modulatedResponse_ALL(c) = h_fr_ALL;
                    
                    
                    
                end
            end
        end
    end
    %CS+
    allTimBinsPSTHS_CSplus(timeInd).high = highPSTHs_CSplus;
    allTimBinsPSTHS_CSplus(timeInd).low = lowPSTHs_CSplus;
    allTimBinsPSTHS_CSplus(timeInd).t = t;
    allTimBinsPSTHS_CSplus(timeInd).fr.high = highFR_CSplus;
    allTimBinsPSTHS_CSplus(timeInd).fr.low = lowFR_CSplus;
    highPSTHs_CSplus = [];lowPSTHs_CSplus = [];
    
    %CS-
    allTimBinsPSTHS_CSminus(timeInd).high = highPSTHs_CSminus;
    allTimBinsPSTHS_CSminus(timeInd).low = lowPSTHs_CSminus;
    allTimBinsPSTHS_CSminus(timeInd).t = t;
    allTimBinsPSTHS_CSminus(timeInd).fr.high = highFR_CSminus;
    allTimBinsPSTHS_CSminus(timeInd).fr.low = lowFR_CSminus;
    highPSTHs_CSminus = [];lowPSTHs_CSminus = [];
    
    movingResponse_CSplus(timeInd) = 100.*(nansum(modulatedResponse_CSplus)./length(modulatedResponse_CSplus));
    movingResponse_CSminus(timeInd) = 100.*(nansum(modulatedResponse_CSminus)./length(modulatedResponse_CSminus));
    movingResponse_ALL(timeInd) = 100.*(nansum(modulatedResponse_ALL)./length(modulatedResponse_ALL));
    movingResponse_ALL_SE(timeInd) = binoDistSE((nansum(modulatedResponse_ALL)./length(modulatedResponse_ALL)), length(modulatedResponse_ALL));

    
    %stat
    %ALL
    
    [p_ALL_vs_chance] = oneSampleProportionTest(movingResponse_ALL(timeInd)./100, 0.05, length(movingResponse_ALL));
    if p_ALL_vs_chance < 0.05
        statAgainstChance_ALL(timeInd) = 1;
    end
    
    %CS+
    [p_csplus_vs_chance] = oneSampleProportionTest(movingResponse_CSplus(timeInd)./100, 0.05, length(modulatedResponse_CSplus));
    if p_csplus_vs_chance < 0.05
        statAgainstChance_CSplus(timeInd) = 3;
    end
    %CS-
    [p_csminus_vs_chance] = oneSampleProportionTest(movingResponse_CSminus(timeInd)./100, 0.05, length(modulatedResponse_CSminus));
    if p_csminus_vs_chance < 0.05
        statAgainstChance_CSminus(timeInd) = 2;
    end
    %CS+ vs CS-
    [p_CSplus_vs_CSminus] = twoSampleProportionTest(movingResponse_CSminus(timeInd)./100, movingResponse_CSplus(timeInd)./100, length(modulatedResponse_CSplus), length(modulatedResponse_CSminus));
    if p_CSplus_vs_CSminus < 0.05
        statCSplus_minus(timeInd) = 1;
    end
end
%% CS+\-
figure;
plot(timeVec, movingResponse_CSplus, 'r')
hold all;
plot(timeVec, movingResponse_CSminus, 'b')
plot([timeVec(1) timeVec(end)], [5 5], 'k--')

plot(timeVec, statAgainstChance_CSplus, 'r')
plot(timeVec, statAgainstChance_CSminus, 'b')
plot(timeVec, statCSplus_minus, 'k')

legend('CS+', 'CS-');
set(gca, 'FontSize', 18);box off;
xlabel('Time (sec)');ylabel(' Modulated response (%)');
xlim([timeVec(1) timeVec(end)])

%% ALL
figure;

errorbar_patch(timeVec, movingResponse_ALL,movingResponse_ALL_SE.*100, 'r')
hold all;
plot(timeVec, statAgainstChance_ALL, 'k')
plot([timeVec(1) timeVec(end)], [5 5], 'k--')

set(gca, 'FontSize', 18);box off;
xlabel('Time (sec)');ylabel(' Modulated response (%)');
xlim([timeVec(1) 0])



