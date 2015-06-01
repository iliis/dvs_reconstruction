imagepath = 'camera_simulation/testimages/panorama.png';
img = double(rgb2gray(imread(imagepath)));

close all;
fig_world = figure;
fig_patch = figure;
fig_events = figure;


thetaCheckpoints = ...
   [pi/4, pi/4, 0 ; ...
   -pi/4, -pi/4, -pi; ...
   pi/4, -pi/4, 0; ...
   -pi/4, pi/4, 2*pi];
omegas = ...
    0.01 * ...
    [-1, -1, -2; ...
    1, 0, 2; ...
    -1, 1, 4];

thetas = interpolateThetaCheckpoints(thetaCheckpoints, omegas);


loops = size(thetas,1);

disp(['got ' num2str(loops) ' frames']);

invKPs = getInvKPsforPatch(cameraIntrinsicParameterMatrix());
patch_state = getPatch(img, invKPs, thetas(1,:));

%frames_world(loops) = struct('cdata',[],'colormap',[]);
%frames_patch(loops) = struct('cdata',[],'colormap',[]);

for j = 1:loops
    
    disp(['rendering frame ' num2str(j) ' of ' num2str(loops)]);
    
    figure(fig_world);
    imagesc(img);
    colormap 'gray';
    hold on;
    plotCameraRect(thetas(j,:), size(img));
    hold off;
    axis off;
    %set(fig_world, 'position', [0 0 1 1],'units','normalized')
    set(fig_world, 'PaperPosition', [0 0 size(img,2) size(img,1)]/200);
    
    
    figure(fig_patch);
    patch = getPatch(img, invKPs, thetas(j,:));
    imagesc(patch);
    colormap 'gray';
    
    [events_raw, patch_state] = getSignals2(patch_state, patch, pixelIntensityThreshold()*255);
    events = convertSignalsToVectors(events_raw, 0);
    event_map = zeros(DVS_PatchSize());
    for k = 1:size(events,1)
        event_map(events(k,2), events(k,1)) = event_map(events(k,2), events(k,1)) + events(k,3);
    end
    
    figure(fig_events);
    imagesc(event_map);
    colormap 'gray';
    
    
    drawnow;
    %frames_world(j) = getframe(fig_world);
    %frames_patch(j) = getframe(fig_patch);
    
    event_map_red   = zeros(DVS_PatchSize());
    event_map_green = zeros(DVS_PatchSize());
    event_map_blue  = zeros(DVS_PatchSize());
    
    event_map_red(event_map < 0) = 1;
    event_map_blue(event_map > 0) = 1;
    
    imwrite(patch/255, ['animations/frames/patch_'  sprintf('%08d', j) '.png']);
    imwrite(cat(3,event_map_red,event_map_green,event_map_blue), ['animations/frames/events_' sprintf('%08d', j) '.png']);
    saveas(fig_world,  ['animations/frames/world_'  sprintf('%08d', j) '.png']);
end