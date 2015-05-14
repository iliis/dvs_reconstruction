function [ events ] = convertSignalsToVectors( events_raw, timestamp )

events = zeros(size(events_raw,1), 4);
for i = 1:size(events_raw,1)
    [x, y, pol] = extractRetinaEventsFromAddr(events_raw(i));
    events(i,:) = [x+1 y+1 pol timestamp];
    % disp(['event ' num2str(i) ' at ' num2str([x y]) ' pol = ' num2str(pol) ' actual diff = ' num2str(diff(y,x))]);
end

% only use signals in small camera frame
validInds  = find(events(:,1) > 32) && (events(:,1) <= 96) && (events(:,2) > 32) && (events(:,2) <= 96);
newEvents = events(validInds,:);

% adapt indices
events = newEvents(:,1:2) - 32;

assert(all(events(:,1:2) > 0 && events(:,1:2) <= 64));

end

