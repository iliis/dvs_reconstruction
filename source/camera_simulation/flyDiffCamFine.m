function [ events, thetas, patch_state ] = flyDiffCamFine( img, numEvents, time_start, theta_start, theta_dim, theta_inc, patch_state )
% generate a path with at least numEvents events where the intensity difference is as
% close to pixelIntensityThreshold()
%
% time: 1 radian / time unit (i.e. timestamp = norm(theta))
%
% output:
%   events: =>numEvents * [x y pol time]
%   thetas: size(events,1) * [alpha beta gamma] at corresponding event (i.e. ground truth)
%   patch_state: state of camera sensor, can be used to chain multiple
%   calls to flyDiffCamFine

invKPs = getInvKPsforPatch(cameraIntrinsicParameterMatrix());

if nargin < 3
    last_timestamp = 0;
else
    last_timestamp = time_start;
end

if nargin < 4
    theta = [0 0 0];
else
    theta = theta_start;
end

if nargin < 5
    theta_dim = 1; % move alpha
end

if nargin < 6
    theta_inc = 0.00001;
end

if nargin < 7
    patch_state = double(getPatch(img, invKPs, theta));
end

events = [];
thetas = [];

while size(events,1) < numEvents
    while true
        theta(theta_dim) = theta(theta_dim) + theta_inc;

        new_patch = double(getPatch(img, invKPs, theta));
        diff = new_patch - patch_state;
        
        %disp(num2str(theta));

        if max(max(diff)) > pixelIntensityThreshold()
            % found a movement where we get at least a single event
            break;
        end
    end
    
    [events_raw,patch_state] = getSignals2(patch_state, new_patch, pixelIntensityThreshold());
    events_new = convertSignalsToVectors(events_raw, norm(theta));
    
    % generate more 'real' timestamps (i.e. more similary to what camera
    % generates and what the reconstruction code uses)
    % adjust this constant according to your map
    TIME_BETWEEN_STEPS = 1/100;
    events_new(:,4) = TIME_BETWEEN_STEPS + last_timestamp;
    last_timestamp = events_new(end,4);
    
    events = [events; events_new];
    thetas = [thetas; repmat(theta, size(events_new,1), 1)];
    
    disp(['got ' num2str(size(events_new,1)) ' new events']);
end
disp(['got ' num2str(size(events,1)) ' events in total']);

end