function [sniffTimes, sniffSignal, inhExh] = sniffsTimeStamps(params)
peaksOrTh = 'PEAKS';
% Extract the signal
sniffTh = params.sniffTh;
sniffSignal = params.allChnls(params.sniffChnl,:);

if strcmpi(peaksOrTh, 'PEAKS')
    sniffSignalSmooth = bandpass_signal(sniffSignal, 1000, 0.2, 30);
    peakParms = [100 0.002];
    % % find lick times
    [pksMax, locMax] = findpeaks(sniffSignalSmooth,'MINPEAKDISTANCE', peakParms(1) ,'MINPEAKHEIGHT', peakParms(2));
    sniffTimes = locMax';
    [inhExh] = detect_sniff_onsets(sniffSignalSmooth, params.sampleRate, 80);
else
    indx1 = find(sniffSignal > sniffTh);
    indx2 = find(sniffSignal <= sniffTh);
    
    sniffSignal(indx1) = 1;
    sniffSignal(indx2) = 0;
    
    sniffStartEndTimes = diff(sniffSignal);
    sniffOn = find(sniffStartEndTimes > 0);
    sniffoff = find(sniffStartEndTimes < 0);
    
    
    
    
    onOffLen = [length(sniffOn) length(sniffoff)];
    sniffOn = sniffOn(1:min(onOffLen));sniffoff = sniffoff(1:min(onOffLen));
    sniffTimes = [sniffOn; sniffoff];
end

