function plotParticles( particles, true_solution,  plot_histogram)

if nargin < 3 || ~exist('plot_histogram','var') || isempty(plot_histogram)
    plot_histogram = false;
end

if plot_histogram
    subplot(1,2,1);
end

scatter(particles(:,2),particles(:,3),5,particles(:,1),'filled');
colormap 'hot'; %'parula';
whitebg([0.2 0.2 0.2]);
%quiver(particles(:,2), particles(:,3), -sin(particles(:,4)).*particles(:,1), cos(particles(:,4)).*particles(:,1));
colorbar;
hold on;
avg = particleAverage(particles);
plot(avg(1), avg(2), 'xb');

if ~(~exist('true_solution','var') || isempty(true_solution))
    % plot actual solution
    plot(true_solution(1), true_solution(2), 'og');
end


%axisLimits = 0.001 * [-0.1 1.9 -1 1];
%axisLimits = [-1 1 -1 1];
%axis(axisLimits);


hold off;

title({'blue X: weighted average over particles', 'green O: correct solution'});

% L = 0.01; % same as in trackingTest3
% %L = 0.001;
% xlim([-L L]);
% ylim([-L L]);

if plot_histogram
    ax = subplot(1,2,2);
    hist(ax,particles(:,1));
    % ax.YScale = 'log'; % not really supported (bottom of bar is at 0 = -inf on log scale)

    N = size(particles,1);
    eff_N = effectiveParticleNumber(particles);
    title(['effective number = ' num2str(eff_N) ' (' num2str(eff_N/N*100) '%)']);
end

end

