function rawAddr=getTmpdiff128Addr(x,y,pol)
%function rawAddr=getTmpdiff128Addr(x,y,pol);
% returns a raw address for Tmpdiff128 for a pixel with x,y location and
% pol polarity with pol=0 for OFF and 1 for ON
% TODO: use 1/-1 like in extractRetinaEventsFromAddr()
% EXPECTS {x, y} in [0, 127]!!
% TODO: expect x and y to be one-based (i.e. element of [1, 128]) and
% clamp & convert them here (and in extractRetinaEventsFromAddr).
assert(all(x>=0)); assert(all(x<DVS_PatchSize()));
assert(all(y>=0)); assert(all(y<DVS_PatchSize()));

rawAddr=(DVS_PatchSize()-1-y)*256+(DVS_PatchSize()-1-x)*2+pol; %extractor.getAddressFromCell(x,y,pol);