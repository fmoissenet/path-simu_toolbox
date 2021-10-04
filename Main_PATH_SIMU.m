% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/fmoissenet/NSLBP-BIOToolbox
% Reference    : To be defined
% Date         : September 2021
% -------------------------------------------------------------------------
% Description  : Main routine used to launch PATH-SIMU routines
% -------------------------------------------------------------------------
% Dependencies : To be defined
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% INIT THE WORKSPACE
% -------------------------------------------------------------------------
clearvars;
close all;
clc;

% -------------------------------------------------------------------------
% SET FOLDERS
% -------------------------------------------------------------------------
disp('Set folders');
Folder.toolbox      = 'C:\Users\beauseroy\Documents\GitHub\path-simu_toolbox\';
Folder.data         = 'C:\Users\beauseroy\Documents\GitHub\path-simu_toolbox\data\';
Folder.export       = 'C:\Users\beauseroy\Documents\GitHub\path-simu_toolbox\data\output\';
Folder.dependencies = [Folder.toolbox,'dependencies\'];
addpath(Folder.toolbox);
addpath(genpath(Folder.dependencies));
cd(Folder.toolbox);

% -------------------------------------------------------------------------
% DEFINE PARTICIPANT
% -------------------------------------------------------------------------
disp('Set participant parameters');
Participant.id           = 'Test';
Participant.gender       = 'Female'; % Female / Male
Participant.implantSide  = 'left';

% -------------------------------------------------------------------------
% DEFINE SESSION
% -------------------------------------------------------------------------
disp('Set session parameters');
Session.date              = '';
Session.type              = '';
Session.examiner          = '';
Session.participantHeight = 163; % cm
Session.participantWeight = 62; % kg
Session.markerHeight      = 0.014; % m

% -------------------------------------------------------------------------
% LOAD C3D FILES
% -------------------------------------------------------------------------
disp('Extract data from C3D files');

% List all trial types
trialTypes = {'Static',...
              'Gait self-select'};

% Extract data from C3D files
cd(Folder.data);
c3dFiles = dir('*.c3d');
k1       = 1;
k2       = 1;
for i = 1:size(c3dFiles,1)
    disp(['  - ',c3dFiles(i).name]);
    for j = 1:size(trialTypes,2)
        if contains(c3dFiles(i).name,trialTypes{j})
            if contains(trialTypes{j},'Static')
                Static(k1).type    = trialTypes{j};
                Static(k1).file    = c3dFiles(i).name;
                Static(k1).btk     = btkReadAcquisition(c3dFiles(i).name);
                Static(k1).n0      = btkGetFirstFrame(Static(k1).btk);
                Static(k1).n1      = btkGetLastFrame(Static(k1).btk)-Static(k1).n0+1;
                Static(k1).fmarker = btkGetPointFrequency(Static(k1).btk);
                Static(k1).fanalog = btkGetAnalogFrequency(Static(k1).btk);
                k1 = k1+1;
            else
                Trial(k2).type    = trialTypes{j};
                Trial(k2).file    = c3dFiles(i).name;
                Trial(k2).btk     = btkReadAcquisition(c3dFiles(i).name);
                Trial(k2).n0      = btkGetFirstFrame(Trial(k2).btk);
                Trial(k2).n1      = btkGetLastFrame(Trial(k2).btk)-Trial(k2).n0+1;
                Trial(k2).fmarker = btkGetPointFrequency(Trial(k2).btk);
                Trial(k2).fanalog = btkGetAnalogFrequency(Trial(k2).btk);
                k2 = k2+1;
            end
        end
    end
end
clear i j k1 k2 c3dFiles trialTypes;

% -------------------------------------------------------------------------
% PRE-PROCESS DATA
% -------------------------------------------------------------------------
% Static data
disp('Pre-process static data');
for i = 1%:size(Static,2) % For the moment, only one static allowed in the process
    disp(['  - ',Static(i).file]);
    
    % Get manually defined events
    Static(i).Event = [];
    
    % Process marker trajectories
    Marker            = btkGetMarkers(Static(i).btk);
    Static(i).Marker  = [];
    Static(i).Vmarker = [];
    Static(i).Segment = [];
    Static(i).Joint   = [];
    Static(i)         = InitialiseMarkerTrajectories(Static(i),Marker);
    Static(i)         = InitialiseVmarkerTrajectories(Static(i));
    Static(i)         = InitialiseSegments(Static(i));
    Static(i)         = InitialiseJoints(Static(i));
    Static(i)         = ProcessMarkerTrajectories([],Static(i));
    Static(i)         = DefineSegments(Participant,[],Static(i));
    clear Marker;
    
    % Process EMG signals
    Static(i).EMG = [];
    
    % Process forceplate signals
    Static(i).GRF = [];    
end

% Trial data
disp('Pre-process trial data');
for i = 1:size(Trial,2)
    
    disp(['  - ',Trial(i).file]);

    % Get manually defined events
    Trial(i).Event = [];
    Event          = btkGetEvents(Trial(i).btk);
    Trial(i)       = InitialiseEvents(Trial(i),Event);
    clear Event;   

    % Process marker trajectories   
    Trial(i).Marker      = [];
    Marker               = btkGetMarkers(Trial(i).btk);
    Trial(i)             = InitialiseMarkerTrajectories(Trial(i),Marker);        
    fmethod.type         = 'intercor';
    fmethod.gapThreshold = [];
    smethod.type         = 'movmean';
    smethod.parameter    = 15;        
    Trial(i)             = ProcessMarkerTrajectories(Static,Trial(i),fmethod,smethod);   
    clear Marker fmethod smethod;

    % Compute segment and joint kinematics
    Trial(i).Vmarker = [];
    Trial(i).Segment = [];
    Trial(i).Joint   = [];
    Trial(i)         = InitialiseVmarkerTrajectories(Trial(i));
    Trial(i)         = InitialiseSegments(Trial(i));
    Trial(i)         = InitialiseJoints(Trial(i));
    if isempty(strfind(Trial(i).type,'Endurance'))
        Trial(i)            = DefineSegments(Participant,Static,Trial(i));
        Trial(i)            = DefineInertialParameters(Trial(i),Participant,Session);
        Trial(i)            = ComputeKinematics(Trial(i),2,5); % Right lower limb kinematic chain
        Trial(i)            = ComputeKinematics(Trial(i),7,10); % Left lower limb kinematic chain
        Trial(i).Segment(5) = Trial(i).Segment(10); % Double pelvis segment for indices coherence
    end
    
    % Process EMG signals
    Trial(i).EMG      = [];
    EMG               = btkGetAnalogs(Trial(i).btk);
    Trial(i)          = InitialiseEMGSignals(Trial(i),EMG);
    fmethod.type      = 'butterBand4';
    fmethod.parameter = [10 450];
    smethod.type      = 'butterLow2';
    smethod.parameter = 3;
    Trial(i)          = ProcessEMGSignals(Trial(i),fmethod,smethod);
    clear EMG fmethod smethod;

    % Process forceplate signals
    Trial(i).GRF                   = [];
    Trial(i).btk                   = Correct_FP_C3D_Mokka(Trial(i).btk);
    GRF                            = btkGetGroundReactionWrenches(Trial(i).btk);
    Trial(i)                       = InitialiseGRFSignals(Trial(i),GRF);
    fmethod.type                   = 'threshold';
    fmethod.parameter              = 50;
    smethod.type                   = 'butterLow2';
    smethod.parameter              = 50;
    steps                          = [2 1]; % Right foot on forceplate 2, left foot on forceplate 1 (0 if not on forceplate)
    Trial(i)                       = ProcessGRFSignals(Trial(i),GRF,steps,fmethod,smethod);
    Trial(i).Segment(1).Q(4:6,:,:) = Trial(i).GRF(1).Signal.P.smooth; % Right foot CoP
    Trial(i).Segment(6).Q(4:6,:,:) = Trial(i).GRF(2).Signal.P.smooth; % Left foot CoP
    Trial(i).Joint(1).F            = -Trial(i).GRF(1).Signal.F.smooth;
    Trial(i).Joint(5).F            = -Trial(i).GRF(2).Signal.F.smooth;
    Trial(i).Joint(1).M            = Trial(i).GRF(1).Signal.M.smooth;
    Trial(i).Joint(5).M            = Trial(i).GRF(2).Signal.M.smooth;
    clear GRF fmethod smethod;
        
end
clear i j;

% -------------------------------------------------------------------------
% EXAMPLE: SEGMENT VISUALISATION DURING CYCLES OF INTEREST
% (with feet on forceplates)
% -------------------------------------------------------------------------

f      = Trial(1).fmarker;
weight = Session.participantWeight;
height = Session.participantHeight;
    
% Implant on the RIGHT side
if strcmp(Participant.implantSide, 'right')
    frames = Trial(1).Event(1).value(2):Trial(1).Event(1).value(3);
    n      = length(frames);


    
    for s = 1:5
        if s == 1
            Segment(s).rM    = [];
            Segment(s).Q(1:3,:,:) = [ones(1,1,n);zeros(2,1,n)]; % X axis of ICS
            Segment(s).Q(4:6,:,:) = Trial(1).Segment(s).Q(4:6,:,frames);
            Segment(s).Q(7:9,:,:) = zeros(3,1,n); % Origin of ICS
            Segment(s).Q(10:12,:,:) = [zeros(2,1,n);ones(1,1,n)]; % Z axis of ICS
            Segment(s).m     = [];
            Segment(s).rCs   = [];
            Segment(s).Is    = [];
        else
            Segment(s).rM    = Trial(1).Segment(s).rM(:,:,frames);
            Segment(s).Q     = Trial(1).Segment(s).Q(:,:,frames);
            Segment(s).m     = Trial(1).Segment(s).m;
            Segment(s).rCs   = Trial(1).Segment(s).rCs;
            Segment(s).Is    = Trial(1).Segment(s).Is;
        end
    end
    for j = 1:4
        if j == 1
            Joint(j).F     = Trial(1).Joint(j).F(:,:,frames);
            Joint(j).M     = Trial(1).Joint(j).M(:,:,frames);
        else
            Joint(j).F     = [];
            Joint(j).M     = [];
        end
    end
    Main_Segment_Visualisation_Right(Segment,1:length(Segment(2).Q));

% Implant on the LEFT side
elseif strcmp(Participant.implantSide, 'left')
    frames = Trial(1).Event(2).value(2):Trial(1).Event(2).value(3);
    n      = length(frames);


    for s = 6:10
        if s == 6
            Segment(s-5).rM    = [];
            Segment(s-5).Q(1:3,:,:) = [ones(1,1,n);zeros(2,1,n)]; % X axis of ICS
            Segment(s-5).Q(4:6,:,:) = Trial(1).Segment(s).Q(4:6,:,frames);
            Segment(s-5).Q(7:9,:,:) = zeros(3,1,n); % Origin of ICS
            Segment(s-5).Q(10:12,:,:) = [zeros(2,1,n);ones(1,1,n)]; % Z axis of ICS
           
            Segment(s-5).m     = [];
            Segment(s-5).rCs   = [];
            Segment(s-5).Is    = [];
        else
            Segment(s-5).rM    = Trial(1).Segment(s).rM(:,:,frames);
            Segment(s-5).Q     = Trial(1).Segment(s).Q(:,:,frames);
            Segment(s-5).m     = Trial(1).Segment(s).m;
            Segment(s-5).rCs   = Trial(1).Segment(s).rCs;
            Segment(s-5).Is    = Trial(1).Segment(s).Is;
        end
    end
    for j = 5:8
        if j == 5
            Joint(j-4).F     = Trial(1).Joint(j).F(:,:,frames);
            Joint(j-4).M     = Trial(1).Joint(j).M(:,:,frames);
        else
            Joint(j-4).F     = [];
            Joint(j-4).M     = [];
        end
    end
    Main_Segment_Visualisation_Left(Segment,1:length(Segment(2).Q));
    
    [Segment,Joint] = Change_L2R(Segment,Joint);
%     for s = 6:10
%         Segment(s) = Change_L2R(Segment(s),Joint(s));
%     end
%     for s = 5:8
%         Joint(s)   = Change_L2R(Segment(s),Joint(s));
%     end

end


% -------------------------------------------------------------------------
% DATA EXTRACTION as .mat file for the MSK_TLEM2_UHS_Min_f model
% -------------------------------------------------------------------------
delete C3D_Data_Extraction.mat
save('C3D_Data_Extraction', 'Segment', 'Joint', 'n', 'f', 'weight', 'height')