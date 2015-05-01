function invKPs = getInvKPsforPatch( K )

invKPs = zeros([128 128 2]);
for u = 1:128
    for v = 1:128      
        invKP = K \ [u v 1]';  
        invKPs(v, u, :) = invKP(1:2);
    end
end

end

