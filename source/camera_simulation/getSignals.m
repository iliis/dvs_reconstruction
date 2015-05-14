function [addr, ts, state] = getSignals(oldPatch, newPatch, time, state, threshold)

% computes the signals of the changed pixels from the two image patches and the system state

diff = double(newPatch) - double(oldPatch);

state = state + diff;

% state(isnan(state)) = 0; %hack to avoid constant Nan values if one pixel
% was once outside of the source image

pIdx = state > threshold;
nIdx = state < -threshold;

% compute indices of noise
noiseInds = randperm(64*64, max(20, round(sum(sum(pIdx + nIdx))/20)));
nOfNoisePxls = size(noiseInds, 1);
pIdx(noiseInds(1:round(nOfNoisePxls / 4))) = true;
nIdx(noiseInds(1:round(nOfNoisePxls / 4))) = false;
pIdx(noiseInds(round(nOfNoisePxls / 4 + 1):round(nOfNoisePxls / 2))) = false;
nIdx(noiseInds(round(nOfNoisePxls / 2 + 1):round(3*nOfNoisePxls / 4))) = true;
pIdx(noiseInds(round(nOfNoisePxls / 2 + 1):round(3*nOfNoisePxls / 4))) = false;
nIdx(noiseInds(round(3*nOfNoisePxls / 4 + 1):end)) = false;

% visDiffs = 0.5*ones(128);
% visDiffs(pIdx) = 1;
% visDiffs(nIdx) = 0;

% imshow(visDiffs);

[vp, up] = find(pIdx);
[vn, un] = find(nIdx);

% state(vp, up) = state(vp, up) - threshold;
% state(vn, un) = state(vn, un) + threshold;

state(vp, up) = 0;
state(vn, un) = 0;

% WHY IS THERE A -1 ?
% The camera works with 8 bit unsigned integers for pixel coordinates
% -> it doesn't make much sense to work with 8 bit uints in Matlab (we're
%    actually using float/doubles anyway), better use one-based indexing
%    troughout the whole Matlab codebase.
addr = getTmpdiff128Addr([up; un]-1,  [vp; vn]-1,  [ones(size(vp)); zeros(size(vn))]);

ts = time*ones(size(addr));