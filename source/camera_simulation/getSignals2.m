function [ events, patch_state ] = getSignals2( patch_state, new_patch, threshold )

% computes the signals of the changed pixels from the two image patches and the system state

diff = double(new_patch) - patch_state;

pIdx = diff > threshold;
nIdx = diff < -threshold;

[vp, up] = find(pIdx);
[vn, un] = find(nIdx);

if false
    %figure;
    subplot(1,3,1);
    imagesc(patch_state);
    hold on;
    plot(up, vp, 'og');
    plot(un, vn, 'or');
    hold off;
    title('patch state');

    subplot(1,3,2);
    imagesc(diff);
    hold on;
    plot(up, vp, 'og');
    plot(un, vn, 'or');
    hold off;
    title('difference newpatch-patchstate');

    subplot(1,3,3);
    imagesc(double(new_patch));
    hold on;
    plot(up, vp, 'og');
    plot(un, vn, 'or');
    hold off;
    title('new patch');
    
    drawnow; waitforbuttonpress;
end

patch_state(vp, up) = new_patch(vp, up);
patch_state(vn, un) = new_patch(vn, un);

% WHY IS THERE A -1 ?!?!
% Camera gives 0 based coordinates, but Matlab code expects indexes starting with 1
events = getTmpdiff128Addr([up; un]-1,  [vp; vn]-1,  [ones(size(vp)); zeros(size(vn))]);
%events = getTmpdiff128Addr([up; un],  [vp; vn],  [ones(size(vp)); zeros(size(vn))]);

end

