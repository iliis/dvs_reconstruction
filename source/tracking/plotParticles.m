function plotParticles( particles )

subplot(1,2,1);
colormap 'parula';
whitebg 'black';
scatter(particles(:,2),particles(:,3),5,particles(:,1),'filled');
colorbar;
hold on;
avg = particleAverage(particles);
plot(avg(1), avg(2), 'xr');

% plot actual solution
% TODO: make this an optional parameter
plot(0.0003, 0, 'og');

hold off;

%L = 0.05;
L = 0.001;
xlim([-L L]);
ylim([-L L]);

ax = subplot(1,2,2);
hist(ax,particles(:,1));
% ax.YScale = 'log'; % not really supported (bottom of bar is at 0 = -inf on log scale)

N = size(particles,1);
eff_N = effectiveParticleNumber(particles);
title(['effective number = ' num2str(eff_N) ' (' num2str(eff_N/N*100) '%)']);

end

