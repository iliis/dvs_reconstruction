function params = getParameters()

% function params = getParameters()
% This function returns a struct with the constant parameters used in both
% the simulation and the reconstruction.
% 
% Available fields:
% cameraIntrinsicParameterMatrix: The intrinsic parameter matrix K
% used to map positions from camera space to world space
% 
% dvsPatchSize: The size (side length) of the original, square camera sensor in pixels
% 
% simulationPatchSize: The size (sidel length) of the virtual, square camera sensor used in the
% simulation in pixels
% 
% measurementNoise: The assumed camera measurement noise for the Kalman
% filters
% 
% pixelIntensityThreshold: The threshold of a pixel to trigger an event
% 
% outputImageSize: The size ([height, width], in pixels) of the image
% produced by the reconstruction
% 
% Some more detailed explanations in the function code

% The approximate intrinsic parameter matrix of the DVS, also used for our
% simulation
params.cameraIntrinsicParameterMatrix = [87.5 0 64.5; 0 87.5 64.5; 0 0 1];

% The size of the DVS sensor in pixels, needed to use the compute some
% offsets when saving events
% DO NOT CHANGE THIS ONE!!
params.dvsPatchSize = 128;

% The sensor size of the virtual camera in our simulation (in pixels), must
% not be larger than the original camera sensor size.
% A smaller sensor leads to a speedup in both simulation and reconstruction
params.simulationPatchSize = 64;

% The assumed measurement noise of the camera for the Kalman Filters
params.measurementNoise = 0.01;

% The accumulated intensity change that a pixel needs to trigger an event.
% Used in both the simulation and the reconstruction.
% The original camera threshold should be around 0.22, but with the
% simulation we need a smaller value to generate enough events.
params.pixelIntensityThreshold = 0.05;

% The size ([height, width], in pixels) of the image produced by the
% reconstruction
params.outputImageSize = [1000 2000];