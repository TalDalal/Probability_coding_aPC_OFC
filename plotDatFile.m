function [channelsData, t] = plotDatFile(filePath,  startEndTime, wantedCnl)
% help: plotDatFile
% filePath: the dat file full path to read
% startEndTime: start and end times to read in seconds. e.g. [0 10] read
% the first 10 seconds
% example: [channelsData] = plotDatFile( 'm18_13_111003_165856.DAT', [0
% 3]); plot the first 3 second 

startEndTime(1) = floor(startEndTime(1));
startEndTime(2) = ceil(startEndTime(2));


startTime = startEndTime(1);
endTime = startEndTime(2);


readSize = 100000;
fid=0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read the neuron data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[fid, NumOfChan, sampleRate]  = openDAQfile(filePath);

startPoint = startTime*sampleRate;
endPoint= endTime*sampleRate;

% seek to startPoint
readSize = startPoint;

figure;
% read to the end point
channelsData=[];
readSize = endPoint - startPoint+1;
while readSize > 0
    [readData] = readDAQfileChuncks(fid, wantedCnl, min(10^6,readSize) , NumOfChan );
    channelsData = [channelsData readData];
    acum_channelsData = size(channelsData);
    readSize = readSize - 10^6;
end


% calculate the time we are
df = 1/sampleRate;
t = startTime:df:endTime;

if length(t) > length(channelsData)
    t(end) = [];
end

clr='rbkgm';
for i=size(channelsData,1):-1:1
    plot(t, channelsData(i,:) , clr(i));  % light signals
    hold on;
end


xlabel('Seconds')
%title(['Neuron: ' datFile]);
fclose(fid);

title(['file: ' filePath]);

