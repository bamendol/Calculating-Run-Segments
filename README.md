# Calculating-Run-Segments
Use ball tracking data to determine when the mouse is running.
Ball tracking data is saved in arbitrary units at 25 kHz in a structure called stimuli. The data are contained in 'stimuli.stim.'
When the mouse is completely at rest on the ball, the motion tracking values range from 2.5 to ~2.3, though this can vary depending on the particulars of your experiment.
To determine what the range for rest and non-rest for your animal is, compare the values with a behavioral recording.
Any values lower than 2.5 represent backward motion, though, again, confirm this with the behavioral recording.

This code takes the following approach to determining non-rest (referred to as run segments, though the mouse may not necessarily be running, so it is more accurate to call these segments 'non-rest'):

1. Filter out the noise using sptool (built-in Matlab filter) and downsample to 1 KHz (recommended, since we analyze LFP data at 1 kHz).

2. Determine threshold for movement vs. artifact (using behavioral recording).

3. Decide on length of time necessary for non-rest motion to count as intentional forward motion, i.e. a walk or run. For example, if the mouse only moves forward for 0.2 seconds, do you want that to count as a run?

4. Decide on length of time between non-rest segments below which you will merge the two segments. For example, if there is 0.05 seconds of data at ~ 2.5 but 0.5 seconds of forward motion on either side of these 0.5 seconds, do you want to 'merge' the two segments to make one segment of 1.05 seconds (absorbing the 0.05 seconds of supposed non-motion)?

5. Identify segments.
