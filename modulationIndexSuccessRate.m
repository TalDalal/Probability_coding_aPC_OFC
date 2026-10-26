[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number
%%
figure;
hold all;
for mouseInd = 1:size(allMiceData,2)
    mouseData = allMiceData(mouseInd).allRecs;
    sessionNum = [];
    for recInd = 1:size(mouseData,2)
        sessionNum(recInd) = mouseData(recInd).sessionNum;
    end
    [sortedSessNum, sessNumInds] = sort(sessionNum);
    mouseData = mouseData(sessNumInds);
    MI_SR = [];
    for recInd = 1:size(mouseData,2)
        MI_SR(recInd) = (mouseData(recInd).data.successRate.A-mouseData(recInd).data.successRate.C)./ ...
            (mouseData(recInd).data.successRate.A+mouseData(recInd).data.successRate.C);
    end
    plot(sortedSessNum, MI_SR);
    
    
end
box off;ylim([-.5 .5])
xlabel('Sessions');ylabel('Success rate modulation index')
set(gca, 'FontSize', 14');box off;