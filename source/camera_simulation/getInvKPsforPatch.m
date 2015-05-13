function invKPs = getInvKPsforPatch( K )

invKPs = zeros([64 64 2]);
for u = 1:64
    for v = 1:64      
        invKP = K \ [u v 1]';  
        invKPs(v, u, :) = invKP(1:2);
    end
end

end

