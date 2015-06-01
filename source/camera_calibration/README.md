We display a flickering checkerboard pattern using the code in main.cpp.
To get the images, we records logs of the camera signal with an approximate length of around 1s using jAER and store them in the folder 'recordings'.
Afterwards, calling the script 'calibrate' will integrate the recordings to create images and call Matlab's cameraCalibrator app.