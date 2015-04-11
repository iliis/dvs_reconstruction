% sweep over map and generate events
% update on events
% event: [ydim sign timestamp real_xpos]

% vertical white line: *true* position at time of event
%
% first column (red): current position estimation
% rest (green): position at time of last event at specific pixel
%
% first row: initial state
% other rows correspond to posterior of successive events


map = tracking1D_globalMap();
[particles, state] = tracking1D_initParticles(400, size(map));

events = tracking1D_generateSignals(map, size(map,2)/2, size(map,2)-1, 100);

tracking1D_plotMap(map, events);


% start tracking
figure;
t = 0;
for i = 1:(size(events,1)+1)
    
    % plot current particle filter and current tracking state
    
    ax = subplot(size(events,1)+1,size(state,1)+1, (i-1)*(size(state,1)+1)+1);
    
    tracking1D_plotParticles(particles, 'red');
    xlim([1, size(map,2)]);
    
    % plot correct position of event
    if i > 1
        hold on;
        plot([events(i-1, 4) events(i-1, 4)], [0 1], 'w-');
        hold off;
    end
    
    for d = 1:size(state,1)
        ax = subplot(size(events,1)+1,size(state,1)+1, (i-1)*(size(state,1)+1)+d+1);
        tracking1D_plotParticles(permute(state(d,:,:),[2 3 1]), 'blue'); %[0.4 0.4 0.4]);
    end
    
    % don't calculate another timestep after plotting the last one
    if i > size(events,1)
        break;
    end
    
    % calculate next timestep
    event = events(i,:);
    deltaT = event(3) - t;
    t = event(3);
    
    particles = tracking1D_predict(particles, deltaT);
    [particles, state] = tracking1D_updateOnEvent(particles, event, map, state, deltaT);
    
end