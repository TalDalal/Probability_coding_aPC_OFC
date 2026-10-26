function [] = scatter_rt_diff_vs_performance(allMiceData)
% Plot the learning curve per mouse
probExpCounter = 0;


for mouseInd = 1:size(allMiceData, 2)
    
    mouseData = allMiceData(mouseInd);
    
    for recInd = 1:size(mouseData.allRecs,2)
        
        if mouseData.allRecs(recInd).sessionNum > 0
            probExpCounter = probExpCounter + 1;
            
            
            SR(probExpCounter) = mean([mouseData.allRecs(recInd).data.successRate.A mouseData.allRecs(recInd).data.successRate.C]);

            if mouseData.allRecs(recInd).data.probability.A > mouseData.allRecs(recInd).data.probability.C
                
                RT_diff(probExpCounter) = mean(mouseData.allRecs(recInd).data.firstLickLatency.A) - ...
                    mean(mouseData.allRecs(recInd).data.firstLickLatency.C);
                
            else
                RT_diff(probExpCounter) = mean(mouseData.allRecs(recInd).data.firstLickLatency.C) - ...
                    mean(mouseData.allRecs(recInd).data.firstLickLatency.A);
            end
            
            
            
            
        end
    end
end

figure;
scatter(SR.*100, RT_diff)
box off;xlabel('Performance (%)');ylabel({'\Delta reaction time (sec)', '(H - L)'})



end

