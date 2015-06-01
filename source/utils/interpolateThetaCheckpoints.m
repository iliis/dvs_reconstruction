function thetas = interpolateThetaCheckpoints(theta_checkpoints, omegas)

thetas = [];
for t = 1:size(theta_checkpoints,1)-1
    
    thetaStart = theta_checkpoints(t,:);
    thetaStop  = theta_checkpoints(t+1,:);
    omega      = omegas(t,:);
    
    steps = round((thetaStop - thetaStart) ./ omega);

    steps((thetaStop - thetaStart) == 0 & omega == 0) = 0; %avoid invalid values due to division by 0

    if (steps(1) ~= steps(2) && steps(1) ~= 0 && steps(2) ~= 0) || ...
            (steps(1) ~= steps(3) && steps(1) ~= 0 && steps(3) ~= 0) || ...
            (steps(2) ~= steps(3) && steps(2) ~= 0 && steps(3) ~= 0) || ...
            steps(1) < 0 || ...
            steps(2) < 0 || ...
            steps(3) < 0;

        fprintf('steps(1): %d\n', steps(1));
        fprintf('steps(2): %d\n', steps(2));
        fprintf('steps(3): %d\n', steps(3));
        error('movement in alpha/beta dimension not consisten with start/endpoints');
    end
    
    steps = max(steps);
    
    thetas = [thetas; interp1([thetaStart; thetaStop], linspace(1,2,steps))];

end