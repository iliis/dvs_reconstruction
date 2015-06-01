## tracking

Functions that are used to track the movement with a particle filter.  The
functions in 'plot/' enable visualization of the real and estimated camera
path.

Tracking results may vary due to the randomization used in the particle filter.

To run tracking on ground truth data (i.e. without the reconstruction half),
run test_tracknig_only.m in the root folder.

The main function here is trackMovement(), which updates a set of particles
with events and a map. It calls predict() to predict the movement and
updateOnEvent() to do the actual bayesian updating. Whenever the
effectiveParticleNumber() of the particles falls below some threshold of N\2,
they are resample()d.


### main functions

* initParticles()
  initializes data structures

* particleAverage()
  calculates weighted average over all particles

* effectiveParticleNumber()
  'effective number' of particles, used to determine if resampling is necessary

* trackMovement()
  main function for tracking, updates a set of particles with events and a map

* predict()
  get predicted position of particles after some time (constant motion model + noise)

* updateOnEvent()
  updates particles weight according to their likelihood to match an event

* resample()
  resamples particles by copy a particle with probability according to its weight
