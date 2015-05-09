function plotParticlesInWorld( particles, img_size )





invKP_uv = getInvKPforPixels(cameraIntrinsicParameterMatrix(), [64 64]);

w = zeros(size(particles,1),2);
for i = 1:size(particles,1);
    w(i,:) = cameraToWorldCoordinatesBatch(invKP_uv, particles(i,2:end), img_size);
end

colormap 'hot'; %'parula';
%scatter(particles(:,2),particles(:,3),5,particles(:,1),'filled');
scatter(w(:,2), w(:,1), 5, particles(:,1), 'filled');
colorbar;

end

