% test extractRetinaEventsFromAddr()

for i = 1:1000
    % generate random values
    event = [randi(DVS_PatchSize())-1, randi(DVS_PatchSize())-1, (randi(2)-1)*2-1]; % pol: 1: ON, -1: OFF
    
    % convert to raw event
    event_raw = getTmpdiff128Addr(event(1),event(2),(event(3)+1)/2); % pol: 1: ON, 0: OFF
    
    % convert back to normal event format
    [x,y,pol] = extractRetinaEventsFromAddr(event_raw);
    
    assert(event(1) == x);
    assert(event(2) == y);
    assert(event(3) == pol, ['pol is ' num2str(pol) ' but should be ' num2str(event(3))]);
end