function plotParticles( particles, true_solution )

% axisLimits = 0.001 * [-0.1 1.9 -1 1];
axisLimits = [-1 1 -1 1];

subplot(1,2,1);
colormap 'hot'; %'parula';
whitebg 'black';
scatter(particles(:,2),particles(:,3),5,particles(:,1),'filled');
%quiver(particles(:,2), particles(:,3), -sin(particles(:,4)).*particles(:,1), cos(particles(:,4)).*particles(:,1));
colorbar;
hold on;
avg = particleAverage(particles);
plot(avg(1), avg(2), 'xb');

if nargin > 1
    % plot actual solution
    plot(true_solution(1), true_solution(2), 'og');
end
axis(axisLimits);
hold off;

title({'blue X: weighted average over particles', 'green O: correct solution'});

% L = 0.01; % same as in trackingTest3
% %L = 0.001;
% xlim([-L L]);
% ylim([-L L]);

ax = subplot(1,2,2);
hist(ax,particles(:,1));
% ax.YScale = 'log'; % not really supported (bottom of bar is at 0 = -inf on log scale)

N = size(particles,1);
eff_N = effectiveParticleNumber(particles);
title(['effective number = ' num2str(eff_N) ' (' num2str(eff_N/N*100) '%)']);

end

