function values = tracking1D_getMapValue( map, xpos )
%TRACKING1D_GETMAPVALUE linearly interpolates map at xpos

values = zeros(size(map,1),numel(xpos));
for x = 1:numel(xpos)
    for d = 1:size(map,1)
        values(d, x) = interp1(map(d,:),xpos(x));
    end
end

end

