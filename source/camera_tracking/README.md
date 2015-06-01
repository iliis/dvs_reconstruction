## tracking

Functions that are used to track the movement with a particle filter.  The
functions in 'plot/' enable visualization of the real and estimated camera
path.

Tracking results may vary due to the randomization used in the particle filter.

To run tracking on ground truth data (i.e. without the reconstruction half),
run test_tracknig_only.m in the root folder.

The main function here is trackMovement(), which updates a set of particles
with events and a map. It calls predict() to predict the movement and
updateOnEvent() to do the actual bayesian updating.


### main functions

initParticles()

particleAverage()

effectiveParticleNumber()

trackMovement()

predict()

updateOnEvent()

resample()
