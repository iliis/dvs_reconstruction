# Update these paths to match your installation
# You may also need to update the linker option rpath, which sets where to look for
# the SDL2 libraries at runtime to match your install
#
#SDL_LIB = -L/usr/local/lib -lSDL2 -Wl,-rpath=/usr/local/lib
#SDL_CFLAGS = -I/usr/local/include

SDL_LIB = $(shell sdl2-config --libs)
SDL_CFLAGS = $(shell sdl2-config --cflags)

CXXFLAGS = -Wall $(SDL_CFLAGS)
LDFLAGS = $(SDL_LIB)


EXE = calibrate

all: $(EXE)

$(EXE): calibration_tool.cpp
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $< -o $@

clean:
	-@rm -f *.o 2> /dev/null
	-@rm -f $(EXE) 2> /dev/null
