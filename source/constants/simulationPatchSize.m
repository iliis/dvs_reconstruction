function size = simulationPatchSize()
% DVS: 128
% lower this value for faster simulations

size = 64;

% do not increase above 128, as encoding as binary addresses will probably fail
assert(size <= DVS_PatchSize());

end

