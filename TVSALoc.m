tic
%%%%%TVSA LOCALIZER %%%%%%%
%%script from Stefania Mattioni - adapted by Alice Van Audenhaege
% March2023

%%RUN DESCRIPTION
% There are 20 blocks.
% Categories of stimuli = 2 (VisualLinguistic and NonLinguistic). Alternation
% VL-NL-VL-NL-....
% counterbalanced across participants (Start with VL or NL).


%%BLOCK DESCRIPTION
% In each block, the full video is presented  
% In each block there are either 0, 1 or 2 (randomly decided) targets.
% The participant has to press when he/she sees a target.
% A target is when a fixation cross/dot appears on the lips for 0.5s (?? confirmer la durée de target). 
% Each block has a duration 15s.


%TIME CALCULATION for each RUN
% 2 categories x 10 vid = 20 blocks;
% block duration = 15s;
% IBI = 8s;
% fixCross at beginning and end = 10s;
% 
% FIXED DURATION = 20x(15s+8s) + 2x10s = 480s (8min00s) 

%ACTION and VARIABLE SETTING
%The only variable you need to manually change is Cfg.device at the
%beginning of the script. Put either 'PC' or 'Scanner'.
%Once you will Run the script you will be asked to select some variables:
%1. Group (TO DEFINE): %%for the moment only controls CON is defined as
%default
%2. SubID : first 2 letters of Name + first 2 letters of Surname (e.g. Stefania Mattioni == StMa).
%3. Start with condition : VisualLinguistic or NonLinguistic


%%%SCRIPT INFORMATION%%%
% The scripts works with one external function (tsvwrite) that convert the csv output to a tsv file (for BIDS analyses)

%What is needed to run the script (inputs):
% 1. a folder named Stimuli containing all the videos in .mp4 format
% 2. tsvwrite.m function 

%What has to be defined to run the script
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

clear all;
clc;
commandwindow; %move the cursor to the command window so responses will not printed on the script




%% SET THE MAIN VARIABLES
global  GlobalExpID GlobalSubjectID GlobalStartCond

GlobalExpID= 'TVSALoc';
GlobalSubjectID=input('Subject ID(e.g. 01):', 's'); 
GlobalStartCond = input('Start run with condition ling (1) or non-ling (2)?', 's');

%% TRIGGER
numTriggers = 1;         % num of excluded volumes (first 2 triggers) [NEEDS TO BE CHECKED]
Cfg.triggerKey = 's';        % the keycode for the trigger

%% SETUP OUTPUT DIRECTORY AND OUTPUT FILE
%if it doesn't exist already, make the output folder
output_directory='output_files';
if ~exist(output_directory, 'dir')
    mkdir(output_directory);
end

output_file_name= strcat(output_directory,'/sub-', GlobalSubjectID, '_task-', GlobalExpID,'_events','.csv');
output_file_name_tab= strcat(output_directory,'/sub-', GlobalSubjectID, '_task-', GlobalExpID,'_events','.tsv');

logfile=fopen(output_file_name,'a');%'a'== PERMISSION: open or create file for writing; append data to end of file
fprintf(logfile,'\n');
fprintf(logfile,'onset,duration,trial_type,stim_name,time_loop,Response_key\n');%name of columns
     



%% DEFINE THE STIMULI NAME, THE PATH & THE SIZE OF THE STIMULI%%

%stim path
stim_path=fullfile(cd,'Stimuli/');

rng('shuffle');
%stim names and order
stimNL={'NL01', 'NL02', 'NL03', 'NL04', 'NL05', 'NL06', 'NL07', 'NL08', 'NL09', 'NL10'};
stimVL={'VL01', 'VL02', 'VL03', 'VL04', 'VL05', 'VL06', 'VL07', 'VL08', 'VL09', 'VL10'};

%%for debug only open this
% stimNL={'NL02'};
% stimVL={'VL02'};


stimNL_order = Shuffle(stimNL);
stimVL_order = Shuffle(stimVL);


if str2double(GlobalStartCond) == 1
    cond1 = stimVL_order;
    cond2 = stimNL_order; 
else
    cond1 = stimNL_order; 
    cond2 = stimVL_order;
end

AllStim = [cond1; cond2];
AllStim_order = AllStim(:)' ;


%load targets defined once at begining of the study
load targets.mat


%STIM SIZE

%For the original size open this part
% %Set the size to 1 to present the video in their original size
size=1;

