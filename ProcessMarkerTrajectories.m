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
% -------------------------------------------------------------------------
% Dependencies : To be defined
% -------------------------------------------------------------------------
% This work is licensed under the Creative Commons Attribution - 
% NonCommercial 4.0 International License. To view a copy of this license, 
% visit http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to 
% Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
% -------------------------------------------------------------------------

function Trial = ProcessMarkerTrajectories(Static,Trial,fmethod,smethod)

% -------------------------------------------------------------------------
% IDENTIFY MISSING TRAJECTORIES AND GAPS IN TRAJECTORIES 
% -------------------------------------------------------------------------
for i = 1:size(Trial.Marker,2)

    % Special case of static
    if isempty(Static)
        if isempty(Trial.Marker(i).Trajectory.raw)
            Trial.Marker(i).Trajectory.fill = [];
        else
            Trial.Marker(i).Trajectory.fill = mean(Trial.Marker(i).Trajectory.raw,3);
        end
        Trial.n0 = 1;
        Trial.n1 = 1;  
    end
    
    % Missing marker trajectory
    if isempty(Trial.Marker(i).Trajectory.raw)
        Trial.Marker(i).Gap(1).frames         = 1:Trial.n1;
        Trial.Marker(i).Gap(1).reconstruction = 'none';
        Trial.Marker(i).smoothing             = 'none';

    % Marker trajectory with gaps
    elseif ~isempty(Trial.Marker(i).Trajectory.raw)

        % Replace [0 0 0] by NaN
        for j = 1:Trial.n1
            if Trial.Marker(i).Trajectory.raw(:,:,j) == [0 0 0]
               Trial.Marker(i).Trajectory.fill(:,:,j) = nan(3,1,1);
            else
               Trial.Marker(i).Trajectory.fill(:,:,j) = Trial.Marker(i).Trajectory.raw(:,:,j);
            end
        end

        % Find gaps
        start = 0;
        stop  = 0;
        k     = 0;
        for j = 1:Trial.n1-1
            if isnan(Trial.Marker(i).Trajectory.fill(:,:,j))
                if start == 0
                    start = j;
                end
                if ~isnan(Trial.Marker(i).Trajectory.fill(:,:,j+1))
                    if start ~= 0
                        stop                                  = j;
                        k                                     = k+1;    
                        Trial.Marker(i).Gap(k).frames         = start:stop;
                        Trial.Marker(i).Gap(k).reconstruction = 'none';
                        start                                 = 0;
                        stop                                  = 0;
                    end
                elseif j+1 == Trial.n1
                    if isnan(Trial.Marker(i).Trajectory.fill(:,:,j+1))
                        if start ~= 0
                            stop                                  = j+1;
                            k                                     = k+1;    
                            Trial.Marker(i).Gap(k).frames         = start:stop;
                            Trial.Marker(i).Gap(k).reconstruction = 'none';
                            start                                 = 0;
                            stop                                  = 0;
                        end   
                    end
                end
            end
        end
    end
end

