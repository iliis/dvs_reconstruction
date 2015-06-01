function invKPs = getInvKPsforPatch()
% calculates K\p for all pixels p of the simulated camera
% this is just a convencience, as we usually need p*K^(-1) instead of just p

% get global Parameters
params = getParameters();

invKPs = zeros([params.simulationPatchSize params.simulationPatchSize 2]);
indexOffset = (params.dvsPatchSize - params.simulationPatchSize)/2;
for u = 1:params.simulationPatchSize
    for v = 1:params.simulationPatchSize
        invKP = params.cameraIntrinsicParameterMatrix \ [u+indexOffset v+indexOffset 1]';
        invKPs(v, u, :) = invKP(1:2);
    end
end

end