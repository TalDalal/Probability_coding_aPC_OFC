odor_A_is_high = [];odor_C_is_high = [];
for miceInd = 1:size(allMiceData,2)
    
    mouseData = allMiceData(miceInd).allRecs;
    
    % Run over alll recordings
    for recInd = 1:size(mouseData,2)
        
        %Only PC recordings
        if strcmpi('PC',mouseData(recInd).brainRegion)
            
            
            %Run across units per recording
            for unitInd = 1:size(mouseData(recInd).data.firingRates,2)
                
                if mouseData(recInd).data.probability.A > mouseData(recInd).data.probability.C
                    odor_A_is_high(end+1) = 1;
                    
                else
                    odor_C_is_high(end+1) = 1;
                end
                

            end
        end
    end
end