%For the modified size open this part
%Set the size to 2 to present the video in a different size and select the
% %size (in pixels) (to keep the ratio: 400-225/450-253/500-281

% size=2;
% Width_modified= 700; %width video 1 in pixels
% Height_modified=394; %height video 1 in pixels


%Set the times
StimLength=15;
timeout=8;
%Baseline times (in sec)
Baseline_start=10;
Baseline_end=10;

% FIX CROSS
crossLength=50;
crossColor=[200 200 200];
crossColorEnd=[150 150 150]; 
crossWidth=7;
%Set start and end point of lines
crossLines=[-crossLength, 0; crossLength, 0; 0, -crossLength; 0, crossLength];
crossLines=crossLines';

targDur = 0.5;

% Open the screen
Screen('Preference', 'SkipSyncTests', 1);
PsychDebugWindowConfiguration();

[wPtr, rect]= Screen('OpenWindow',max(Screen('Screens'))); %open the screen
Screen('FillRect',wPtr,[0 0 0]); %draw a rectangle (big as all the monitor) on the back buffer
Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
HideCursor(wPtr);

% STIMULUS RECTANGLE (in the center)
screenWidth = rect(3);
screenHeight = rect(4);%-(rect(4)/3); %this part is to have it on the top of te screen
screenCenterX = screenWidth/2;
screenCenterY = screenHeight/2;
%stimulusRect=[screenCenterX-stimSize/2 screenCenterY-stimSize/2 screenCenterX+stimSize/2 screenCenterY+stimSize/2];

%save the response keys into a cell array
RespKey = num2cell(zeros(1,length(AllStim_order)));
Onset = zeros(1,length(AllStim_order));
Name=num2cell(zeros(1,length(AllStim_order)));
Duration=zeros(1,length(AllStim_order));

%% OPEN THE SCREEN
try %the 'try and chatch me' part is added to close the screen in case of an error so that you can see the command window and not get stucked with the blank screen)
    
    
    %% TRIGGER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Screen('TextSize', wPtr, 50);%text size
    DrawFormattedText(wPtr, '\n READY TO START', 'center','center',[255 255 255]);
    Screen('Flip', wPtr);
    HideCursor(wPtr);
    
    disp ('Wait for trigger...');
    
    %%%
    triggerCounter=0;
    while triggerCounter < numTriggers
        
        [keyIsDown, ~, keyCode, ~] = KbCheck(-1);
        
        if strcmp(KbName(keyCode),Cfg.triggerKey)
            triggerCounter = triggerCounter+1;
            
            DrawFormattedText(wPtr,[num2str(numTriggers-triggerCounter)],... %%countdown for the trigger
                'center', 'center',[255 255 255] );
            Screen('Flip', wPtr);
            
            while keyIsDown
                [keyIsDown, ~, keyCode, ~] = KbCheck(-1);
            end
            
        end
    end
    
    %Draw THE FIX CROSS
    Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
    % Flip the screen
    Screen('Flip', wPtr);
    
    disp 'Trigger ok: experiment starting!'; %print this on command window
    
    LoopStart=GetSecs();
    WaitSecs(Baseline_start);
    %% Start the loop for each video
    for iStim=1:length(AllStim_order)
        
        Screen('FillRect',wPtr,[0 0 0]); %draw a rectangle (big as all the monitor) on the back buffer
        Screen ('Flip',wPtr); %flip the buffer, showing the rectangle
        
        %Find the stim name
        Stim_name=AllStim_order{iStim};
        %Set the movie and filename
        pathToMovie=strcat(stim_path,AllStim_order{iStim},'.mp4');
        
        %Set clip info
        toTime=inf; %second to stop in movie
        soundvolume=0; %0 to 1
        
        %disp on command window
        disp (strcat('Presenting stimulus',num2str(iStim), '(', Stim_name, ')'));
        
        respTime = [];
        responseKey = [];
        r = 1; %counter for response (will increase at each resp)
        
        %show the movie one time
        for i=1
%             Start_time=GetSecs();
            
            %Open the movie
            [movie,dur,fps,width,height]=Screen('OpenMovie',wPtr,pathToMovie);
            
            %Define the size of the videos according to what has been
            %defined at the beginning of the scipt
            
            if size==1 %original size
                stimulusRect=[screenCenterX-width/2 screenCenterY-height/2 screenCenterX+width/2 screenCenterY+height/2];
            elseif size==2 %modified size
                stimulusRect=[screenCenterX-Width_modified/2 screenCenterY-Height_modified/2 screenCenterX+Width_modified/2 screenCenterY+Height_modified/2];
            end
            

            %Play the movie
            Screen('PlayMovie', movie,1,0,soundvolume);
            %Mark starting time
            Start_time=GetSecs();
            %loop through each frame of the movie and present it
            
            while Start_time<toTime
                
                % register the keypress
                [keyIsDown, secs, keyCode] = KbCheck(-1);
                if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                    respTime(r) = secs-LoopStart;
                    responseKey(r) = KbName(find(keyCode));
                    fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', respTime(r),0,'response','n/a',0,responseKey(r));
                    r = r+1;
                    FlushEvents();
                end
                
                %get the texture
                tex=Screen('GetMovieImage',wPtr,movie);
                
                
                %if there is no texture we are at the end of the movie
                if tex<=0
                    break;
                end
                
                
                %draw the texture (in this part you can set the position
                %of the video on the screen)
                Screen('DrawTexture',wPtr,tex,[],stimulusRect);
                
                %Screen('Flip', wPtr); %display the info visually
