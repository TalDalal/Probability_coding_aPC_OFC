function [csStruct] = analyze_context_modulated_neurons(allMiceData, fgPeriod,bgPeriod, brainRegion)
csStruct = [];c = 0;
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        params = mouseData(recInd).data;
        
        
        %Only PC recordings
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                currUnitFR = params.firingRates(unitInd).firingRateByBIn;
                currUnit_rasterPlot = params.allRasterPlots(unitInd);
                
                [csStruct] = check_context_modulation(c, params, fgPeriod,bgPeriod,currUnitFR, csStruct, currUnit_rasterPlot);
                %------------------CS- ---------------
                [csStruct] = check_context_modulation(c, params, fgPeriod,bgPeriod,currUnitFR, csStruct, currUnit_rasterPlot);
                csStruct(c).TTname = [mouseData(recInd).date{1} '_' params.NeuralData.Spikes{unitInd}.tetrode];
            end
        end
    end
end
end

function [outStruct] = check_context_modulation(unitInd, params, fgPeriod, bgPeriod, currUnitFR, outStruct, currUnit_rasterPlot)

%------------------CS+---------------
Atrials = params.targetTrials.A;
Ctrials = params.targetTrials.C;
Btrials = params.targetTrials.B;
[evokedOdorResponse,H_fr, L_fr,B_fr, h_context_modulated, odor_response] = compute_context_modulation(Atrials, Ctrials,Btrials, params, fgPeriod, bgPeriod, currUnitFR);
outStruct(unitInd).CSplus.evokedOdorResponse = evokedOdorResponse;
outStruct(unitInd).CSplus.H_fr = H_fr;
outStruct(unitInd).CSplus.L_fr = L_fr;
outStruct(unitInd).CSplus.B_fr = B_fr;
outStruct(unitInd).CSplus.h_context_modulated = h_context_modulated;
outStruct(unitInd).CSplus.odor_response = odor_response;
outStruct(unitInd).CSplus.successRate = mean([params.successRate.A params.successRate.C]);

if params.probability.A > params.probability.C
    outStruct(unitInd).CSplus.H_raster = currUnit_rasterPlot.data(Atrials);
    outStruct(unitInd).CSplus.L_raster = currUnit_rasterPlot.data(Ctrials);
else
    outStruct(unitInd).CSplus.H_raster = currUnit_rasterPlot.data(Ctrials);
    outStruct(unitInd).CSplus.L_raster = currUnit_rasterPlot.data(Atrials);
end


clear evokedOdorResponse  H_fr  L_fr B_fr  h_context_modulated odor_response
 
%------------------CS- ---------------
Atrials = params.tMinusTrials.A;
Ctrials = params.tMinusTrials.C;
Btrials = params.tMinusTrials.B;
[evokedOdorResponse,H_fr, L_fr,B_fr, h_context_modulated, odor_response] = compute_context_modulation(Atrials, Ctrials,Btrials, params, fgPeriod, bgPeriod, currUnitFR);
outStruct(unitInd).CSminus.evokedOdorResponse = evokedOdorResponse;
outStruct(unitInd).CSminus.H_fr = H_fr;
outStruct(unitInd).CSminus.L_fr = L_fr;
outStruct(unitInd).CSminus.B_fr = B_fr;
outStruct(unitInd).CSminus.h_context_modulated = h_context_modulated;
outStruct(unitInd).CSminus.odor_response = odor_response;


if params.probability.A > params.probability.C
    outStruct(unitInd).CSminus.H_raster = currUnit_rasterPlot.data(Atrials);
    outStruct(unitInd).CSminus.L_raster = currUnit_rasterPlot.data(Ctrials);
else
    outStruct(unitInd).CSminus.H_raster = currUnit_rasterPlot.data(Ctrials);
    outStruct(unitInd).CSminus.L_raster = currUnit_rasterPlot.data(Atrials);
end

end




function [evokedOdorResponse,H_fr, L_fr,B_fr, h_context_modulated, cs_response] = compute_context_modulation(Atrials, Ctrials,Btrials, params, fgPeriod, bgPeriod, currUnitFR)


%---- time indices----
frAnalysisIndices = find(params.firingRateAnalysisBins >= fgPeriod(1) & params.firingRateAnalysisBins <= fgPeriod(2));
fullOdorDurationAnalysisIndices = find(params.firingRateAnalysisBins >= fgPeriod(1) & params.firingRateAnalysisBins <= fgPeriod(2));
baselineDurationAnalysisIndices = find(params.firingRateAnalysisBins >= bgPeriod(1) & params.firingRateAnalysisBins <= bgPeriod(2));


%test response to the odor
odorDurationFr = mean(currUnitFR([Atrials Ctrials], fullOdorDurationAnalysisIndices),2);
baselineDurationFr = mean(currUnitFR([Atrials Ctrials], baselineDurationAnalysisIndices),2);

% odorDurationFr = mean(currUnitFR(:, fullOdorDurationAnalysisIndices),2);
% baselineDurationFr = mean(currUnitFR(:, baselineDurationAnalysisIndices),2);

[cs_response,~] = ttest(odorDurationFr, baselineDurationFr);
evokedOdorResponse = mean(odorDurationFr-baselineDurationFr);

% Compare the firing rate between probabilities
A_fr = mean(currUnitFR(Atrials, frAnalysisIndices),2);
C_fr = mean(currUnitFR(Ctrials, frAnalysisIndices),2);
B_fr = mean(currUnitFR(Btrials, frAnalysisIndices),2);

[h_context_modulated(1)] = ttest2(A_fr, C_fr);
[h_context_modulated(2)] = ttest2(A_fr, B_fr);
[h_context_modulated(3)] = ttest2(B_fr, C_fr);

h_context_modulated(isnan(h_context_modulated)) = 0;



if params.probability.A > params.probability.C
    H_fr = mean(A_fr)-mean(baselineDurationFr);
    L_fr = mean(C_fr)-mean(baselineDurationFr);
else
    H_fr = mean(C_fr)-mean(baselineDurationFr);
    L_fr = mean(A_fr)-mean(baselineDurationFr);
end
if ~isempty(B_fr)
    B_fr = mean(B_fr)-mean(baselineDurationFr);
end
end
