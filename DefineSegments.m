% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : To be defined
% Reference    : To be defined
% Date         : September 2021
% -------------------------------------------------------------------------
% Description  : To be defined
% Inputs       : To be defined
% Outputs      : To be defined
% -------------------------------------------------------------------------
% Dependencies : None
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function Trial = DefineSegments(Participant,Static,Trial)

% -------------------------------------------------------------------------
% Pelvis parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RASI = Trial.Marker(1).Trajectory.smooth;
LASI = Trial.Marker(2).Trajectory.smooth;
RPSI = Trial.Marker(3).Trajectory.smooth;
LPSI = Trial.Marker(4).Trajectory.smooth;
% Pelvis axes (Dumas and Wojtusch 2018)
Z5 = Vnorm_array3(RASI-LASI);
Y5 = Vnorm_array3(cross(RASI-(RPSI+LPSI)/2, ...
                        LASI-(RPSI+LPSI)/2));
X5 = Vnorm_array3(cross(Y5,Z5));
% Determination of the lumbar joint centre by regression (Dumas and Wojtusch 2018)
if ~isempty(Static)
    % Determination of the lumbar joint centre by singular value decomposition
    % based on the static record
    RASIs = Static.Marker(1).Trajectory.smooth;
    LASIs = Static.Marker(2).Trajectory.smooth;
    RPSIs = Static.Marker(3).Trajectory.smooth;
    LPSIs = Static.Marker(4).Trajectory.smooth;
    LJCs  = Static.Vmarker(9).Trajectory.smooth;
    for t = 1:Trial.n1
        [R5,d5,rms5] = soder([RASIs';RPSIs';LPSIs';LASIs'],...
                             [RASI(:,:,t)';RPSI(:,:,t)';LPSI(:,:,t)';LASI(:,:,t)']);  
        LJC(:,:,t)   = R5*LJCs+d5;
        clear R5 d5 rms5;
    end
else
    % Pelvis width
    W5 = mean(sqrt(sum((RASI-LASI).^2)),3);
    % Determination of the lumbar joint centre by regression (Dumas and Wojtusch 2018)
    if strcmp(Participant.gender,'Female')
        LJC(1) = -34.0/100;
        LJC(2) = 4.9/100;
        LJC(3) = 0.0/100;
    elseif strcmp(Participant.gender,'Male')
        LJC(1) = -33.5/100;
        LJC(2) = -3.2/100;
        LJC(3) = 0.0/100;
    end
    LJC = (RASI+LASI)/2 + ...
          LJC(1)*W5*X5 + LJC(2)*W5*Y5 + LJC(3)*W5*Z5;
end
% Store virtual marker
Trial.Vmarker(9).label             = 'LJC';
Trial.Vmarker(9).Trajectory.smooth = LJC;
% Determination of the hip joint centre by regression (Dumas and Wojtusch 2018)
if ~isempty(Static)
    % Determination of the hip joint centre by singular value decomposition
    % based on the static record
    RASIs = Static.Marker(1).Trajectory.smooth;
    LASIs = Static.Marker(2).Trajectory.smooth;    
    RPSIs = Static.Marker(3).Trajectory.smooth;
    LPSIs = Static.Marker(4).Trajectory.smooth;
    RHJCs = Static.Vmarker(4).Trajectory.smooth;
    LHJCs = Static.Vmarker(8).Trajectory.smooth;
    for t = 1:Trial.n1
        [R5,d5,rms5] = soder([RASIs';RPSIs';LPSIs';LASIs'],...
                             [RASI(:,:,t)';RPSI(:,:,t)';LPSI(:,:,t)';LASI(:,:,t)']);  
        RHJC(:,:,t)  = R5*RHJCs+d5;  
        LHJC(:,:,t)  = R5*LHJCs+d5;
        clear R5 d5 rms5;
    end
else
    % Determination of the hip joint centre by regression (Dumas and Wojtusch 2018)
    if strcmp(Participant.gender,'Female')
        R_HJC(1) = -13.9/100;
        R_HJC(2) = -33.6/100;
        R_HJC(3) = 37.2/100;
        L_HJC(1) = -13.9/100;
        L_HJC(2) = -33.6/100;
        L_HJC(3) = -37.2/100;
    elseif strcmp(Participant.gender,'Male')
        R_HJC(1) = -9.5/100;
        R_HJC(2) = -37.0/100;
        R_HJC(3) = 36.1/100;
        L_HJC(1) = -9.5/100;
        L_HJC(2) = -37.0/100;
        L_HJC(3) = -36.1/100;
    end
    RHJC = (RASI+LASI)/2 + ...
           R_HJC(1)*W5*X5 + R_HJC(2)*W5*Y5 + R_HJC(3)*W5*Z5;
    LHJC = (RASI+LASI)/2 + ...
           L_HJC(1)*W5*X5 + L_HJC(2)*W5*Y5 + L_HJC(3)*W5*Z5;
