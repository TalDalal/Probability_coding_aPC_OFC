function [allPSTHs, cutTimeBins, deletedNeurons] = normalizePSTHsAndSortToExcorInh(PSTHstruct,bgPeriod, psthTimeWin, conditionType, Z_flag)

if nargin < 5
    Z_flag = 0;
end
firstLastPSTHvalue = [psthTimeWin(1)-1 psthTimeWin(2) + 1];
allPSTHs = [];deletedNeurons = [];

for psthInd = 1:size(PSTHstruct,2)
    
    switch conditionType
        
        case 'High'
            
            %Current PSTH and time vector
            currPSTH_High = PSTHstruct(psthInd).high(2,:);
            currTime_High = PSTHstruct(psthInd).high(1,:);
            
            %Compute the bins of the time vector
            currTimeBin = round(median(diff(currTime_High)),3);
            
            %Find the first index
            %             if currTime_A(1) < firstLastPSTHvalue(1)
            firstInd = find(currTime_High >= firstLastPSTHvalue(1),1);
            finalPSTHlength = diff(firstLastPSTHvalue)/currTimeBin;
            
            if currTime_High(1) < bgPeriod(2) & (firstInd + finalPSTHlength) < length(currPSTH_High)
                
                cutPSTH_High = currPSTH_High(firstInd: firstInd + finalPSTHlength);
                
                % normalize
                baseline_High = currPSTH_High(find(currTime_High >= bgPeriod(1) & currTime_High < bgPeriod(2)));
                meanBaseline_High = mean(baseline_High);
                meanBaseline_High(isnan(meanBaseline_High)) = 0;
                
                if Z_flag
                    [Z_cutPSTH_High] = zscorePSTH(cutPSTH_High, PSTHstruct(psthInd).rasterHigh, bgPeriod);
                else
                    Z_cutPSTH_High = cutPSTH_High - meanBaseline_High;
                end
                
                allPSTHs(end+1,:) = Z_cutPSTH_High;
                
            else
                disp('Skipped one neuron due to lack of spikes')
                deletedNeurons(end+1) = psthInd;
            end
            
        case 'Low'
            
            %Current PSTH and time vector
            currPSTH_Low = PSTHstruct(psthInd).low(2,:);
            currTime_Low = PSTHstruct(psthInd).low(1,:);
            
            %Compute the bins of the time vector
            currTimeBin = round(median(diff(currTime_Low)),3);
            
            %Find the first index
            %             if currTime_C(1) < firstLastPSTHvalue(1)
            
            firstInd = find(currTime_Low >= firstLastPSTHvalue(1),1);
            finalPSTHlength = diff(firstLastPSTHvalue)/currTimeBin;
            
            if currTime_Low(1) < bgPeriod(2) & (firstInd + finalPSTHlength) < length(currPSTH_Low)
                cutPSTH_Low = currPSTH_Low(firstInd: firstInd + finalPSTHlength);
                
                
                %Normalize
                baseline_Low = currPSTH_Low(find(currTime_Low >= bgPeriod(1) & currTime_Low < bgPeriod(2)));
                meanBaseline_Low = mean(baseline_Low);
                meanBaseline_Low(isnan(meanBaseline_Low)) = 0;
                
                if Z_flag
                    [Z_cutPSTH_Low] = zscorePSTH(cutPSTH_Low, PSTHstruct(psthInd).rasterLow, bgPeriod);
                else
                    Z_cutPSTH_Low = cutPSTH_Low - meanBaseline_Low;
                end
                
                allPSTHs(end+1,:) = Z_cutPSTH_Low;
                
            else
                disp('Skipped one neuron due to lack of spikes')
                deletedNeurons(end+1) = psthInd;
            end
    end
    
end
cutTimeBins = firstLastPSTHvalue(1):currTimeBin:firstLastPSTHvalue(2);
end


function [zPSTH] = zscorePSTH(psth, rasterPlot, bgPeriod)

for trialInd = 1:size(rasterPlot,2)
    
    currTrial = rasterPlot(trialInd).times;
    bgActivity(trialInd) = length(find(currTrial > bgPeriod(1) & currTrial < bgPeriod(2)))./diff(bgPeriod);
    
end

zPSTH = (psth - mean(bgActivity))./std(bgActivity);
end