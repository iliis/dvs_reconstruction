function integratedImage = integrateEvents(events)

% computes a simple integration of the given events
% input: events (N*3) matrix events(i,:) = [u(i) v(i) pol(i)]
% output 128*128 matrix, each pixel is indicated with the polarity of the
% last event given for this pixel, or 0 (no event)

integratedImage = zeros(128);

for i = 1:size(events,1)
    integratedImage(events(i,2), events(i,1)) =  integratedImage(events(i,2), events(i,1)) + events(i,3);
end

integratedImage = integratedImage .* pixelIntensityThreshold();