end
% Store virtual markers
Trial.Vmarker(4).label             = 'RHJC';
Trial.Vmarker(4).Trajectory.smooth = RHJC;  
Trial.Vmarker(8).label             = 'LHJC';
Trial.Vmarker(8).Trajectory.smooth = LHJC;
% Pelvis parameters (Dumas and Chèze 2007) = Pelvis duplicated to manage
% different kinematic chains
rP5                  = LJC;
rD5                  = (RHJC+LHJC)/2;
w5                   = Z5;
u5                   = X5;
Trial.Segment(5).Q   = [u5;rP5;rD5;w5];
Trial.Segment(5).rM  = [RASI,LASI,RPSI,LPSI];
Trial.Segment(10).Q  = [u5;rP5;rD5;w5];
Trial.Segment(10).rM = [RASI,LASI,RPSI,LPSI];

% -------------------------------------------------------------------------
% Right femur parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RTHI = Trial.Marker(5).Trajectory.smooth;
RKNE = Trial.Marker(6).Trajectory.smooth;
RKNI = Trial.Marker(7).Trajectory.smooth;
CRT1 = Trial.Marker(8).Trajectory.smooth;
CRT2 = Trial.Marker(9).Trajectory.smooth;
CRT3 = Trial.Marker(10).Trajectory.smooth;
CRT4 = Trial.Marker(11).Trajectory.smooth;
% Knee joint centre
RKJC = (RKNE+RKNI)/2;
% Store virtual marker
Trial.Vmarker(3).label             = 'RKJC';
Trial.Vmarker(3).Trajectory.smooth = RKJC;
% Femur axes (Dumas and Wojtusch 2018)
Y4 = Vnorm_array3(RHJC-RKJC);
X4 = Vnorm_array3(cross(RKNE-RHJC,RKJC-RHJC));
Z4 = Vnorm_array3(cross(X4,Y4));
% Femur parameters (Dumas and Chèze 2007)
rP4                 = RHJC;
rD4                 = RKJC;
w4                  = Z4;
u4                  = X4;
Trial.Segment(4).Q  = [u4;rP4;rD4;w4];
Trial.Segment(4).rM = [RTHI,RKNE,RKNI,CRT1,CRT2,CRT3,CRT4];

% -------------------------------------------------------------------------
% Right Tibia/fibula parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RTTU = Trial.Marker(12).Trajectory.smooth;
RTIB = Trial.Marker(13).Trajectory.smooth;
RANK = Trial.Marker(14).Trajectory.smooth;
RMED = Trial.Marker(15).Trajectory.smooth;
% Ankle joint centre
RAJC = (RANK+RMED)/2;
% Store virtual marker
Trial.Vmarker(2).label             = 'RAJC';
Trial.Vmarker(2).Trajectory.smooth = RAJC;  
% Tibia/fibula axes (Dumas and Wojtusch 2018)
Y3 = Vnorm_array3(RKJC-RAJC);
X3 = Vnorm_array3(cross(RANK-RKJC,RMED-RKJC));
Z3 = Vnorm_array3(cross(X3,Y3));
% Tibia/fibula parameters (Dumas and Chèze 2007)
rP3                 = RKJC;
rD3                 = RAJC;
w3                  = Z3;
u3                  = X3;
Trial.Segment(3).Q  = [u3;rP3;rD3;w3];
Trial.Segment(3).rM = [RTTU,RTIB,RANK,RMED];

