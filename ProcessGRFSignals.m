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
% Dependencies : - Biomechanical Toolkit (BTK): https://github.com/Biomechanical-ToolKit/BTKCore
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function [Trial] = ProcessGRFSignals(Trial,GRF,steps,fmethod,smethod)

% -------------------------------------------------------------------------
% IDENTIFY FORCEPLATE CYCLES/STEPS
% -------------------------------------------------------------------------

% Right foot forceplate steps
% -------------------------------------------------------------------------
if steps(1) > 0
    Trial.GRF(1).Signal.P.raw(1,1,:) = permute(GRF(steps(1)).P(:,1),[2,3,1])*1e-3; % Convert mm to m
    Trial.GRF(1).Signal.P.raw(3,1,:) = -permute(GRF(steps(1)).P(:,2),[2,3,1])*1e-3; % Convert mm to m
    Trial.GRF(1).Signal.P.raw(2,1,:) = permute(GRF(steps(1)).P(:,3),[2,3,1])*1e-3; % Convert mm to m
    Trial.GRF(1).Signal.F.raw(1,1,:) = permute(GRF(steps(1)).F(:,1),[2,3,1]);
    Trial.GRF(1).Signal.F.raw(3,1,:) = -permute(GRF(steps(1)).F(:,2),[2,3,1]);
    Trial.GRF(1).Signal.F.raw(2,1,:) = permute(GRF(steps(1)).F(:,3),[2,3,1]);
    Trial.GRF(1).Signal.M.raw(:,:,:) = permute([zeros(size(GRF(steps(1)).M(:,3))) ...
                                                GRF(steps(1)).M(:,3) ...
                                                zeros(size(GRF(steps(1)).M(:,3)))],[2,3,1])*1e-3; % Convert Nmm to Nm
else
    Trial.GRF(1).Signal.P.raw = [];
    Trial.GRF(1).Signal.F.raw = [];
    Trial.GRF(1).Signal.M.raw = [];
end

% Left foot forceplate steps
% -------------------------------------------------------------------------
if steps(2) > 0
    Trial.GRF(2).Signal.P.raw(1,1,:) = permute(GRF(steps(2)).P(:,1),[2,3,1])*1e-3; % Convert mm to m
    Trial.GRF(2).Signal.P.raw(3,1,:) = -permute(GRF(steps(2)).P(:,2),[2,3,1])*1e-3; % Convert mm to m
    Trial.GRF(2).Signal.P.raw(2,1,:) = permute(GRF(steps(2)).P(:,3),[2,3,1])*1e-3; % Convert mm to m
    Trial.GRF(2).Signal.F.raw(1,1,:) = permute(GRF(steps(2)).F(:,1),[2,3,1]);
    Trial.GRF(2).Signal.F.raw(3,1,:) = -permute(GRF(steps(2)).F(:,2),[2,3,1]);
    Trial.GRF(2).Signal.F.raw(2,1,:) = permute(GRF(steps(2)).F(:,3),[2,3,1]);
    Trial.GRF(2).Signal.M.raw(:,1,:) = permute([zeros(size(GRF(steps(2)).M(:,3))) ...
                                                GRF(steps(2)).M(:,3) ...
                                                zeros(size(GRF(steps(2)).M(:,3)))],[2,3,1])*1e-3; % Convert Nmm to Nm
else
    Trial.GRF(2).Signal.P.raw = [];
    Trial.GRF(2).Signal.F.raw = [];
    Trial.GRF(2).Signal.M.raw = [];
end

