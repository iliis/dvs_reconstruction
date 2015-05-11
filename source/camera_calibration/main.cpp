// http://stackoverflow.com/questions/21890627/drawing-a-rectangle-with-sdl2

#include <stdlib.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_events.h>

using namespace std;

void draw_checkerboard_pattern(SDL_Window* window, SDL_Renderer* r, int numrows, int numcols)
{
    int W = 0, H = 0;
    SDL_GetWindowSize(window, &W, &H);

    SDL_Rect rect;
    rect.w = W/numcols; rect.h = H/numrows;

    for (int row = 0; row < numrows; ++row) {
        for (int col = 0; col < numcols; ++col) {
            if ((row % 2) == (col % 2)) {
                rect.x = col * rect.w;
                rect.y = row * rect.h;
                SDL_RenderFillRect(r, &rect);
            }
        }
    }
}

int main(int argc, char* argv[])
{
    SDL_Window* window = NULL;
    window = SDL_CreateWindow
    (
        "DVS Calibration Target",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        640,
        480,
        SDL_WINDOW_SHOWN | SDL_WINDOW_FULLSCREEN_DESKTOP
    );

    // Setup renderer
    SDL_Renderer* renderer = NULL;
    renderer =  SDL_CreateRenderer( window, 0, SDL_RENDERER_PRESENTVSYNC | SDL_RENDERER_ACCELERATED);

    SDL_Event e;
    bool quit = false;
    while (!quit){
        while (SDL_PollEvent(&e)){
            switch (e.type) {
                case SDL_QUIT:
                case SDL_KEYDOWN:
                case SDL_MOUSEBUTTONDOWN:
                    quit = true;
                    break;
            }
        }

        // show pattern
        SDL_SetRenderDrawColor( renderer, 0, 0, 0, 255 );
        SDL_RenderClear( renderer );

        SDL_SetRenderDrawColor( renderer, 255, 255, 255, 255 );
        draw_checkerboard_pattern(window, renderer, 6, 10);
        SDL_RenderPresent(renderer);


        // show black window
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255 );
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();

    return EXIT_SUCCESS;
}
