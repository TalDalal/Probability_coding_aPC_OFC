function [dataChunk] = readDAQfileChuncks(fid, requiredChannels, readSize, NumOfChan )
% Read the channel information from ChaNum and only maxByte
% this function assumes that the file structure is as follows:
% first line: [x y z] where x is the blocak size that is not needed , y is the clock ? and z is the
% number of recorded channels
% the rest of the file is composed of lines with each channel values are
% interleaved. e.g. if we have 2 channels and they have happend to report
% the values 1 and 2 corresponingly we will have a file that looks like:
% 30000 1000 2 [....][.....]12121212
%
% Output: a matrix of channel X data

channelsData =[];

%readSize=3*10^6;
dataChunk = fread(fid, [NumOfChan readSize],'single','s');

if sum(size(dataChunk,2)) == 0
    return
end

if size(dataChunk,2)  < readSize
  disp('warnning: reading less then requested ');
end

% remove unneccary channels
dataChunk = dataChunk(requiredChannels,:);

