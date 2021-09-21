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

function Trial = InitialiseSegments(Trial)

segmentLabels = {'Right forceplate','Right foot','Right tibia','Right femur','Pelvis',...
                 'Left forceplate','Left foot','Left tibia','Left femur','Pelvis'};
             
for i = 1:length(segmentLabels)
    Trial.Segment(i).label = segmentLabels{i};
    Trial.Segment(i).rM    = [];
    Trial.Segment(i).Q     = [];
    Trial.Segment(i).T     = [];
end