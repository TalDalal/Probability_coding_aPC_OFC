function [allCriterionCrossingData] = trialToCriterionAcrossMice(allMiceData, winSize)
    criterions = [.7 .8 .2];% success rate, hit, fa

    for mouseInd = 1:size(allMiceData,2)
        currMouse = allMiceData(mouseInd).allRecs;
        
        %Compute SR vectors
        [output] = createBinaryVectorsFromAllSessions(currMouse);
        
        %Compute moving SRs
        metrics = compute_moving_success_rate(output.CS_plus_minus, output.lickNoLick, winSize, ...
                  criterions(1), criterions(2), criterions(3));
              
              
         allCriterionCrossingData(mouseInd,:) =  [metrics.success_trials_to_criterion ...
             metrics.hit_trials_to_criterion metrics.fa_trials_to_criterion];
    end
end


    
