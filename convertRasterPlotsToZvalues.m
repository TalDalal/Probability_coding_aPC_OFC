function [zValues] = convertRasterPlotsToZvalues(rasterData, bgWin, fgWin)
    for ind = 1:size(rasterData,2)
%         figure;
%         mypsth(rasterData{ind}, 0.05)
%         close;
        [zValues(ind)] = computeZscorefromRaster(rasterData{ind}, bgWin, fgWin);
    end
end
        