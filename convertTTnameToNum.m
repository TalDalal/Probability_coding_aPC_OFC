function [params] = convertTTnameToNum(params, clusName)
params.clusNum = [];
for clsInd = 1:size(params.allRasterPlots,2)
    if strcmpi(params.allRasterPlots(clsInd).data(1).info, clusName)
        params.clusNum = clsInd;
        break;
    end
end
if isempty(params.clusNum)
    %     clc
    disp('No such TT and cluster exist in the directory')
end