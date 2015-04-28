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

show_predicted_prior = false;
show_pixel_states    = false;

whitebg('black');

map = tracking1D_globalMap();
[particles, state] = tracking1D_initParticles(1000, size(map));

events = tracking1D_generateSignals(map, size(map,2)/2, size(map,2)-1, 100);

% execute tracking1D_test2 to plot map with events
%tracking1D_plotMap(map, events);
%figure;

% start tracking
hold off;

t = 0;
for i = 1:(size(events,1)+1)
    
    % plot current particle filter and current tracking statetrue
    
    if show_pixel_states
        ax = subplot(size(events,1)+1,size(state,1)+1, (i-1)*(size(state,1)+1)+1);
    else
        ax = subplot(1,size(events,1)+1,i);
    end
    
    % plot correct position of event
    if i > 1
        hold on;
        plot([events(i-1, 4) events(i-1, 4)], [0 1], 'w-');
    end
    
    tracking1D_plotParticles(particles, 'red');
    if ~show_pixel_states
        set(ax, 'XTick', []);
        set(ax, 'YTick', []);
        box on;
        set(ax, 'XColor', [0.3 0.3 0.3]);
        set(ax, 'YColor', [0.3 0.3 0.3]);
        if i > 1
            title(['event ' num2str(i-1)]);
        else
            title('initial state');
        end
    end
    xlim([1, size(map,2)]);
    hold off;
    
    if show_pixel_states
        for d = 1:size(state,1)
            ax = subplot(size(events,1)+1,size(state,1)+1, (i-1)*(size(state,1)+1)+d+1);

            hold on;

            % plot current row of map
            plot(1:size(map,2), map(d,:)*0.1+0.05, 'w-', 'Color', [0.2,0.2,0.2]);

            % plot correct position of event
            if i > 1 && events(i-1,1) == d
                plot([events(i-1, 4) events(i-1, 4)], [0 1], 'w-');
            end

            tracking1D_plotParticles(permute(state(d,:,:),[2 3 1]), 'green');
            hold off;
        end
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
    
    if show_predicted_prior
        if show_pixel_states
            subplot(size(events,1)+1,size(state,1)+1, (i-1)*(size(state,1)+1)+1);
        else
            subplot(1,size(events,1)+1,i);
        end
        hold on;
        tracking1D_plotParticles(particles, [0.5 0.4 0]);
        hold off;
    end
    
    [particles, state] = tracking1D_updateOnEvent(particles, event, map, state, deltaT);
    
end