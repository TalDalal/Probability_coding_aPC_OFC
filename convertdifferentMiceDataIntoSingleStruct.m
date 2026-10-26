function [fullDataStruct] = convertdifferentMiceDataIntoSingleStruct(allMiceData, brainRegion)

if nargin < 1
    brainRegion = [];
end

% [allMiceData] = concateMiceData([2 3]);% the number marks the mouse number
c = 0;
fullDataStruct = [];
% Run across mice
for mouseInd = 1:size(allMiceData,2)
    % Run across recordings
    for recInd = 1:size(allMiceData(mouseInd).allRecs,2)
        
        % If requested, 
        if strcmpi(brainRegion, allMiceData(mouseInd).allRecs(recInd).brainRegion)
            c = c+1;
            fullDataStruct(c).data = allMiceData(mouseInd).allRecs(recInd).data;
            fullDataStruct(c).date = allMiceData(mouseInd).allRecs(recInd).date;
            fullDataStruct(c).brainRegion = allMiceData(mouseInd).allRecs(recInd).brainRegion;
            fullDataStruct(c).sessionNum = [num2str(allMiceData(mouseInd).allRecs(recInd).sessionNum) '_' num2str(mouseInd)];
        end
    end
end