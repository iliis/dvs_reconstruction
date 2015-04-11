function events = tracking1D_generateSignals( map, startx, endx, time )
%TRACKING1D_GETSIGNALS sweeps over map from startx to endx in time
% event: [ydim sign timestamp real_xpos]

%disp(['generating events. speed = ' num2str((endx-startx)/time) ' map units / time units']);

state = tracking1D_getMapValue(map, startx);

events = [];

xs = linspace(startx, endx, 1000);
for i = 1:numel(xs);
    x = xs(i);
    t = (i-1)/(numel(xs)-1) * time;
    
    diff = tracking1D_getMapValue(map, x) - state;
    
    
    for d = 1:size(diff,1)
        if abs(diff(d))+0.01 >= tracking1D_pixelIntensityThreshold()
            % assumes the sampling is fine enough to never get a delta
            % of >= 2*threshold
            s = sign(diff(d));
            state(d) = state(d) + tracking1D_pixelIntensityThreshold() * s;
            events = [events; d s t x];
        end
    end
end

end

