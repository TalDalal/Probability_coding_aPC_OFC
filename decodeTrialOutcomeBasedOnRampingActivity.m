clear;clc
%Load the data
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number

% identifiedRamping = [8 9 13 14 15 18 21 22 23 26 28 30 32 33 34  50 51 52 53 54 63 66 ...
%     71 76 83 95 112 125 129 132 135 138 143 147  152 155 157 163 173 176 ...
%     179 186 189 191 194  221 223 224 228 236 239 240 249 250 253 254];

identifiedRamping = [8 9 13 14 15 18 21 22  26 28 30 32 33 34  50 51 52 53 54 63 66 ...
    71 76 83 95  132 143  155 157 163 173 176 ...
    179 189 191 194  221 223 224 228 239 240 249 250 253 254];
%%
c = 0;
psthCounter = 0;
minimalNumTrials = 5;

allDecoderSR = [];allSignificanceFlags = [];
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            ISI = mouseData(recInd).data.ISIbetweenOdors./1000;
            odorDuration = mouseData(recInd).data.odor_duration./1000;
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                
                %% Compare the firing rate in the requested window
                c = c + 1;
                if sum(c == identifiedRamping)
                    
                    psthCounter = psthCounter + 1;
                    
                    
                    %----------A------------
                    hit_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.hit.A);
                    CR_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.CR.A);
                    miss_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.miss.A);
                    FA_A = mouseData(recInd).data.allRasterPlots(unitInd).data(mouseData(recInd).data.trialOutcome.FA.A);
                    
                    correctTrials = [hit_A CR_A];
                    incorrectTrials = [miss_A FA_A];
                    
                    if length(correctTrials) > minimalNumTrials & length(incorrectTrials) > minimalNumTrials
                        [allSR, signifDecoding] = decodeHitOrMissTrial(correctTrials, incorrectTrials);
                        
                        allDecoderSR(end+1,:) = allSR;
                        allSignificanceFlags(end+1) = signifDecoding;
                    end
  
                end
            end
        end
        
    end
end

%% Plot
signifInds = find(allSignificanceFlags==1);
noSignifInds = find(allSignificanceFlags==0);

figure;
scatter(ones(1,length(allDecoderSR(signifInds,1))), allDecoderSR(signifInds,1), 'filled')
hold on;
scatter(ones(1,length(allDecoderSR(noSignifInds))), allDecoderSR(noSignifInds,1))