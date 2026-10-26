clear;clc
[allMiceData] = concateMiceData([2 3]);% the number marks the mouse number
mouseData = allMiceData(2).allRecs;
Aflag = 1;Acolor = 'r';
Cflag = 3;Ccolor = 'm';

%% Sort the data by the session number (according to training days)
sessionNum = [];
for recInd = 1:size(mouseData,2)
    sessionNum(recInd) = mouseData(recInd).sessionNum;
end
[sortedSesNum, sessNumInds] = sort(sessionNum);
mouseData = mouseData(sessNumInds);

for faInd = 1:size(mouseData,2)
    faA(faInd) = mouseData(faInd).data.FA.A;
    faC(faInd) = mouseData(faInd).data.FA.C;
end
figure;
plot(sortedSesNum, faA, Acolor);
hold on;
plot(sortedSesNum, faC, Ccolor);