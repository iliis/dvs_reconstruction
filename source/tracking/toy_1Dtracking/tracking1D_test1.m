
map = tracking1D_globalMap();
particles = tracking1D_initParticles(200, size(map,2));

% just plot continuing decay
N = 5;
for i = 1:N
    ax = subplot(N,1,i);
    tracking1D_plotParticles(particles);
    particles = tracking1D_predict(particles,1);
    xlim([1, size(map,2)]);
end