% -------------------------------------------------------------------------
% Right foot parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
RHEE = Trial.Marker(16).Trajectory.smooth;
RMIF = Trial.Marker(17).Trajectory.smooth;
RTOE = Trial.Marker(18).Trajectory.smooth;
RMET = Trial.Marker(19).Trajectory.smooth;
% Metatarsal joint centre (Dumas and Wojtusch 2018)
RMJC = RTOE;
% Store virtual marker
Trial.Vmarker(1).label             = 'RMJC';
Trial.Vmarker(1).Trajectory.smooth = RMJC;  
% Foot axes (Dumas and Wojtusch 2018)
X2 = Vnorm_array3(RMJC-RHEE);
Y2 = Vnorm_array3(cross(RMET-RHEE,RTOE-RHEE));
Z2 = Vnorm_array3(cross(X2,Y2));
% Foot parameters (Dumas and Chèze 2007)
rP2                 = RAJC;
rD2                 = RMJC;
w2                  = Z2;
u2                  = X2;
Trial.Segment(2).Q  = [u2;rP2;rD2;w2];
Trial.Segment(2).rM = [RHEE,RMIF,RTOE,RMET];

% -------------------------------------------------------------------------
% Left femur parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
LTHI = Trial.Marker(20).Trajectory.smooth;
LKNE = Trial.Marker(21).Trajectory.smooth;
LKNI = Trial.Marker(22).Trajectory.smooth;
CLT1 = Trial.Marker(23).Trajectory.smooth;
CLT2 = Trial.Marker(24).Trajectory.smooth;
CLT3 = Trial.Marker(25).Trajectory.smooth;
CLT4 = Trial.Marker(26).Trajectory.smooth;
% Knee joint centre
LKJC = (LKNE+LKNI)/2;
% Store virtual marker
Trial.Vmarker(7).label             = 'LKJC';
Trial.Vmarker(7).Trajectory.smooth = LKJC;
% Femur axes (Dumas and Wojtusch 2018)
Y9 = Vnorm_array3(LHJC-LKJC);
X9 = -Vnorm_array3(cross(LKNE-LHJC,LKJC-LHJC));
Z9 = Vnorm_array3(cross(X9,Y9));
% Femur parameters (Dumas and Chèze 2007)
rP9                 = LHJC;
rD9                 = LKJC;
w9                  = Z9;
u9                  = X9;
Trial.Segment(9).Q  = [u9;rP9;rD9;w9];
Trial.Segment(9).rM = [LTHI,LKNE,LKNI,CLT1,CLT2,CLT3,CLT4];

% -------------------------------------------------------------------------
% Left Tibia/fibula parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
LTTU = Trial.Marker(27).Trajectory.smooth;
LTIB = Trial.Marker(28).Trajectory.smooth;
LANK = Trial.Marker(29).Trajectory.smooth;
LMED = Trial.Marker(30).Trajectory.smooth;
% Ankle joint centre
LAJC = (LANK+LMED)/2;
% Store virtual marker
Trial.Vmarker(6).label             = 'LAJC';
Trial.Vmarker(6).Trajectory.smooth = LAJC;
% Tibia/fibula axes (Dumas and Wojtusch 2018)
Y8 = Vnorm_array3(LKJC-LAJC);
X8 = Vnorm_array3(cross(LANK-LKJC,LMED-LKJC));
Z8 = Vnorm_array3(cross(X8,Y8));
% Tibia/fibula parameters (Dumas and Chèze 2007)
rP8                 = LKJC;
rD8                 = LAJC;
w8                  = Z8;
u8                  = X8;
Trial.Segment(8).Q  = [u8;rP8;rD8;w8];
Trial.Segment(8).rM = [LTTU,LTIB,LANK,LMED];

% -------------------------------------------------------------------------
% Left foot parameters
% -------------------------------------------------------------------------
% Extract marker trajectories
LHEE = Trial.Marker(31).Trajectory.smooth;
LMIF = Trial.Marker(32).Trajectory.smooth;
LTOE = Trial.Marker(33).Trajectory.smooth;
LMET = Trial.Marker(34).Trajectory.smooth;
% Metatarsal joint centre (Dumas and Wojtusch 2018)
LMJC = LTOE;
% Store virtual marker
Trial.Vmarker(5).label             = 'LMJC';
Trial.Vmarker(5).Trajectory.smooth = LMJC;
% Foot axes (Dumas and Wojtusch 2018)
X7 = Vnorm_array3(LMJC-LHEE);
Y7 = Vnorm_array3(cross(LMET-LHEE,LTOE-LHEE));
Z7 = Vnorm_array3(cross(X7,Y7));
% Foot parameters (Dumas and Chèze 2007)
rP7                 = LAJC;
rD7                 = LMJC;
w7                  = Z7;
u7                  = X7;
Trial.Segment(7).Q  = [u7;rP7;rD7;w7];
Trial.Segment(7).rM = [LHEE,LMIF,LTOE,LMET];