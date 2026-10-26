function [successRates] = getSuccessRatesForEachNeuron(allMiceData, brainRegion)

if nargin < 2
    brainRegion = 'PC';
end

%The out put matrix is the mouse number, SR for high and SR for low prob.
c = 0;
%Run across mice
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi(brainRegion,mouseData(recInd).brainRegion)
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                currUnitSR = mouseData(recInd).data.successRate;
                
                %Record the session num
                %[mouseInd High Low]
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    successRates(c,:)  = [miceInd currUnitSR.A currUnitSR.C];
                else
                    successRates(c,:)  = [miceInd currUnitSR.C currUnitSR.A];
                end
            end
        end
    end
end