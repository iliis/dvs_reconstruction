function [particles, tracking_state, intermediate_positions] = trackMovement( particles, tracking_state, events, img, last_timestamp, ground_truth)
% updates on events

if nargin < 5
    last_timestamp = 0;
end

intermediate_positions = zeros(size(events,1), 3);

avg = particleAverage(particles);
for i = 1:size(events,1)
    
    deltaT_global = events(i,4) - last_timestamp;
    last_timestamp = events(i,4);
    
    particles = predict(particles, deltaT_global);
    
    [particles, tracking_state] = updateOnEvent(particles, events(i,:), img, tracking_state);
    
    disp(['updated on event ' num2str(i) ' = ' num2str(events(i,:)) ' deltaT_global = ' num2str(deltaT_global) ' mean = ' num2str(particleAverage(particles)) '  eff. no. = ' num2str(effectiveParticleNumber(particles))]);
    %plotParticles(particles); drawnow; waitforbuttonpress;
    
    
    % resample distribution if particles become too unevenly distributed
    if effectiveParticleNumber(particles) < size(particles,1)/2; % paper uses 50%state
        particles = resample(particles);
        effno = effectiveParticleNumber(particles);
        
        disp(['resampled -> mean = ' num2str(mean(particles,1)) '  eff. no. = ' num2str(effno)]);
        %plotParticles(particles, theta_new); drawnow; waitforbuttonpress;
    end
    
    prev_avg = avg;
    avg = particleAverage(particles);
    
    if (nargin >= 6 && exist('ground_truth','var') && ~isempty(ground_truth))
        plotInWorld([ground_truth(i,:); avg], size(img), simulationPatchSize()*[1 1]/2, ':', 'Color', [0.9 0.9 0.9]);
    end
    
    plotInWorld([prev_avg; avg], size(img), simulationPatchSize()*[1 1]/2, ':.b');
    drawnow;

    intermediate_positions(i, :) = avg;
end

end

