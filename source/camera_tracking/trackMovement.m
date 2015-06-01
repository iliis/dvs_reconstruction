function [particles, tracking_state, intermediate_positions, plot_handle] = trackMovement( particles, tracking_state, events, img, last_timestamp, ground_truth)
% updates on events
% init particles and tracking state with initParticles()
% last_timestamp is the timestamp of the last event we already updated and
% optional, but required for correct prediction
% ground_truth is simply for visualization and can be omitted

if nargin < 5
    last_timestamp = 0;
end

params = getParameters();

intermediate_positions = zeros(size(events,1), 3);

avg = particleAverage(particles);
for i = 1:size(events,1)
    
    deltaT_global = events(i,4) - last_timestamp;
    last_timestamp = events(i,4);
    
    % predict motion of camera
    % in our case, this is simply constant position + gaussian noise
    particles = predict(particles, deltaT_global);
    
    % actually do bayesian updating based on the measurements
    [particles, tracking_state] = updateOnEvent(particles, events(i,:), img, tracking_state, params);
    
    disp(['updated on event ' num2str(i) ' = ' num2str(events(i,:)) ' deltaT_global = ' num2str(deltaT_global) ' mean = ' num2str(particleAverage(particles)) '  eff. no. = ' num2str(effectiveParticleNumber(particles))]);
    
    % show particle distribution and wait for user
    %plotParticles(particles); drawnow; waitforbuttonpress;
    
    
    % resample distribution if particles become too unevenly distributed
    if effectiveParticleNumber(particles) < size(particles,1)/2; % paper uses 50%state
        particles = resample(particles);
        effno = effectiveParticleNumber(particles);
        
        disp(['resampled -> mean = ' num2str(mean(particles,1)) '  eff. no. = ' num2str(effno)]);
        %plotParticles(particles, theta_new); drawnow; waitforbuttonpress;
    end
    
    % plot weighted average over particles
    prev_avg = avg;
    avg = particleAverage(particles);
    
    if (nargin >= 6 && exist('ground_truth','var') && ~isempty(ground_truth))
        plotInWorld([ground_truth(i,:); avg], size(img), simulationPatchSize()*[1 1]/2, ':', 'Color', [0.9 0.9 0.9]);
    end
    
    plot_handle = plotInWorld([prev_avg; avg], size(img), params.simulationPatchSize*[1 1]/2, ':.b');
    drawnow;

    intermediate_positions(i, :) = avg;
end

end

