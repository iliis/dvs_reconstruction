function [ events, thetas, patch_state ] = flyDiffCamFine( img, numEvents, time_start, theta_start, theta_dim, theta_inc, patch_state )
% generate a path with at least numEvents events where the intensity difference is as
% close to params.tracking.pixelIntensityThreshold
%
% This is a more close approximation to the real DVS as flyDiffCam() as the
% intensity differences that generate an event is bound and close to the
% threshold.
%
% timestamp differences of the generated events:
% 0 for simultaneous events, T between the following events (where T is a
% constant defined below as TIME_BETWEEN_STEPS)
%
% output:
%   events: >=numEvents * [x y pol time]
%   thetas: size(events,1) * [alpha beta gamma] at corresponding event (i.e. ground truth)
%   patch_state: state of camera sensor, can be used to chain multiple
%   calls to flyDiffCamFine

invKPs = getInvKPsforPatch();
params = getParameters();

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
    % initialize state
    patch_state = double(getPatch(img, invKPs, theta, params.simulationPatchSize));
end

events = [];
thetas = [];

while size(events,1) < numEvents
    while true
        theta(abs(theta_dim)) = theta(abs(theta_dim)) + theta_inc;

        new_patch = double(getPatch(img, invKPs, theta, params.simulationPatchSize));
        diff = new_patch - patch_state;
        
        %disp(num2str(theta));

        if max(max(diff)) > params.pixelIntensityThreshold
            % found a movement where we get at least a single event
            break;
        end
    end
    
    [events_raw,patch_state] = getSignalsFromState(patch_state, new_patch, params.pixelIntensityThreshold);
    events_new = convertSignalsToVectors(events_raw, 0);
    
    % generate more 'real' timestamps (i.e. more similary to what camera
    % generates and what the reconstruction code uses)
    % adjust this constant according to your map
    %
    % this is a magic constant that maybe should be moved into
    % getParameters() and shouldn't even be necessary in the first place.
    %
    % Essentialy, the higher this is, the more movement will be
    % predict()ed. So this value must be high enough to allow enough
    % movement, but tracking becomes noisy if it gets too high.
    TIME_BETWEEN_STEPS = 10;
        
    events_new(:,4) = TIME_BETWEEN_STEPS + last_timestamp;
    last_timestamp = events_new(end,4);
    
    events = [events; events_new];
    thetas = [thetas; repmat(theta, size(events_new,1), 1)];
    
    disp(['got ' num2str(size(events_new,1)) ' new events. theta = ' num2str(theta)]);
end
disp(['got ' num2str(size(events,1)) ' events in total']);

end