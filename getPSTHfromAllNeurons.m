function [PSTHstruct] = getPSTHfromAllNeurons(allMiceData, trialsIncluded, equalizeTrialNum, brainRegion)

if nargin < 4
    brainRegion = 'PC';
end

c = 0;
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
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                % Decide which trials to take
                switch trialsIncluded
                    case 'allTrials'
                        rasterA = params.allRasterPlots(unitInd).data(params.Atrials);
                        rasterC = params.allRasterPlots(unitInd).data(params.Ctrials);
                    case 'CS+'
                        rasterA = params.allRasterPlots(unitInd).data(params.targetTrials.A);
                        rasterC = params.allRasterPlots(unitInd).data(params.targetTrials.C);
                    case 'CS-'
                        rasterA = params.allRasterPlots(unitInd).data(params.tMinusTrials.A);
                        rasterC = params.allRasterPlots(unitInd).data(params.tMinusTrials.C);
                end
                if isempty(rasterA) | isempty(rasterC)
                    continue;
                end
                % Compute the PSTH
                [R,t] = mypsth(rasterA, .1, 'n');
                currPSTH_A = [t;R];
                
                [R,t] = mypsth(rasterC, .1, 'n');
                currPSTH_C = [t;R];
                
                %Assign by probability
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    PSTHstruct(c).high = currPSTH_A;
                    PSTHstruct(c).low = currPSTH_C;
                    PSTHstruct(c).rasterHigh = rasterA;
                    PSTHstruct(c).rasterLow = rasterC;
                else
                    PSTHstruct(c).high = currPSTH_C;
                    PSTHstruct(c).low = currPSTH_A;
                    PSTHstruct(c).rasterHigh = rasterC;
                    PSTHstruct(c).rasterLow = rasterA;
                end
                    
            end
        end
    end
end