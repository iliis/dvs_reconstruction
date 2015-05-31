function img = integrateAll(allAddr)

[x,y,pol] = extractRetinaEventsFromAddr(allAddr);

image = zeros(128);

% remove negative (!) events
%pol(pol > 0) = 0;

for i = 1:size(x,1)
    image(y(i)+1, x(i)+1) = image(y(i)+1, x(i)+1) - pol(i);
end

% scale image to [0, 1]
image = image - min(min(image));
image = image / max(max(image));

img = image;