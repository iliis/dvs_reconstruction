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
    colormap 'gray';
    scatter(w(:,2), w(:,1), 5, [0 0 0], 'filled');
    xlimits = xlim(gca);
    ylimits = ylim(gca);
    
    image(repmat(background_image,1,1,3));
    hold on;
    
    % cannot draw particle's weight, as background image throws off the scale...
    %scatter(w(:,2), w(:,1), 5, [1 0.5 0], 'filled');
    
    
    % cut image to region with particles
    xlim(xlimits);
    ylim(ylimits);
end
    
scatter(w(:,2), w(:,1), 5, particles(:,1), 'filled');
    
% scale coloring of scatterplot to range of particle weights
% (background image might have changed this)
range = minmax(particles(:,1)');
if (range(1) >= range(2))
    range = range(1)*[0.9 1.1];
end
caxis(range);
   
set(gca,'YDir','reverse'); % Y = 0 is at the top
colormap 'parula';
colorbar;
hold on;
plot(avg_world(2), avg_world(1), 'ob');

title({'particles in world', 'blue circle: weighted average'});

end

