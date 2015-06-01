## build

getPatch and updateOnEvent are the most time-critical functions in this project.
Compiling them and calling the respective getPatch_mex and updateOnEvent_mex functions leads to a significant speedup.