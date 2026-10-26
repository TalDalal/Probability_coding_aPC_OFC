function [output] = createBinaryVectorsFromAllSessions(currMouse)
% currMouse = allMiceData(9).allRecs;
H_L_vec = [];CS_plus_minus = [];firstLickLatency = [];lickNoLick = [];

for sessInd = 1:length(currMouse)
    if currMouse(sessInd).sessionNum > 0
        
        [dataMatrix] = createBinaryVectorsFromSessionsData(currMouse(sessInd).data, 0);
        H_L_vec = [H_L_vec dataMatrix.H_L_vec];
        CS_plus_minus = [CS_plus_minus dataMatrix.CS_plus_minus];
        firstLickLatency = [firstLickLatency dataMatrix.firstLickLatency];
        lickNoLick = [lickNoLick dataMatrix.lickNoLick];
    end
end
output.H_L_vec = H_L_vec;
output.CS_plus_minus = CS_plus_minus;
output.firstLickLatency = firstLickLatency;
output.lickNoLick = lickNoLick;



function [dataMatrix] = createBinaryVectorsFromSessionsData(params, saveFlag)


%H or L

probFlags = params.trialsIndex(find(abs(params.trialsIndex)==1 | abs(params.trialsIndex)==3));
H_L_vec = zeros(1,length(probFlags));

if params.probability.A > params.probability.C
    H_L_vec(find(abs(probFlags)==1)) = 1;
else
    H_L_vec(find(abs(probFlags)==3)) = 1;
end

%CS+ or -
CS_plus_minus = zeros(1,length(probFlags));
CS_plus_minus(find(probFlags > 0)) = 1;

firstLickLatency = params.firstLickLatency.all;
lickNoLick = params.lickIndicator(find(abs(params.trialsIndex)==1 | abs(params.trialsIndex)==3));

dataMatrix = table(H_L_vec, CS_plus_minus, firstLickLatency, lickNoLick);

if saveFlag
save(params.fullFileName, 'dataMatrix')
end
