function invKPs = getInvKPsforPatch( K )

invKPs = zeros([simulationPatchSize() simulationPatchSize() 2]);
for u = 1:simulationPatchSize()
    for v = 1:simulationPatchSize()
        invKP = K \ [u+simulationPatchSize()/2 v+simulationPatchSize()/2 1]';  
        invKPs(v, u, :) = invKP(1:2);
    end
end

end