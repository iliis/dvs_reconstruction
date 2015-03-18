function [addr, ts, state] = getSignals(oldPatch, newPatch, time, state, threshold)

% computes the signals of the changed pixels from the two image patches and the system state

diff = double(newPatch) - double(oldPatch);

state = state + diff;

pIdx = state > threshold;
nIdx = state < -threshold;

visDiffs = 0.5*ones(128);
visDiffs(pIdx) = 1;
visDiffs(nIdx) = 0;

imshow(visDiffs);

[vp, up] = find(pIdx);
[vn, un] = find(nIdx);

% state(vp, up) = state(vp, up) - threshold;
% state(vn, un) = state(vn, un) + threshold;

state(vp, up) = 0;
state(vn, un) = 0;

addr = getTmpdiff128Addr([up; un]-1,  [vp; vn]-1,  [ones(size(vp)); zeros(size(vn))]);
ts = time*ones(size(addr));