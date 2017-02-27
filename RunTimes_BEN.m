%Find running times --> extract run signal with GetStimulus_TS(animal, ...)
%in get_ALL_LFPs_BEN (line 27)
%goal: Look at beta power during running and not in running; compare
%1) need to filter out noise from running
%2) figure out threshold for what running is (data recorded as
%running/not-running, with 2.5 as baseline) ["Statistically significant
%lower CS was observed in C57BL/6J mice (18.0 m/min)"]
%3) define threshold for how long running must occur for it to be a run (1
%to 3 sec, but make this an input variable)
%4) extract LFPs for running times
%*Note: need to put runs in either cells or row (but in row may be
%different lengths and will need to fill in empties with NaN)

%run file at H:\data
%analysis\SLAYTraining\SLAY1-3\10-27-16\cortex\stimuli\stimuli_running

%run times are in a vector right now (variable = stimuli.stim)
%sampling rate = 25000 Hz --> 1 sec every 25000 cells of vector
%identify all values > 2.5 (baseline)
%when observing the mouse, when mouse is not moving, there are still
%fluctuations up to ~ 2.6

% nonRun = find(stimuli.stim < th); %all values below 2.6 are nonRun
% stimuli.stim(nonRun) = 0; %assign all values below 2.6 --> 0
clear Time dur merge run shiftEnd shiftStart startError segmentDur shortSegment segmentCorr

tic;
if animal == 'SLAY1-3'
    load('E:\BenA\SLAYTraining\SLAY1-3\10-27-16\cortex\stimuli\stimuli_running.mat');
elseif animal == 'SLAY1-1'
    load('E:\BenA\SLAYTraining\SLAY1-1\120116\cortex\stimuli\stimuli_running.mat');
elseif animal == 'SLAY1-2'
    load('E:\BenA\SLAYTraining\SLAY1-2\110416\cortex\stimuli\stimuli_running.mat');
end

Fs = 25e3; %sampling frequency is 25kHz
th = 2.53; %run threshold = 2.60; based on observing mice on ball

stimDownsampleNoFilt = downsample(stimuli.stim,25); %downsample to 1 kHz
stimDownsample = filtfilt(filt1.tf.num,1,stimDownsampleNoFilt); %lowpass signal < 60Hz / 25 = 2.4 (acc. to Jiannis)
endDownsample = length(stimDownsample)/1000; %end of sample in seconds
x = 0:0.001:endDownsample-0.001;
diff = mean(stimDownsample)-mean(stimDownsampleNoFilt);
stimDownsample = stimDownsample - diff; %correct for change in magnitude due to filtfilt

mindur = 300; %# frames between segments that will cause segments to merge
mintime = 1000; %min. # frames for run to count as segment
run = (stimDownsample > th); %run = 1, non-run = 0; run = find(stimuli.stim >= 2.60), gives cell #s; %gives cells in which mouse is running

stimNonRun = stimDownsample;
stimRun = stimDownsample;

stimNonRun(run) = NaN;
stimRun(~run) = NaN;

figure;
plot(x,stimDownsampleNoFilt,'g');
hold on;
plot(x,stimNonRun,x,stimRun,'r');

run = run'; %transpose row to column to use circshift
shiftStart = find(run - circshift(run,1) == 1); %shift configuration to find Start of runs; when subtract from run, 1 = start
shiftEnd = find(run - circshift(run,-1) == 1); %shift configuration to find End of runs; when subtract from run, 1 = end

Time = [shiftStart shiftEnd]; %put results as two columns in one matrix

for i = 2:length(Time)
    dur(i-1) = Time(i,1) - Time(i-1,2); %difference between Start and End = duration of runs
end

dur = dur'; %trasnspose to column
merge = find(dur<mindur); %identifies rows in which end of one run and start of next is < 5 frames
startError = Time(merge + 1); %identifies start times to replace

shiftEnd(merge) = []; %delete appropriate ends
shiftStart(merge+1) = []; %delete problematic start times
TimeCorr = [shiftStart shiftEnd];

%shiftStart(merge+1) = shiftStart(merge) ; %replace startError with value from preceding row
%shiftStart = unique(shiftStart,'rows');

segmentDur = TimeCorr(:,2) - TimeCorr(:,1); %calculate run segment lengths
shortSegment = find(segmentDur < mintime); %identify locations of short segments in TimeCorr
TimeCorr(shortSegment,:) = []; %running segments post-merge and w/o short segments
segmentCorr = TimeCorr(:,2) - TimeCorr(:,1); %calculate run segment lengths, post-merge and w/o short segments
segmentCorr = segmentCorr/Fs; %convert length in frames to length in seconds

%%plot ball motion during rest and non-rest
%TimeCorr gives frames during which animal is non-rest
%define run as frames between TimeCorr segments
%runCorr = zeros([1:length(stimDownsample)]);
figure;
plot(stimDownsample,'b');
hold on;
tic;
for z = 1:length(TimeCorr) %loop over rows of TimeCorr
    x = TimeCorr(z,1):TimeCorr(z,2);
    plot(x,stimDownsample(x),'r');
    hold on;
end
toc;
toc;