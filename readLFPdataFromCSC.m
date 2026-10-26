function [LFPmat] = readLFPdataFromCSC()
decimationFactor=32;
numOfChannels = 32;
for i = 1:numOfChannels+1
    CSCpath = ['LFP' num2str(i) '.ncs'];
    if i==33
        CSCpath = 'CSC33_RESPIRATION.ncs';
    end
    [~, ~, SampleFrequencies, ~, Samples, ~] = Nlx2MatCSC( CSCpath, [1 1 1 1 1],1, 1, 0);
    sampleRate = SampleFrequencies(1);
    % decimate
    data = decimate(Samples(:), decimationFactor);
    if i==1
        LFPmat = nan(numOfChannels, length(data));
    end
    sampleRate = sampleRate/decimationFactor;
    if i~= 33
        data = bandpass_signal(data,sampleRate,0.2,200);
    else
        data = bandpass_signal(data,sampleRate,0.2,20);
    end
    LFPmat(i,:) = data';
end