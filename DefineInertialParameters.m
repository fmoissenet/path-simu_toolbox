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
% Description  : Set inertial parameters for all segments
% -------------------------------------------------------------------------
% Dependencies : To be defined
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function Trial = DefineInertialParameters(Trial,Participant,Session)

% Load the regression table (Dumas and Wojtusch 2018)
if strcmp(Participant.gender,'Female')
    r_BSIP = dlmread('r_BSIP_Female.csv',';','C2..L17');
elseif strcmp(Participant.gender,'Male')
    r_BSIP = dlmread('r_BSIP_Male.csv',';','C2..L17');
end

% Set parameters /right limb
sindex = [13 12 11 10];
for i = 2:5
    s = sindex(i-1);
    rPi = Trial.Segment(i).Q(4:6,:,:);
    rDi = Trial.Segment(i).Q(7:9,:,:);
    L(i) = mean(sqrt(sum((rPi-rDi).^2)),3); % length of the segment
    Trial.Segment(i).m = r_BSIP(s,1)*Session.participantWeight/100;
    Trial.Segment(i).rCs = [r_BSIP(s,2)*L(i)/100; ...
        r_BSIP(s,3)*L(i)/100; ...
        r_BSIP(s,4)*L(i)/100];
    Trial.Segment(i).Is = [((r_BSIP(s,5)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,8)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,9)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100); ...
        ((r_BSIP(s,8)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,6)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,10)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100);...
        ((r_BSIP(s,9)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100),...
        ((r_BSIP(s,10)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,7)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100)];
end

% Set parameters /left limb
sindex = [16 15 14 10];
for i = 7:10
    s = sindex(i-6);
    rPi = Trial.Segment(i).Q(4:6,:,:);
    rDi = Trial.Segment(i).Q(7:9,:,:);
    L(i) = mean(sqrt(sum((rPi-rDi).^2)),3); % length of the segment
    Trial.Segment(i).m = r_BSIP(s,1)*Session.participantWeight/100;
    Trial.Segment(i).rCs = [r_BSIP(s,2)*L(i)/100; ...
        r_BSIP(s,3)*L(i)/100; ...
        r_BSIP(s,4)*L(i)/100];
    Trial.Segment(i).Is = [((r_BSIP(s,5)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,8)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,9)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100); ...
        ((r_BSIP(s,8)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,6)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,10)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100);...
        ((r_BSIP(s,9)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100),...
        ((r_BSIP(s,10)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100), ...
        ((r_BSIP(s,7)*L(i)/100).^2)*(r_BSIP(s,1)*Session.participantWeight/100)];
end