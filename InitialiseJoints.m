% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : o be defined
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

function Trial = InitialiseJoints(Trial)

jointLabels = {'Right MTP','Right ankle','Right knee','Right hip', ...
               'Left MTP','Left ankle','Left knee','Left hip'};

for i = 1:length(jointLabels)
    Trial.Joint(i).label = jointLabels{i};
    Trial.Joint(i).T     = [];
    Trial.Joint(i).Euler = [];
    Trial.Joint(i).dj    = [];
end