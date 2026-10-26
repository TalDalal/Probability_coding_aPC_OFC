function [data, sampleRate] = readSniffCSC(CSCpath)

% read all sniff data from the file downsample it and filter it
[~, ~, SampleFrequencies, ~, Samples, ~] = Nlx2MatCSC( CSCpath, [1 1 1 1 1],1, 1, 0);
sampleRate = SampleFrequencies(1);
% decimate and filter out > 20 hz
decimationFactor=10;
data = decimate(Samples(:), decimationFactor);
data = bandpass_signal(data,sampleRate/decimationFactor,0.2,20);
sampleRate = sampleRate/decimationFactor;