% -------------------------------------------------------------------------
% SIGNAL FILTERING
% -------------------------------------------------------------------------
if ~isempty(Trial.GRF)
    for i = 1:size(Trial.GRF,2)
        
        % Method 1: No filtering
        if strcmp(fmethod.type,'none') 
            Trial.GRF(i).Signal.P.filt   = Trial.GRF(i).Signal.P.raw;
            Trial.GRF(i).Signal.F.filt   = Trial.GRF(i).Signal.F.raw;
            Trial.GRF(i).Signal.M.filt   = Trial.GRF(i).Signal.M.raw;
            Trial.GRF(i).Processing.filt = fmethod.type;
        
        % Method 2: Vertical force threshold ([fmethod.parameter] N)
        elseif strcmp(fmethod.type,'threshold') 
            if ~isempty(Trial.GRF(i).Signal.F.raw)
                for j = 1:size(Trial.GRF(i).Signal.F.raw,3)
                    if Trial.GRF(i).Signal.F.raw(2,:,j) < fmethod.parameter
                        Trial.GRF(i).Signal.P.filt(:,:,j) = zeros(3,1);
                        Trial.GRF(i).Signal.F.filt(:,:,j) = zeros(3,1);
                        Trial.GRF(i).Signal.M.filt(:,:,j) = zeros(3,1);
                    else
                        Trial.GRF(i).Signal.P.filt(:,:,j) = Trial.GRF(i).Signal.P.raw(:,:,j);
                        Trial.GRF(i).Signal.F.filt(:,:,j) = Trial.GRF(i).Signal.F.raw(:,:,j);
                        Trial.GRF(i).Signal.M.filt(:,:,j) = Trial.GRF(i).Signal.M.raw(:,:,j);
                    end
                end
            end
            Trial.GRF(i).Processing.filt = fmethod.type;
        end
        
    end
end

% -------------------------------------------------------------------------
% SIGNAL SMOOTHING
% -------------------------------------------------------------------------
if ~isempty(Trial.GRF)
    for i = 1:size(Trial.GRF,2)

        % Method 1: No smoothing
        if strcmp(smethod.type,'none') 
            if ~isempty(Trial.GRF(i).Signal.F.raw)
                Trial.GRF(i).Signal.P.smooth = Trial.GRF(i).Signal.P.filt;
                Trial.GRF(i).Signal.F.smooth = Trial.GRF(i).Signal.F.filt;
                Trial.GRF(i).Signal.M.smooth = Trial.GRF(i).Signal.M.filt;
            end
            Trial.GRF(i).Processing.smooth = smethod.type;

        % Method 2: Low pass filter (Butterworth 2nd order, [smethod.parameter] Hz)
        elseif strcmp(smethod.type,'butterLow2') 
            if ~isempty(Trial.GRF(i).Signal.F.raw)
                [B,A]                          = butter(1,smethod.parameter/(Trial.fanalog/2),'low');
                Trial.GRF(i).Signal.P.smooth   = permute(filtfilt(B,A,permute(Trial.GRF(i).Signal.P.filt,[3,1,2])),[2,3,1]);
                Trial.GRF(i).Signal.F.smooth   = permute(filtfilt(B,A,permute(Trial.GRF(i).Signal.F.filt,[3,1,2])),[2,3,1]);
                Trial.GRF(i).Signal.M.smooth   = permute(filtfilt(B,A,permute(Trial.GRF(i).Signal.M.filt,[3,1,2])),[2,3,1]);
            end
            Trial.GRF(i).Processing.smooth = smethod.type;
        end

    end
end

% -------------------------------------------------------------------------
% SIGNAL RESAMPLING
% -------------------------------------------------------------------------
if ~isempty(Trial.GRF)
    for i = 1:size(Trial.GRF,2)
        if ~isempty(Trial.GRF(i).Signal.F.raw)
            Trial.GRF(i).Signal.P.smooth = permute(interp1((1:size(Trial.GRF(i).Signal.P.smooth,3))',...
                                                           permute(Trial.GRF(i).Signal.P.smooth,[3,1,2]),...
                                                           (linspace(1,size(Trial.GRF(i).Signal.P.smooth,3),size(Trial.Marker(1).Trajectory.smooth,3)))',...
                                                           'spline'),[2,3,1]);
            Trial.GRF(i).Signal.F.smooth = permute(interp1((1:size(Trial.GRF(i).Signal.F.smooth,3))',...
                                                           permute(Trial.GRF(i).Signal.F.smooth,[3,1,2]),...
                                                           (linspace(1,size(Trial.GRF(i).Signal.F.smooth,3),size(Trial.Marker(1).Trajectory.smooth,3)))',...
                                                           'spline'),[2,3,1]);
            Trial.GRF(i).Signal.M.smooth = permute(interp1((1:size(Trial.GRF(i).Signal.M.smooth,3))',...
                                                           permute(Trial.GRF(i).Signal.M.smooth,[3,1,2]),...
                                                           (linspace(1,size(Trial.GRF(i).Signal.M.smooth,3),size(Trial.Marker(1).Trajectory.smooth,3)))',...
                                                           'spline'),[2,3,1]);
        end
    end
end