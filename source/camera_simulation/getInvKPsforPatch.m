function invKPs = getInvKPsforPatch( K )
% TODO: use global K directly?

invKPs = zeros([simulationPatchSize() simulationPatchSize() 2]);
indexOffset = (128 - simulationPatchSize())/2;
for u = 1:simulationPatchSize()
    for v = 1:simulationPatchSize()
        invKP = K \ [u+indexOffset v+indexOffset 1]';  
        invKPs(v, u, :) = invKP(1:2);
    end
end

end