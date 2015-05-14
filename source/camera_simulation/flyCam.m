function flyCam(imagepath)

% Testfunction to simulate camera rotation

testimg = im2double(rgb2gray(imread(imagepath)));
K = cameraIntrinsicParameterMatrix();
for beta = -pi/4*3:0.02:pi/4*3
    invKPs = getInvKPsforPatch(K);
    imshow(getPatch(testimg, invKPs, [-pi/8 beta 0]));
    drawnow;
end