clear;clc

identifiedRamping = [8 9 13 14 15 18 21 22  26 28 30 32 33 34  50 51 52 53 54 63 66 ...
    71 76 83 95  132 143  155 157 163 173 176 ...
    179 189 191 194  221 223 224 228 239 240 249 250 253 254];


%% Get the success rates across mice and recordings
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number
c = 0;
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
                
                %Record the session num and SR
                sessionNum_data(c,:)  = [miceInd mouseData(recInd).sessionNum];
                SR_data(c,:)  = [miceInd mean([mouseData(recInd).data.successRate.A mouseData(recInd).data.successRate.C])];
            end
        end
    end
end
rampingSR = SR_data(identifiedRamping,2);
rampingSessionNum = sessionNum_data(identifiedRamping,2);

srCriterion = 0.8;
meanSuccessRates = SR_data(:,2);%mean([SR_data(:,2)';SR_data(:,3)']);
naiveInds = find( meanSuccessRates < srCriterion & sessionNum_data < 5);
expertInds = find(meanSuccessRates >= srCriterion & sessionNum_data >= 5);

percentRampingNaive = length(find(rampingSR < srCriterion))./length(naiveInds);
percentRampingExpert = length(find(rampingSR >= srCriterion))./length(expertInds);
