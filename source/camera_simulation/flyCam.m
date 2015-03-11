function flyCam(imagepath)

% Testfunction to simulate camera rotation

testimg = rgb2gray(imread(imagepath));
K = [87.5 0 64.5; 0 87.5 64.5; 0 0 1];
for beta = -pi/4*3:0.02:pi/4*3
    imshow(getPatch(testimg, K, 0, beta, 0));
    pause(0.001);
end