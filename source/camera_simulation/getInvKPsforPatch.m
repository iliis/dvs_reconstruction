function invKPs = getInvKPsforPatch( K )
% TODO: use global K directly?

% get global Parameters
params = getParameters();

invKPs = zeros([params.simulationPatchSize params.simulationPatchSize 2]);
indexOffset = (params.dvsPatchSize - params.simulationPatchSize)/2;
for u = 1:params.simulationPatchSize
    for v = 1:params.simulationPatchSize
        invKP = K \ [u+indexOffset v+indexOffset 1]';  
        invKPs(v, u, :) = invKP(1:2);
    end
end

end