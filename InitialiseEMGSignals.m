% Author       : F. Moissenet
%                Kinesiology Laboratory (K-LAB)
%                University of Geneva
%                https://www.unige.ch/medecine/kinesiology
% License      : Creative Commons Attribution-NonCommercial 4.0 International License 
%                https://creativecommons.org/licenses/by-nc/4.0/legalcode
% Source code  : https://github.com/fmoissenet/NSLBP-BIOToolbox
% Reference    : To be defined
% Date         : June 2020
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

function Trial = InitialiseEMGSignals(Trial,EMG)

% Set EMGset
EMGSet = {'R_GME','L_GME'};      
         
% Initialise EMGs
for i = 1:length(EMGSet)
    Trial.EMG(i).label              = EMGSet{i};
    if isfield(EMG,EMGSet{i})
        Trial.EMG(i).Signal.raw     = permute(EMG.(EMGSet{i}),[2,3,1]);
        Trial.EMG(i).Signal.filt    = [];
        Trial.EMG(i).Signal.rect    = [];
        Trial.EMG(i).Signal.smooth  = [];
        Trial.EMG(i).Signal.units   = 'V';
    else
        Trial.EMG(i).Signal.raw     = [];
        Trial.EMG(i).Signal.filt    = [];
        Trial.EMG(i).Signal.rect    = [];
        Trial.EMG(i).Signal.smooth  = [];
        Trial.EMG(i).Signal.units   = 'V';
    end
    Trial.EMG(i).Processing.filt       = 'none';
    Trial.EMG(i).Processing.smooth     = 'none';
end