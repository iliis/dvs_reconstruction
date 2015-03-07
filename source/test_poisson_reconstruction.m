% Read Input Gray Image
imgstr = 'testimages/airport.tiff';

disp(sprintf('Reading Image %s',imgstr));
img = imread(imgstr);
[H,W,C] = size(img);
img = double(img);

% Find gradinets
gx = zeros(H,W); gy = zeros(H,W);
j = 1:H-1; k = 1:W-1;
gx(j,k) = (img(j,k+1) - img(j,k));
gy(j,k) = (img(j+1,k) - img(j,k));

% Reconstruct image from gradients for verification
img_rec = poisson_solver_function(gx,gy,img);

figure;imagesc(img);colormap gray;colorbar;title('Image')
figure;imagesc(img_rec);colormap gray;colorbar;title('Reconstructed');
figure;imagesc(abs(img_rec-img));colormap gray;colorbar;title('Abs error');