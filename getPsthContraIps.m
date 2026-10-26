function [A, stimuliDuration] = getPsthContraIps(allNeurons, ind, responseType, timeRange, suffel)
 

A = [];

switch(responseType)
        case{1}  % contra-exc
            [A] = simplePsth(allNeurons(ind).contraW(1).lp, allNeurons(ind).contraW(1).maxind, timeRange);
            stimuliDuration = allNeurons(ind).contraW(1).lp.stimuliDuration;
                
            specificIndx = allNeurons(ind).specificIndxInContraPsthStruct;
            if specificIndx > 0  % we a psth of a specific run
                A = allNeurons(ind).contraPsth(specificIndx).psth;
            end
        
            if suffel
                randomSpotInd = randperm(length(allNeurons(ind).contraW(1).w),1);

                [A] = simplePsth(allNeurons(ind).contraW(1).lp, randomSpotInd, timeRange);
            end

        case{2} % contra-inh
            [A] = simplePsth(allNeurons(ind).contraW(1).lp, allNeurons(ind).contraW(1).minind, timeRange);
            stimuliDuration = allNeurons(ind).contraW(1).lp.stimuliDuration;

            if suffel
                randomSpotInd = randperm(length(allNeurons(ind).contraW(1).w),1);

                [A] = simplePsth(allNeurons(ind).contraW(1).lp, randomSpotInd, timeRange);
            end

            
        case{3} %ipsi-exh
            [A] = simplePsth(allNeurons(ind).ipsiW(1).lp, allNeurons(ind).ipsiW(1).maxind, timeRange);
            stimuliDuration = allNeurons(ind).ipsiW(1).lp.stimuliDuration;
            
            if suffel
                randomSpotInd = randperm(length(allNeurons(ind).ipsiW(1).w),1);

                [A] = simplePsth(allNeurons(ind).ipsiW(1).lp, randomSpotInd, timeRange);
            end


    end
