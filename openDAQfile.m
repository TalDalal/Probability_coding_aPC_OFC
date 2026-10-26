function [fid, NumOfChan, SampRate, fileVersion, SampToRead] = openDAQfile(filename)
NumOfChan=-1;
SampRate=-1;

fid = fopen(filename);
if fid < 0
    disp([' ------> FAILED to open file: ' filename]);
    return
end



% read the first 3 values (x,y and z)
% and discard the first blocks of data
buffer_szs = fread(fid,[3],'single','s');  % you need to read the five first values not the 3 first  
SampRate = buffer_szs(1);    % sampling rate
SampToRead = buffer_szs(2);
NumOfChan = buffer_szs(3);

fileVersion = (filename(end));

        fileVersion = 0;

        fseek(fid, SampRate*NumOfChan*4, 'cof');  % ignore first chunk, I dont know why fantana kept this part                


    
