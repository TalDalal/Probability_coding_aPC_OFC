function [lickTimes, lickSignal] = lickTimeStamps(params)
lowPassFlag = 1;%Filter licks with time difference less than the physiological XX ms
lickTh = params.lickTh;
lickSignal = params.allChnls(params.lickChnl,:);


% find lick times

indx1 = find(lickSignal > lickTh);
indx2 = find(lickSignal <= lickTh);

lickSignal(indx1) = 1;
lickSignal(indx2) = 0;

lickStartEndTimes = diff(lickSignal);
lickOn = find(lickStartEndTimes > 0);
lickOff = find(lickStartEndTimes < 0);


% % correct a situation you start recoding after the experient started and
% % you lost the first event
% % if abs(length(lickOn) - length(lickOff)) > 1
% %     error('probnlem with extracting odor on set times. number of ons != number of Off')
% % end
% % Correct start ith no end
% if length(lickOn) > length(lickOff)
%     lickOn(length(lickOff)+1:end) = [];
% elseif length(lickOn) < length(lickOff)
%     lickOff(length(lickOn)+1:end) = [];
% end
%
% if length(lickOn) - length(lickOff) == -1
%     disp('correcting missing first start time of odor')
%     if lickOn(1) > lickOff(1) & lickOn(1) < lickOff(2)
%         d = mean(lickOff(2:end)-lickOn(1:end));
%         x =  lickOff(1) - d;
%         lickOn = [x lickOn];
%     end
% end
onOffLen = [length(lickOn) length(lickOff)];
lickOn = lickOn(1:min(onOffLen));lickOff = lickOff(1:min(onOffLen));
lickTimes = [lickOn; lickOff];

%%% Low pass filter off licking
if lowPassFlag
    lickWin = 80;%ms
    licksForFiltering = [];
    for lickBin = 0:lickWin:lickOn(end)-lickWin
        currBin = find(lickOn > lickBin & lickOn < lickBin+lickWin);
        if length(currBin) > 1
            licksForFiltering = [licksForFiltering currBin(2:end)];
        end
    end
    lickTimes(:, licksForFiltering) = [];
    disp(['Applied low-pass filter of ' num2str(1000/lickWin) ' Hz to the licking signal'])
end

