function plotParticlesInWorld( particles, img_size )

invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), [simulationPatchSize() simulationPatchSize()]);

w = zeros(size(particles,1),2);
for i = 1:size(particles,1);
    w(i,:) = cameraToWorldCoordinatesBatch(invKP_uv, particles(i,2:end), img_size);
end

colormap 'hot'; %'parula';
scatter(w(:,2), w(:,1), 5, particles(:,1), 'filled');
colorbar;

end

