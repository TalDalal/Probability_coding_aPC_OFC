function [data, sampleRate, correctedFlag, Timestamps] = shared_readAndCorrectCSC(CSCpath)

% 'CSCPpath'- full path to the CSC file (for example:'D:\CheetahData\2021-10-10_12-40-46\CSC33_RESPIRATION.ncs')

% read all sniff data from the file downsample it and filter it
%Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples
correctedFlag =0 ;

[Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, ~] = Nlx2MatCSC( CSCpath, [1 1 1 1 1],1, 1, 0);
sampleRate = SampleFrequencies(1);
data = Samples(:);

% % sampling rate before correction
% sampleRateBef = length(Samples(:))/(Timestamps(end) - Timestamps(1))*10^6;

badBlocksindx = find(NumberOfValidSamples < 512);

if  badBlocksindx(1) < size(Samples,2)
    % badBlocksindx
    disp('**************************************************')
    warning(['number of invalid blocks: ' num2str(length(badBlocksindx))])
    warning(['located at ' num2str(badBlocksindx./size(NumberOfValidSamples,2)*100) '%'])
    CSCpath
    disp('**************************************************')

    correctedFlag=1;

end


%Samples(:,badBlocksindx) = [];
% exclRange=[];
% for ii=badBlocksindx
%     exclRange = [exclRange ((ii-1)*512+NumberOfValidSamples(ii)+1):((ii)*512)  ];
% end
%
%
% data(exclRange) = [];
% sampleRate = length(data)/(Timestamps(end) - Timestamps(1))*10^6;    %SampleFrequencies(1);
