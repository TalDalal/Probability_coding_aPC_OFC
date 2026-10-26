function [sniffPeakVals, inhaleTimes, exhaleTimes] = extractSniffFromCSC(CSCpath, useFile, expParam)
% input:
% CSCPath is the CSC file name that contains the sniff info
% useFile = 1 will read the data from previous analysis that was saved in the disk
% output:
% sniffPeakVals - the inhale and exhale peaks values and locations
% inlaheTimes and exhaleTime - are the inhale and exhale start times


if nargin < 2
    useFile = 0;
end

sectionFactor = 1.75; % how much to look back for the zero crossing


inhaleTimes=[];
exhaleTimes=[];
sniffPeakVals=[];


% read from file if exists
fileName = [ CSCpath(1:end-4) '_SNIFF_' '.mat']
if useFile == 1 &  exist(fileName)
    disp('reading the sniff info from file')
    x = load(fileName);
    sniffPeakVals = x.sniffPeakVals;
    inhaleTimes = x.inhaleTimes;
    exhaleTimes = x.exhaleTimes;    
    return
end

% read the data from the file and filter it
[data, sampleRate] = readSniffCSC(CSCpath); %, expParam);
% this parameters are suited for awake mouse. for anesthesized: [1200 prctile(data,83)]
peakParams = [800  prctile(data,50) ];

% ask the user to define peak and trough of the sniff signal
%res = input('enter the MINPEAKDISTANCE in samples and max PEAKHEIGHT in abs value')
[maxVals , minVals] = computeMinMaxVals(data, peakParams);


% do we need to invert the signal?
if median(abs(minVals(1,1:end-1) - maxVals(1,1:end-2))) > median(abs(minVals(1,1:end-1) - maxVals(1,2:end-1)))
    %userResponse = input('shall we switch y/n ?');
    userResponse = 'y'
    if strcmp(userResponse, 'y') == 1
         disp('inverted signal! inverting it and recalculating')

        inverted = 1;
        
        data = -data;
        %[maxVals2 , minVals2] = computeMinMaxVals(data);    
        maxVals2=maxVals;
        maxVals = minVals;     minVals = maxVals2;
        maxVals(2,:) = -maxVals(2,:);
        minVals(2,:) = -minVals(2,:);
        minVals(:,1) = [];
    end
    
end

peak_num=100;

% show first 55 seconds
figure('units','normalized','outerposition',[0 0 1 1]);
subplot(4,4,[1:4])
t=0:1/(sampleRate):peak_num;
plot(t, data(1:length(t)));
xlabel('samples')
hold on;

% show last peak_num seconds

subplot(4,4,[5:8])
t = length(data)-peak_num*sampleRate:length(data);
plot(t,data(end+1-length(t):end));
xlabel('samples')
hold on;

% ask the user to define peak and trough of the sniff signal
%res = input('enter the MINPEAKDISTANCE in samples and max PEAKHEIGHT in abs value')


% [pksMax, locMax] = findpeaks(data,'MINPEAKDISTANCE', res(1) ,'MINPEAKHEIGHT', res(2));
% maxVals = [locMax; pksMax];
% 
% minVals=[];
% for i=1:size(maxVals,2)-1
%     maxLoci1 = maxVals(1,i);
%     maxLoci2 = maxVals(1,i+1);
%    
%     [a,b] = min(data(maxLoci1:maxLoci2));
%     minVals(:,i) = [b+maxLoci1, a];
%     
% end

% plot the result
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% we plot the first and last sniff so that we can see the analysis was ok

subplot(4,4,[1:4])
scatter(    maxVals(1, 1:peak_num)/sampleRate, maxVals(2, 1:peak_num), '*r')
scatter(minVals(1,1:peak_num)/sampleRate, minVals(2,1:peak_num), '*g')
%title([datFilepath '   -  first ' num2str(peak_num) ' sniff'])


% Find the zero crossing which is the real inhale start time and end times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from each peak go backwards and forward find the point we reached zero
 
%the time of maxVal(i) is before the time of  minVal(i)
zeroLoc=[];
for i=2:size(minVals,2)-1
  
    zeroInd = find(data(maxVals(1,i):minVals(1,i)) < (maxVals(2,i)+minVals(2,i))/2,1);
    if isempty(zeroInd)
        zeroInd=0;
        disp('might have a problem in analysing the sniff of this run')
    end
    
    zeroLoc(2,i) = zeroInd + maxVals(1,i);  % exhale

        
    % search from max to min the zero crossing. we look only half the
    % range as it usually very fast
    
    backSectioPartIndx = round((zeroLoc(2,i) - maxVals(1,i))*sectionFactor);
    section = data((maxVals(1,i)-backSectioPartIndx):maxVals(1,i));
    [~, zeroInd] = min(fliplr(section));
    
    
    zeroLoc(1,i) = maxVals(1,i) - zeroInd(1);
        
