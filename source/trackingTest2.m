function [ map, gradients, theta_est ] = trackingTest2(steps)

imagepath = 'camera_simulation/testimages/panorama.png';

omega = [0 0.00001 0];

% K = cameraIntrinsicParameterMatrix();
% invKPs = zeros([128 128 2]);
% for u = 1:128
%     for v = 1:128      
%         invKP = K \ [u v 1]';  
%         invKPs(v, u, :) = invKP(1:2);
%     end
% end

% img = im2double(rgb2gray(imread(imagepath)));

[events_raw, TS, theta_gt, ~] = flyDiffCam2(imagepath, [0 0 0], steps*omega, omega, zeros(128));

[map, gradients, theta_est ] = trackingTest_combined(events_raw, TS, theta_gt, imagepath);
% 
% % convert events into normal matlab vectors
% events = zeros(size(events_raw,1), 4);
% for i = 1:size(events_raw,1)
%     [x, y, pol] = extractRetinaEventsFromAddr(events_raw(i));
%     % exractRetinaEventsFromAddr() gives 0 based indexes...
%     events(i,:) = [x+1 y+1 pol TS(i)];
%     
%     disp(['event ' num2str(i) ' at ' num2str([x y]) ' pol = ' num2str(pol)]);
% end
% 
% disp(['got ' num2str(size(events,1)) ' events']);
% 
% 
% % update on events
% N = 1000;
% [particles, tracking_state] = initParticles(N, [128 128]);
% 
% last_timestamp = 0;
% if ~exist('tracking_test2_figure', 'var') || ~ishandle(tracking_test2_figure)
%     tracking_test2_figure = figure();
% else
%     figure(tracking_test2_figure);
% end
% plotParticles(particles, omega); drawnow; %waitforbuttonpress;
% 
% theta_est = zeros(size(events, 1), 3);
% % map = zeros(3000, 6000);
% 
% for i = 1:size(events,1)
%     
%     deltaT_global = events(i,4) - last_timestamp;
%     last_timestamp = events(i,4);
%     
%     % actually perform Bayesian update
%     particles = predict(particles, deltaT_global);
%     
%     theta_est(i,:) = particleAverage(particles);
%     
%     if deltaT_global > 0; [map, ~] = reconstructMosaic(events_raw(1:i), TS(1:i), theta_est(1:i, :)); end;    
%     disp(['map extreme values: [' num2str(min(min(map))) ', ' num2str(max(max(map))) ']']);
%     
% %     if i < 200
%         [particles, tracking_state] = updateOnEvent(particles, events(i,:), img, tracking_state);
% %     else
% %         [particles, tracking_state] = updateOnEvent(particles, events(i,:), map, tracking_state);
% %     end
% 
%     disp(['updated on event ' num2str(i) ...
%         ' (time ' num2str(events(i,4)) ')' ...
%         ' = ' num2str(events(i,1:3)) ...
%         ' err = ' num2str(norm(theta_gt(i,:) - theta_est(i,:))) ...
%         ' deltaT_global = ' num2str(deltaT_global) ...
%         ' mean = ' num2str(particleAverage(particles)) ...
%         ' eff. no. = ' num2str(effectiveParticleNumber(particles))]);
%     
%     if i < 50
%         if ~exist('tracking_test2_figure', 'var') || ~ishandle(tracking_test2_figure)
%             tracking_test2_figure = figure();
%         else
%             figure(tracking_test2_figure);
%         end
%         plotParticles(particles, theta_gt(i,:)); drawnow; %waitforbuttonpress;
%     end
%     
%     if mod(i, 50) == 0
% %         [map, ~] = reconstructMosaic(events_raw(1:i), TS(1:i), theta_est(1:i, :));
%         if ~exist('intermediate_map_figure', 'var') || ~ishandle(intermediate_map_figure)
%             intermediate_map_figure = figure();
%         else
%             figure(intermediate_map_figure);
%         end
%         imagesc(map);
%         colormap(   intermediate_map_figure, 'gray');
%         drawnow;
%         disp(['map extreme values: [' num2str(min(min(map))) ', ' num2str(max(max(map))) ']']);
%         disp(['image extreme values: [' num2str(min(min(img))) ', ' num2str(max(max(img))) ']']);
%     end
%         
%     
%     % resample distribution if particles become too unevenly distributed
%     if effectiveParticleNumber(particles) < size(particles,1)/2; % paper uses 50%state
%         particles = resample(particles);
%         effno = effectiveParticleNumber(particles);
%         disp(['resampled -> mean = ' num2str(mean(particles,1)) '  eff. no. = ' num2str(effno)]);
% %         if ~exist('tracking_test2_figure', 'var') || ~ishandle(tracking_test2_figure)
% %             tracking_test2_figure = figure();
% %         else
% %             figure(tracking_test2_figure);
% %         end
% %         plotParticles(particles, theta_gt(i,:)); drawnow;% waitforbuttonpress;
%     end
% end
% 
% disp(['final mean = ' num2str(particleAverage(particles)) '  eff. no. = ' effectiveParticleNumber(particles)]);
% 
% dist = sqrt(sum(theta_gt, 2))';
% err = sqrt(sum((theta_gt - theta_est).^2, 2))';
% relerr = err ./ dist;
% 
% if ~exist('errorplot_figure', 'var') || ~ishandle(errorplot_figure)
%     errorplot_figure = figure();
% else
%     figure(errorplot_figure);
% end
% semilogy(1:size(theta_gt,1), err, 'r', 1:size(theta_gt,1), relerr, 'b', 1:size(theta_gt,1), dist, 'g');
% legend('total error', 'error relative to overall movement', 'overall movement');
% 
% 
% [map, gradients] = reconstructMosaic(events_raw(1:i), TS(1:i), theta_est(1:i, :));
% disp(['map extreme values(double): [' num2str(min(min(map))) ', ' num2str(max(max(map))) ']']);
% % disp(['map extreme values: [' num2str(min(min(im2uint8(map)))) ', ' num2str(max(max(im2uint8(map)))) ']']);
% disp(['image extreme values: [' num2str(min(min(img))) ', ' num2str(max(max(img))) ']']);
% 
% if ~exist('intermediate_map_figure', 'var') || ~ishandle(intermediate_map_figure)
%     intermediate_map_figure = figure();
% else
%     figure(intermediate_map_figure);
% end
% imagesc(map);
% colormap(intermediate_map_figure, 'gray');
% drawnow;
