allPassiveOdorData = [];
fileNameArray{1} = 'unitsDescription_M6_passiveOdorExposure';
fileNameArray{2} = 'unitsDescription_M9_passiveOdorExposure';
fileNameArray{3} = 'unitsDescription_M10_passiveOdorExposure';
fileNameArray{4} = 'unitsDescription_M13_passiveOdorExposure';
fileNameArray{5} = 'unitsDescription_M14_passiveOdorExposure';
fileNameArray{6} = 'unitsDescription_M17_passiveOdorExposure';
%%
for i = 1:size(fileNameArray,2)
    [allRecs] = readXLSPassiveOdors(fileNameArray{i});
    allPassiveOdorData = [allPassiveOdorData allRecs];
end

