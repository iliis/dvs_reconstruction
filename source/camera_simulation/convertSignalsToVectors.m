function [ events ] = convertSignalsToVectors( events_raw, timestamp )
% batch-converting a list of events
% event: [x y pol timestamp]

events = zeros(size(events_raw,1), 4);
for i = 1:size(events_raw,1)
    [x, y, pol] = extractRetinaEventsFromAddr(events_raw(i));
    events(i,:) = [x+1 y+1 pol timestamp];
    % disp(['event ' num2str(i) ' at ' num2str([x y]) ' pol = ' num2str(pol) ' actual diff = ' num2str(diff(y,x))]);
end

params = getParameters();
assert(all(all(events(:,1:2) > 0 & events(:,1:2) <= params.simulationPatchSize)));

end

