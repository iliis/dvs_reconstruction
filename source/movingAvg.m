function [ data_smooth ] = movingAvg( data, avg_count )
% averages data over avg_count points (along first dimension)

assert(size(data,1) >= avg_count);

data_smooth = zeros(size(data,1)-avg_count+1, size(data,2));

for i = 1:size(data_smooth,1)
    data_smooth(i,:) = sum( data(i:i+avg_count-1, :), 1) ./ avg_count;
end

end

