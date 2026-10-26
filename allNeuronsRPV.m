%Load the allMiceData.
%For example: [allMiceData] = concateMiceData([2 3 13 17]);
c = 0;
for miceInd = 1:size(allMiceData,2)
    mouseData = allMiceData(miceInd).allRecs;
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                c = c + 1;
                
                allNeuronsRPV(c) = mouseData(recInd).data.NeuralData.Spikes{unitInd}.percentRefPeriodViolation;
            end
        end
    end
end
