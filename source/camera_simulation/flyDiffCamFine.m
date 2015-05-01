function [ events, thetas ] = flyDiffCamFine( img, numEvents )
% generate a path with at least numEvents events where the intensity difference is as
% close to pixelIntensityThreshold()
%
% time: 1 radian / time unit (i.e. timestamp = norm(theta))
%
% output:
%   events: =>numEvents * [x y pol time]
%   thetas: size(events,1) * [alpha beta gamma] at corresponding event (i.e. ground truth)

theta_inc = 0.00001;
theta_dim = 1; % move alpha

invKPs = getInvKPsforPatch(cameraIntrinsicParameterMatrix());

theta = [0 0 0];
events = [];
thetas = [];
patch_state = double(getPatch(img, invKPs, theta));

while size(events,1) < numEvents
    while 1
        theta(theta_dim) = theta(theta_dim) + theta_inc;

        new_patch = getPatch(img, invKPs, theta);
        diff = new_patch - patch_state;
        
        disp(num2str(theta));

        if max(max(diff)) > pixelIntensityThreshold()
            % found a movement where we get at least a single event
            break;
        end
    end
    
    [events_raw,patch_state] = getSignals2(patch_state, new_patch, pixelIntensityThreshold());
    events_new = convertSignalsToVectors(events_raw, norm(theta));
    events = [events; events_new];
    thetas = [thetas; repmat(theta, size(events_new,1), 1)];
    
    disp(['got ' num2str(size(events_new,1)) ' new events']);
end

disp(['got ' num2str(size(events,1)) ' events in total']);

end