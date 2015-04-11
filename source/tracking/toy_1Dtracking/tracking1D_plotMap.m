function tracking1D_plotMap( image, events )

H = size(image, 1);
W = size(image, 2);

whitebg('black');

for i = 1:H
    plot(1:W, image(i,:) + 2*(H-i), 'w-');
    hold on;
end

if nargin > 1 && size(events,1) > 0
    for i = 1:size(events,1)
        ev = events(i,:);
        % plot events [ydim, sign, timestamp, true xpos]
        if ev(2)>0
            color = 'g-';
        else
            color = 'r-';
        end
        plot([ev(4) ev(4)], [2*(H-ev(1))     2*(H-ev(1))+1], color);
        text(ev(4),2*(H-ev(1))+1,num2str(i), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    end
end

hold off;

end

