function plotParticlesInWorld( particles, img_size )

invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), [simulationPatchSize() simulationPatchSize()]);
w = cameraToWorldCoordinatesThetaBatch(invKP_uv, particles(:,2:end), img_size);

avg = particleAverage(particles);
% camera to world coordinates returns [y, x] !!1!einself!
avg_world = cameraToWorldCoordinatesBatch(invKP_uv, avg, img_size);

colormap 'hot'; %'parula';
scatter(w(:,2), w(:,1), 5, particles(:,1), 'filled');
colorbar;
plot(avg_world(2), avg_world(1), 'ob');

title({'particles in world', 'blue circle: weighted average'});



end