% -------------------------------------------------------------------------
% TRAJECTORIES GAP FILLING (NOT ALLOWED FOR STATIC)
% -------------------------------------------------------------------------
if ~isempty(Static)
    
    % Method 0: None
    if strcmp(fmethod.type,'none')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Gap)
                    for j = 1:size(Trial.Marker(i).Gap,2)
                        Trial.Marker(i).Gap(j).reconstruction = 'none';
                    end
                end
            end
        end
    end
    
    % Method 1: Linear interpolation
    %           - At least 1 point before and 1 point after gap is required (1/1
    %             are used here)
    if strcmp(fmethod.type,'linear')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Gap)
                    for j = 1:size(Trial.Marker(i).Gap,2)
                        if size(Trial.Marker(i).Gap(j).frames,2) < fmethod.gapThreshold
                            if Trial.Marker(i).Gap(j).frames(1) > 1 && ...
                               Trial.Marker(i).Gap(j).frames(end) < Trial.n1
                                Trial.Marker(i).Trajectory.fill(:,:,...
                                                                Trial.Marker(i).Gap(j).frames(1)-1: ...
                                                                Trial.Marker(i).Gap(j).frames(end)+1) = ...
                                fillmissing(Trial.Marker(i).Trajectory.fill(:,:,...
                                                                            Trial.Marker(i).Gap(j).frames(1)-1: ...
                                                                            Trial.Marker(i).Gap(j).frames(end)+1),'linear');
                            end
                            Trial.Marker(i).Gap(j).reconstruction = 'linear';
                        end
                    end
                end
            end
        end
    end

    % Method 2: Cubic spline interpolation
    %           - At least 2 point before and 2 point after gap is required 
    %             (10/10 are used here)
    if strcmp(fmethod.type,'spline')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Gap)
                    for j = 1:size(Trial.Marker(i).Gap,2)
                        if size(Trial.Marker(i).Gap(j).frames,2) < fmethod.gapThreshold
                            if Trial.Marker(i).Gap(j).frames(1) > 10 && ...
                               Trial.Marker(i).Gap(j).frames(end) < Trial.n1-9
                                Trial.Marker(i).Trajectory.fill(:,:,...
                                                                Trial.Marker(i).Gap(j).frames(1)-10: ...
                                                                Trial.Marker(i).Gap(j).frames(end)+10) = ...
                                fillmissing(Trial.Marker(i).Trajectory.fill(:,:,...
                                                                            Trial.Marker(i).Gap(j).frames(1)-10: ...
                                                                            Trial.Marker(i).Gap(j).frames(end)+10),'spline');
                            end
                            Trial.Marker(i).Gap(j).reconstruction = 'spline';
                        end
                    end
                end
            end
        end
    end

    % Method 3: Shape-preserving piecewise cubic interpolation
    %           - At least 2 point before and 2 point after gap is required 
    %             (10/10 are used here)
    if strcmp(fmethod.type,'pchip')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Gap)
                    for j = 1:size(Trial.Marker(i).Gap,2)
                        if size(Trial.Marker(i).Gap(j).frames,2) < fmethod.gapThreshold
                            if Trial.Marker(i).Gap(j).frames(1) > 10 && ...
                               Trial.Marker(i).Gap(j).frames(end) < Trial.n1-9
                                Trial.Marker(i).Trajectory.fill(:,:,...
                                                                Trial.Marker(i).Gap(j).frames(1)-10: ...
                                                                Trial.Marker(i).Gap(j).frames(end)+10) = ...
                                fillmissing(Trial.Marker(i).Trajectory.fill(:,:,...
                                                                            Trial.Marker(i).Gap(j).frames(1)-10: ...
                                                                            Trial.Marker(i).Gap(j).frames(end)+10),'pchip');
                            end
                            Trial.Marker(i).Gap(j).reconstruction = 'pchip';
                        end
                    end
                end
            end
        end
    end

    % Method 4: Modified Akima cubic Hermite interpolation
    %           - At least 1 point before and 1 point after gap is required 
    %             (10/10 are used here)
    if strcmp(fmethod.type,'makima')
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Gap)
                    for j = 1:size(Trial.Marker(i).Gap,2)
                        if size(Trial.Marker(i).Gap(j).frames,2) < fmethod.gapThreshold
                            if Trial.Marker(i).Gap(j).frames(1) > 10 && ...
                               Trial.Marker(i).Gap(j).frames(end) < Trial.n1-9
                                Trial.Marker(i).Trajectory.fill(:,:,...
                                                                Trial.Marker(i).Gap(j).frames(1)-10: ...
                                                                Trial.Marker(i).Gap(j).frames(end)+10) = ...
                                fillmissing(Trial.Marker(i).Trajectory.fill(:,:,...
                                                                            Trial.Marker(i).Gap(j).frames(1)-10: ...
                                                                            Trial.Marker(i).Gap(j).frames(end)+10),'makima');
                            end
                            Trial.Marker(i).Gap(j).reconstruction = 'makima';
                        end
                    end
                end
            end
        end
    end

    % Method 5: Marker trajectories intercorrelation (https://doi.org/10.1371/journal.pone.0152616)
    if strcmp(fmethod.type,'intercor')
        tMarker = [];
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                tMarker = [tMarker permute(Trial.Marker(i).Trajectory.fill,[3,1,2])];
            end
        end
        tMarker = PredictMissingMarkers(tMarker,'Algorithm',2);
        k = 0;
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                k = k+1;
                Trial.Marker(i).Trajectory.fill = permute(tMarker(:,(3*k)-2:3*k),[2,3,1]);
            end
        end
        clear k tMarker;
        for i = 1:size(Trial.Marker,2)
            if ~isempty(Trial.Marker(i).Trajectory.raw)
                if ~isempty(Trial.Marker(i).Gap)
                    for j = 1:size(Trial.Marker(i).Gap,2)
                        Trial.Marker(i).Gap(j).reconstruction = 'intercor';
                    end
                end
            end
        end
    end

    % Method 6: Apply rigid body transformation of the related segment on
    %           missing trajectories
    %           - The missing trajectories must be part of a marker related to a
    %             rigid body
    %           - At least 3 other markers, without gap, are needed on each segment
    if strcmp(fmethod.type,'rigid')
        for i = 1:size(Trial.Marker,2)        
            if ~isempty(Trial.Marker(i).Gap)
                for j = 1:size(Trial.Marker(i).Gap,2)

                    % Markers related to a rigid body
                    if strcmp(Trial.Marker(i).type,'landmark') || ...
                            strcmp(Trial.Marker(i).type,'hybrid-landmark') || ...
                            strcmp(Trial.Marker(i).type,'technical')

                        % Identify all available markers of the same segment
                        % without gap during all frames of the processed gap
                        nsegment = Trial.Marker(i).Body.Segment.label;
                        kmarker = [];
                        if strcmp(nsegment,'none') == 0 % Only for available segments
                            for k = 1:size(Trial.Marker,2)
                                if k ~= i
                                    if strcmp(Trial.Marker(k).Body.Segment.label,nsegment) == 1
                                        if ~isempty(Trial.Marker(k).Trajectory.raw)
                                            if isempty(find(isnan(Trial.Marker(k).Trajectory.fill(1,:,Trial.Marker(i).Gap(j).frames))))
                                                kmarker = [kmarker k];
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        % If at least 3 markers of the same segment are
                        % available, reconstruct the missing marker
                        if size(kmarker,2) >= 3
                            X = [];
                            for k = 1:size(kmarker,2)
                                X = [X; permute(Static.Marker(kmarker(k)).Trajectory.fill,[3,1,2])];
                            end
                            for t = Trial.Marker(i).Gap(j).frames
                                Y = [];
                                for k = 1:size(kmarker,2)
                                    Y = [Y; permute(Trial.Marker(kmarker(k)).Trajectory.fill(:,:,t),[3,1,2])];
                                end
                                [R,d,rms] = soder(X,Y);
                                Trial.Marker(i).Trajectory.fill(:,:,t) = ...
                                    permute(permute(Static.Marker(i).Trajectory.fill,[3,1,2])*R'+d',[2,3,1]);
                                clear R d;
                            end
                        end
                        clear segment;
                    end
                    Trial.Marker(i).Gap(j).reconstruction = 'rigid';
                end
            end
        end
    end

    % Method 7: Low dimensional Kalman smoothing (http://dx.doi.org/10.1016/j.jbiomech.2016.04.016)
    %           - A set of frames in which all markers are present is required
    if strcmp(fmethod.type,'kalman')
        disp('not available');
    end
end

% -------------------------------------------------------------------------
% MISSING TRAJECTORIES RECONSTRUCTION (NOT ALLOWED FOR STATIC)
% -------------------------------------------------------------------------
if ~isempty(Static)
    for i = 1:size(Trial.Marker,2)
        if isempty(Trial.Marker(i).Trajectory.raw)
            
            % Markers related to a rigid body (landmarks and hybrid-landmarks)
            if strcmp(Trial.Marker(i).type,'landmark') || ...
               strcmp(Trial.Marker(i).type,'hybrid-landmark') || ...
               strcmp(Trial.Marker(i).type,'technical')
                
                % Identify all available markers of the same segment
                % without gap during all frames of the processed gap
                nsegment = Trial.Marker(i).Body.Segment.label;
                kmarker = [];
                if strcmp(nsegment,'none') == 0 % Only for available segments
                    for k = 1:size(Trial.Marker,2)
                        if k ~= i
                            if strcmp(Trial.Marker(k).Body.Segment.label,nsegment) == 1
                                if ~isempty(Trial.Marker(k).Trajectory.raw)
                                    if isempty(find(isnan(Trial.Marker(k).Trajectory.fill(1,:,Trial.Marker(i).Gap(1).frames))))
                                        kmarker = [kmarker k];
                                    end
                                end
                            end
                        end
                    end
                end
                
                % If at least 3 markers of the same segment are
                % available, reconstruct the missing marker
                if size(kmarker,2) >= 3
                    X = [];
                    for k = 1:size(kmarker,2)
                        X = [X; (Static.Marker(kmarker(k)).Trajectory.fill)'];
                    end
                    for t = Trial.Marker(i).Gap(1).frames
                        Y = [];
                        for k = 1:size(kmarker,2)
                            Y = [Y; (Trial.Marker(kmarker(k)).Trajectory.fill(:,:,t))'];
                        end
                        [R,d,rms] = soder(X,Y);
                        Trial.Marker(i).Trajectory.fill(:,:,t) = R*Static.Marker(i).Trajectory.fill+d;
                        clear R d;
                    end
                    Trial.Marker(i).Gap(1).reconstruction = 'rigid';
                end
                clear segment;
            end
        end
    end
end

% -------------------------------------------------------------------------
% SMOOTH ALL RESULTING TRAJECTORIES
% -------------------------------------------------------------------------
for i = 1:size(Trial.Marker,2)
    if ~isempty(Trial.Marker(i).Trajectory.fill)
        if ~isempty(Static)
            % Low pass filter (Butterworth 2nd order, [smethod.parameter] Hz)
            if strcmp(smethod.type,'none')    
                Trial.Marker(i).Trajectory.smooth = Trial.Marker(i).Trajectory.fill;
                Trial.Marker(i).smoothing = 'none';
            % Low pass filter (Butterworth 2nd order, [smethod.parameter] Hz)
            elseif strcmp(smethod.type,'butterLow2')                
                [B,A]                             = butter(1,smethod.parameter/(Trial.fmarker/2),'low'); 
                Trial.Marker(i).Trajectory.smooth = permute(filtfilt(B,A,permute(Trial.Marker(i).Trajectory.fill,[3,1,2])),[2,3,1]);
                Trial.Marker(i).smoothing = 'butterLow2';
            % Moving average (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'movmedian')
                Trial.Marker(i).Trajectory.smooth = permute(smoothdata(permute(Trial.Marker(i).Trajectory.fill,[3,1,2]),'movmedian',smethod.parameter),[2,3,1]);
                Trial.Marker(i).smoothing = 'movmedian';
            % Moving average (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'movmean')
                Trial.Marker(i).Trajectory.smooth = permute(smoothdata(permute(Trial.Marker(i).Trajectory.fill,[3,1,2]),'movmean',smethod.parameter),[2,3,1]);
                Trial.Marker(i).smoothing = 'movmean';
            % Gaussian-weighted moving average (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'gaussian')
                Trial.Marker(i).Trajectory.smooth = permute(smoothdata(permute(Trial.Marker(i).Trajectory.fill,[3,1,2]),'gaussian',smethod.parameter),[2,3,1]);
                Trial.Marker(i).smoothing = 'gaussian';
            % Robust quadratic regression (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'rloess')
                Trial.Marker(i).Trajectory.smooth = permute(smoothdata(permute(Trial.Marker(i).Trajectory.fill,[3,1,2]),'rloess',smethod.parameter),[2,3,1]);
                Trial.Marker(i).smoothing = 'rloess';
            % Savitzky-Golay filter (window of [smethod.parameter] frames)
            elseif strcmp(smethod.type,'sgolay')
                Trial.Marker(i).Trajectory.smooth = permute(smoothdata(permute(Trial.Marker(i).Trajectory.fill,[3,1,2]),'sgolay',smethod.parameter),[2,3,1]);
                Trial.Marker(i).smoothing = 'sgolay';
            end
        else
            Trial.Marker(i).Trajectory.smooth = Trial.Marker(i).Trajectory.fill;
        end
        % Modify the ICS (Y vertical)
        Trial.Marker(i).Trajectory.smooth = [Trial.Marker(i).Trajectory.smooth(1,1,:); ...
                                             Trial.Marker(i).Trajectory.smooth(3,1,:); ...
                                             -Trial.Marker(i).Trajectory.smooth(2,1,:)];
    else
        Trial.Marker(i).Trajectory.smooth = [];
    end
end