end
% remove the first colum of zeros
zeroLoc(:,1) = [];

scatter(zeroLoc(1,1:peak_num)/sampleRate, zeros(1,peak_num), 'om')
scatter(zeroLoc(2,1:peak_num)/sampleRate, zeros(1,peak_num), 'ok')

subplot(4,4,[5:8])

x=maxVals(1,end-peak_num:end);
% scatter(x ,maxVals(2,end-peak_num:end), '*r')
% scatter(minVals(1,end-peak_num:end) ,minVals(2,end-peak_num:end), '*g')

scatter(zeroLoc(1,end-peak_num:end) , zeros(1,length(x)), 'om')
scatter(zeroLoc(2,end-peak_num:end) , zeros(1,length(x)), 'ok')


title(['last ' num2str(peak_num) ' sniffs'])


% statistics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% plot the histogram of the max and min peak values
subplot(4,4,[9])
[a,b]=hist(maxVals(2,:),25);
plot(b,a,'.-r')
hold on
[a,b]=hist(minVals(2,:),25);
plot(b,a,'.-b')
%legend('peak max dist', 'peak min dist')

% plot the histogram of the peak to peak values
subplot(4,4,[10])
[a,b]=hist(diff(maxVals(1,:)));   % max to max diffs
plot(b,a,'.-r')
hold on
m=min(size(maxVals,2), size(minVals,2));
[a,b]=hist(maxVals(1,1:m) - minVals(1,1:m),25);   % max to min diffs
plot(b,a,'.-b')
%legend('exhale2exhale peak', 'exhale2inhale peak')




% convert the result from samples to seconds
sniffPeakVals = [maxVals(:,1:m); minVals(:,1:m)];
sniffPeakVals(1,:) = sniffPeakVals(1,:)/sampleRate;
sniffPeakVals(3,:) = sniffPeakVals(3,:)/sampleRate;
inhaleTimes = zeroLoc(1,:)/sampleRate;
exhaleTimes = zeroLoc(2,:)/sampleRate;



% plot the histogram of the inhlation and exhalation time
subplot(4,4,[11])
[a,b]=hist(exhaleTimes - inhaleTimes, 25);
plot(b,a,'.-r')
hold on
[a,b]=hist(inhaleTimes(2:end) - exhaleTimes(1:end-1),25);
plot(b,a,'.-b')
%legend('inhale times(sec)', 'exhale times(sec)')
xlabel('seconds')


% add a nother plot of the signal in the middle of the run
expDurat = length(data)/sampleRate;  % in sceonds
halfExpDurat = round(expDurat/2);  % in sceonds

subplot(4,4,[13:16])
secToShow=10;
t = halfExpDurat*sampleRate:((halfExpDurat+secToShow)*sampleRate);
t=t/sampleRate;
plot(t,data(halfExpDurat*sampleRate:((halfExpDurat+10)*sampleRate)));
xlabel('seconds')
hold on;

% mark the inhale and exhale times
indx1 = find(inhaleTimes > halfExpDurat & inhaleTimes <  halfExpDurat + secToShow);
indx2 = find(exhaleTimes > halfExpDurat & exhaleTimes <  halfExpDurat + secToShow);

scatter(inhaleTimes(indx1), zeros(1,length(indx1)), 'om')
scatter(exhaleTimes(indx2), zeros(1,length(indx2)), 'ok')


title('middle of the run; magenta is inhale start time, black is exhale start time')

disp(['saving to '  fileName])
save(fileName, 'sniffPeakVals', 'inhaleTimes', 'exhaleTimes')
%print(gcf, '-dbmp', fileName);


function [maxVals , minVals] = computeMinMaxVals(data, peakParms)

[pksMax, locMax] = findpeaks(data,'MINPEAKDISTANCE', peakParms(1) ,'MINPEAKHEIGHT', peakParms(2));
maxVals = [locMax; pksMax];

% find the min value located between each consequitive peaks
minVals=[];
for i=1:size(maxVals,2)-1
    maxLoci1 = maxVals(1,i);
    maxLoci2 = maxVals(1,i+1);
   
    [a,b] = min(data(maxLoci1:maxLoci2));
    minVals(:,i) = [b+maxLoci1, a];    
end
