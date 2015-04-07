function tracking1D_plotMap( image )

H = size(image, 1);
W = size(image, 2);

for i = 1:H
    plot(1:W, image(i,:) + 2*(H-i));
    hold on;
end

hold off;

end