%                 t=Screen('Flip',wPtr);
                Screen('Flip',wPtr);
                %discard this texture
                Screen('Close',tex);
                
            end
            %if the 15 sec did not pass stay on the last fotogramma
            while (GetSecs-Start_time)<=(StimLength)
               
                %do nothing
            end
            %Stop the movie
            Screen('PlayMovie',movie,0);
            
            
            %Close the movie
            Screen('CloseMovie',movie);
        end
        Video_end_time=GetSecs();
        Duration(iStim)= Video_end_time-Start_time; %%
        
        %display duration in command window
        disp (strcat('stim was ',num2str(Duration(iStim)), 'seconds long'));
        %%%FIX CROSS
        
        Screen('DrawLines',wPtr,crossLines,crossWidth,crossColor,[screenCenterX,screenCenterY]);
        % Flip the screen
        cross_time= Screen('Flip', wPtr);
        
%         while (GetSecs-(cross_time))<=(timeout)
            
         while (GetSecs-(cross_time))<=(23-Duration(iStim)) %%
            [keyIsDown, secs, keyCode] = KbCheck(-1);
            if keyIsDown && min(~strcmp(KbName(keyCode),Cfg.triggerKey))
                respTime(r) = secs-LoopStart;
                responseKey(r) = KbName(find(keyCode));
                fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', respTime(r),0,'response','n/a',0,responseKey(r));
                r = r+1;
                FlushEvents();
            end
        end
        End_time=GetSecs();
        Name(iStim) = AllStim_order(iStim);
        RespKey(iStim) = {responseKey};
        RespTime(iStim) = {respTime};
        Onset(iStim)=  Start_time-LoopStart;
        
        if Name{1,iStim}(1)=='N'
            trial_type='NL';
        else
            trial_type='VL';
        end
           
        
        %         Duration(iStim)= Video_end_time-Start_time;
        %print the variable in the .csv file   title = 'onset,duration,trial_type,stim_name, time_loop,Response_key
        fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim),Duration(iStim),trial_type,AllStim_order{iStim},End_time-Start_time,'n/a'); 
        
        if Name{1,iStim}(4)=='2'
            type='target';
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(2,1),targDur,type,'n/a',0,'n/a');
        elseif Name{1,iStim}(4)=='3'
            type='target';
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(3,1),targDur,type,'n/a',0,'n/a');
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(3,2),targDur,type,'n/a',0,'n/a');
        elseif Name{1,iStim}(4)=='5'
            type='target';
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(5,1),targDur,type,'n/a',0,'n/a');
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(5,2),targDur,type,'n/a',0,'n/a');
        elseif Name{1,iStim}(4)=='7'
            type='target';
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(7,1),targDur,type,'n/a',0,'n/a');
        elseif Name{1,iStim}(4)=='8'
            type='target';
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(8,1),targDur,type,'n/a',0,'n/a');
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(8,2),targDur,type,'n/a',0,'n/a');
        elseif Name{1,iStim}(4)=='9'
            type='target';
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(9,1),targDur,type,'n/a',0,'n/a');
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(9,2),targDur,type,'n/a',0,'n/a');
        elseif Name{1,iStim}(4)=='0'
            type='target';
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(10,1),targDur,type,'n/a',0,'n/a');
            fprintf(logfile,'%d,%d,%s,%s,%d,%s\n', Onset(iStim)+targetSave(10,2),targDur,type,'n/a',0,'n/a');
        end
 
    end%for iStim
    
    WaitSecs(Baseline_end);
    LoopEnd=GetSecs();
    disp (strcat( 'The time for the run took min:', num2str ((LoopEnd-LoopStart)/60))); 
    
    %%%%%This part it is added to if the script end before the data
    %%%%%acquisitions the subject  will se the fix cross and not the matlab
    %%%%%screen.
    %wait for any key pressed to close the screen
    disp 'Press SPACE to quit';
    
    ActiveKey= [KbName('space')];%select the key you want to stay active for kbwait
    RestrictKeysForKbCheck(ActiveKey); % make it active
    KbWait(-1); %will only work with  space
    
    %create a .tsv file with tab delimiter (better for BIDS analyses)
    table= readtable(output_file_name);
    tsvwrite(output_file_name_tab,table);
    
    %save the variables in a .mat file
    cd('output_files')
    save(strcat ('sub-',GlobalSubjectID,'_Onsetfile_',GlobalExpID,'.mat'),'Onset','Name','Duration','RespKey','RespTime');

    
catch ME %the 'try and chatch me' part is added to close the screen in case of an error so that you can see the command window and not get stucked with the blank screen)
    Screen('CloseAll');
    rethrow(ME);
end %try


%Clear the screen
clear Screen;
sca;

toc

