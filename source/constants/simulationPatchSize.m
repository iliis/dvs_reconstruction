function size = simulationPatchSize()
% DVS: 128
% lower this value for faster simulations

size = 128;
assert(size == DVS_PatchSize()); % there are serious bugs with smaller patch sizes!!!

% do not increase above 128, as encoding as binary addresses will probably fail
assert(size <= DVS_PatchSize());

end

