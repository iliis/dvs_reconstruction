% simulates camera path and reconstructs the image from this
% i.e. scene reconstruction without tracking

imagepath = 'camera_simulation/testimages/panorama.png';
% imagepath = 'camera_simulation/testimages/checkerboard_small.jpg';
% imagepath = 'camera_simulation/testimages/churchtest_downscaled.jpg';
% imagepath = 'camera_simulation/testimages/SonyCenter.jpg';

% the smaller, the more realistic but more computationally intensive!
step_size = 0.000001;



% thetaCheckpoints = ...
%     0.001 * ...
%    [pi/4, pi/4, 0 ; ...
%    -pi/4, -pi/4, 0; ...
%    pi/4, -pi/4, 0; ...
%    -pi/4, pi/4, 0];
% 
% omegas = ...
%     step_size * ...
%     [-1, -1, 0; ...
%     1, 0, 0; ...
%     -1, 1, 0];

thetaCheckpoints = ...
    [0 0 0; ...
    -pi/8 -pi/8 0];
omegas = ...
    step_size * ...
    [-1 -1 0];

% thetaCheckpoints = ...
%     0.2 * ...
%     [0 0 0; ...
%     0 -1 0; ...
%     -1 -1 0; ...
%     -1 -2 0; ...
%     -2 -2 0]; ...
% %     -2 -3 0; ...
% %     -3 -3 0];
% 
% omegas = ...
%     step_size * ...
%     [0 -1 0; ...
%     -1 0 0; ...
%     0 -1 0; ...
%     -1 0 0]; ...
% %     0 -1 0; ...
% %     -1 0 0];

% get global parameters
params = getParameters();

allAddr = [];
allTS = 0; %set first number 0 to have reference for first bunch of stamps
allThetas = [];
intermediateState = zeros(params.simulationPatchSize);

for i = 1:size(thetaCheckpoints, 1) - 1
    
    fprintf('simulating subpath %d/%d\n', i, size(omegas, 1));
    
    [addr, ts, thetas, intermediateState] = flyDiffCam(imagepath, thetaCheckpoints(i, :), thetaCheckpoints(i+1, :), omegas(i, :), intermediateState);
    
    allAddr = [allAddr; addr];
    allTS = [allTS; ts + allTS(end)];
    allThetas = [allThetas; thetas]; % ground truth
    
    disp([ ' ---> ' num2str(size(addr)) ' events generated']);
end

allTS = allTS(2:end); %remove pending 0;


disp([ num2str(size(allAddr)) ' events generated']);

[map, gradients, theta_est, imgSeq ] = reconstructSceneFromEventStream(allAddr, allTS, allThetas, imagepath);
