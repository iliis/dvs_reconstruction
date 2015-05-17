function [particles, state_prior] = updateOnEvent(particles_prior, event, intensities, state_prior)
% input:
%  4xN list of particles [weight, 3x rotation]
%  1 event [u,v,sign,timestamp]
%  state: position of camera for every pixel at the time of its last event [128x128x3]

assert(~any(any(isnan(intensities))), 'NaN in intensities');

disp(['updating on event ' num2str(event)]);



show_plots = false;

% TODO: these values were chosen arbitrariliy!
LOW_LIKELIHOOD = 0.0001;
INTENSITY_VARIANCE  = 0.005; %0.08; %1; % 0.08 % dependent on variance in predict and number of particles
INTENSITY_THRESHOLD = pixelIntensityThreshold(); %0.05;



u = event(1); v = event(2);

if event(3) > 0
    event_sign = 1;
else
    event_sign = -1;
end

K = double(cameraIntrinsicParameterMatrix());
invKPs = reshape(K \ double([u v 1]'), 1, 1, 3); invKPs = invKPs(:,:,1:2);

%old_points_w = zeros(size(particles,1),2);
%new_points_w = zeros(size(particles,1),2);

particles_prior_this_pixel = state_prior(:,:,v,u); %permute(state_prior(v,u,:,:), [3 4 1 2]);

% get pixel coordinates in world map
% WARNING: cameraToWorldCoordinates returns [y,x] !
old_points_w = cameraToWorldCoordinatesThetaBatch(invKPs, particles_prior_this_pixel(:,2:end), size(intensities));
new_points_w = cameraToWorldCoordinatesThetaBatch(invKPs, particles_prior(:,2:end),            size(intensities));

    
% get pixel-intensity difference of prior and proposed posterior particle
%measurements = log(interp2(intensities,new_points_w(:,2),new_points_w(:,1))) - log(interp2(intensities,old_points_w(:,2),old_points_w(:,1)));

old_intensities = interp2(intensities, old_points_w(:,2), old_points_w(:,1));
new_intensities = interp2(intensities, new_points_w(:,2), new_points_w(:,1));


particles = particles_prior; % posterior positions are the same as prior positions
for p = 1:size(particles,1)
    
    % compare current pixel's intensity with all possible previous ones
    measurements = new_intensities(p) - old_intensities;
    
    assert(~any(isnan(measurements)));
    
    % center gaussian around positive or negative threshold
    likelihoods = gaussmf(measurements, [INTENSITY_VARIANCE INTENSITY_THRESHOLD*event_sign]) + LOW_LIKELIHOOD;
    %     copied from gaussmf
    %params = [INTENSITY_VARIANCE INTENSITY_THRESHOLD*event_sign];
    %sigma = params(1);
    %c = params(2);
    %likelihoods = max(exp(-(measurements - c).^2/(2*sigma^2)), 0.01) + LOW_LIKELIHOOD;
    
    %likelihoods = likelihoods/sum(likelihoods);
    
    % sum up likelihood over all possible positions at time of previous
    % event at that pixel
    particles(p,1) = likelihoods' * particles_prior_this_pixel(:,1); %permute(state_prior(v,u,:,1), [3 1 2 4]);
end

if show_plots
    % just for plotting
    particles_pixelprior_times_likelihood = particles;
end

% actually update prior probability
particles(:,1) = particles(:,1) .* particles_prior(:,1);

% normalize weights
particles = normalizeParticles(particles);

% update state
state_prior(:,:,v,u) = particles; %particleAverage(particles);



if show_plots
    
    global update_event_plot_figure;
    
    if ~exist('update_event_plot_figure','var') || isempty(update_event_plot_figure)
        update_event_plot_figure = figure('Name', 'updateOnEvent(): probabilities');
    else
        figure(update_event_plot_figure);
    end
    
    subplot(4,3,1);
    plotParticles(particles_prior);
    title('prior (current position)');
    
    subplot(4,3,2);
    plotParticles(particles_prior_this_pixel);
    title('prior (this pixel)');
    
    subplot(4,3,3);
    plotParticles(particles_pixelprior_times_likelihood);
    title('pixel prior * likelihood');
    
    
        
    subplot(4,3,4);
    plotParticlesInWorld(particles_prior, size(intensities), [u v], intensities);
    
    subplot(4,3,5);
    plotParticlesInWorld(particles_prior_this_pixel, size(intensities), [u v], intensities);
    
    
    subplot(4,3,6);
    plotParticlesInWorld(particles_pixelprior_times_likelihood, size(intensities), [u v], intensities);
    title('pixel prior * likelihood (world)');
    
    
    
    subplot(4,3,7);
    scatter(particles_prior(:,2),particles_prior(:,3),5,new_intensities,'filled');
    title({'new intensities', 'at current position'});
    colorbar;
    
    subplot(4,3,8);
    scatter(particles_prior_this_pixel(:,2),particles_prior_this_pixel(:,3),5,old_intensities,'filled');
    title({'old intensities','at previous event''s position'});
    colorbar;
    
    subplot(4,3,9);
    plotParticles(particles);
    title('posterior');
    
    
    
    
    subplot(4,3,10);
    %scatter(particles_prior(:,1),particles_prior(:,3),5,new_intensities,'filled');
    tmp_particles = particles_prior;
    tmp_particles(:,1) = new_intensities;
    plotParticlesInWorld(tmp_particles, size(intensities), [u v]);
    title({'new intensities','at current position, in world'});
    colorbar;
    
    subplot(4,3,11);
    %scatter(particles_prior(:,2),particles_prior(:,3),5,old_intensities,'filled');
    tmp_particles = particles_prior_this_pixel;
    tmp_particles(:,1) = old_intensities;
    plotParticlesInWorld(tmp_particles, size(intensities), [u v]);
    title({'old intensities','at previous event''s position, in world'});
    colorbar;
    
    subplot(4,3,12);
    plotParticlesInWorld(particles, size(intensities), [u v], intensities);
    title('posterior (world)');
    
    
    disp('waiting for user. click to continue...');
    drawnow; waitforbuttonpress;
    disp('ok, continuing...');
end



end