# VISUAL SPEECH: localizer

script from Stefania Mattioni - adapted by Alice Van Audenhaege

March 2023

## RUN DESCRIPTION

Categories of stimuli = 2 (VisualLinguistic and NonLinguistic).
Alternation between VL-NL-VL-NL-... counterbalanced across participants (start with VL or NL)

There are 20 blocks : 10 for each condition.

This localizer should be ran only once (1 run).

## BLOCK DESCRIPTION

In each block, the full video is presented. Block duration = 15s. 

Task : 
In each block there are either 0, 1 or 2 (randomly decided) targets.
The participant has to press when he/she sees a target.
A target is when a fixation cross/dot appears on the lips for 0.5s 

## TIME CALCULATION for each RUN

2 categories x 10 vid = 20 blocks;
block duration = 15s;
IBI = 8s;
fixCross at beginning and end = 10s;

FIXED DURATION = 20x(15s+8s) + 2x10s = 480s (8min00s) 

## ACTION and VARIABLE SETTING

The only variable you need to manually change is Cfg.device at the beginning of
the script. Put either 'PC' or 'Scanner'.

Once you will Run the script you will be asked to select some variables:

1. Group: ctrl is defined as default
2. SubID : first 2 letters of Name + first 2 letters of Surname (e.g. Mickey Mouse == MiMo).
3. Start with condition : VisualLinguistic (VL) or NonLinguistic (NL)

## Script information 

The scripts works with one external function (tsvwrite) that convert the csv output to a tsv file (for BIDS analyses)

Inputs to run script : 
1. folder named Stimuli containing all the videos in .mp4 format. Videos can be found on OSF (ADD LINK)
2. tsvwrite.m function 

What has to be defined to run the script
% 1. The stimuli path
% 2. The stimuli name
% 3. You can decide if present the videos in their original size or in a
% fixed size chosen by you. To do that you need to set the size to 1
% (original) or to 2(modified). In the latter case you have to specify the
% size in pixels.

%Which output:
%The script will generate a folder named 'output_files'.
%For each participant there will be 3 output files:
% 1. Results.mat file for each run (e.g. 'StMa_Onsetfile_1.mat' for the subject StMa RUN 1)
% including the Onset, Duration, Name, Resp for Target and Non-Target Stimuli.
% 2. A .csv file for  each in which all the variables aboved are saved.
% 3. a .tsv file for  each in which all the variables aboved are saved (this compatible with BIDS analyses).
% N.B. The .csv  file will be saved also in the case the exp. is stopped
% before the end (e.g. forced to stop, the script crash etc.), while the
% mat file will be stored only if the experiment arrives till the end.

## STIMULI

To be used with a folder named `stimuli` containing the following files stored
on OSF in `VisualSpeech-loc_stimuli.zip`

https://osf.io/2xtsn/?view_only=22f09bb4dc5f4a11823103141ca2f735
