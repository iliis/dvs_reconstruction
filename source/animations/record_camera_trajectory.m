imagepath = 'camera_simulation/testimages/panorama.png';
img = double(rgb2gray(imread(imagepath)));

fig_world = figure;
fig_patch = figure;


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

%frames_world(loops) = struct('cdata',[],'colormap',[]);
%frames_patch(loops) = struct('cdata',[],'colormap',[]);
invKPs = getInvKPsforPatch(cameraIntrinsicParameterMatrix());
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
    set(fig_world, 'PaperPosition', [0 0 size(img,2) size(img,1)]/400);
    
    
    figure(fig_patch);
    patch = getPatch(img, invKPs, thetas(j,:));
    imagesc(patch);
    colormap 'gray';
    
    
    drawnow;
    %frames_world(j) = getframe(fig_world);
    %frames_patch(j) = getframe(fig_patch);
    
    imwrite(patch/255, ['animations/frames/patch_' sprintf('%08d', j) '.png']);
    saveas(fig_world,  ['animations/frames/world_' sprintf('%08d', j) '.png']);
    
    return;
end