% sweep over map and generate events

map = tracking1D_globalMap();
particles = tracking1D_initParticles(1000, size(map));

events = tracking1D_generateSignals(map, size(map,2)/2, size(map,2)-1, 100)

tracking1D_plotMap(map, events);