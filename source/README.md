# DVS reconstruction

This is a MATLAB implementation of the paper 'Simultaneous Mosaicing and
Tracking with an Event Camera' by Kim et al (2014).

For testing purposes we additionally implemented a camera simulation that can
generate a camera-like signal from a given image.

The parameters used might not be optimal since the long runtime makes
optimization tedious.

## Documentation

The code is mostly documented inline. Some general notes for the different
parts are contained in the enclosed readme files.

## Compiled Functions

For an increase in computing speed, some core functions should be compiled.

These are:
 * getPatch() in flyDiffCam()
 * updateOnEvent() in reconstructSceneFromEventStream()

To actually use them, change all function calls to the name of the compiled
function. These lines are marked with a [MEX] comment troughout the code.

