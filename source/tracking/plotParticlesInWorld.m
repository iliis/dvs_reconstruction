function plotParticlesInWorld( particles, img_size, uv, background_image )

if nargin < 2 || ~exist('uv','var') || isempty(uv)
    % take camera center
    uv = [simulationPatchSize() simulationPatchSize()]/2;
end

invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), uv);
w = cameraToWorldCoordinatesThetaBatch(invKP_uv, particles(:,2:end), img_size);

avg = particleAverage(particles);
% camera to world coordinates returns [y, x] !!1!einself!
avg_world = cameraToWorldCoordinatesBatch(invKP_uv, avg, img_size);


if nargin >= 4 && ~isempty(background_image)
    
    % measure region of interest
    scatter(w(:,2), w(:,1), 5, [0 0 0], 'filled');
    xlimits = xlim(gca);
    ylimits = ylim(gca);
    
    imagesc(background_image);
    hold on;
    
    % cannot draw particle's weight, as background image throws off the scale...
    scatter(w(:,2), w(:,1), 5, [1 0.5 0], 'filled');
    
    % cut image to region with particles
    xlim(xlimits);
    ylim(ylimits);
else
    scatter(w(:,2), w(:,1), 5, particles(:,1), 'filled');
    set(gca,'YDir','reverse'); % Y = 0 is at the top
    colormap 'hot'; %'parula';
    colorbar;
    hold on;
end

plot(avg_world(2), avg_world(1), 'ob');
hold off;

title({'particles in world', 'blue circle: weighted average'});

end

