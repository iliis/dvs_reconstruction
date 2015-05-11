// http://stackoverflow.com/questions/21890627/drawing-a-rectangle-with-sdl2

#include <stdlib.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_events.h>

using namespace std;

int main(int argc, char* argv[])
{
    SDL_Window* window = NULL;
    window = SDL_CreateWindow
    (
        "DVS Calibration Target", SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        640,
        480,
        SDL_WINDOW_SHOWN
    );

    // Setup renderer
    SDL_Renderer* renderer = NULL;
    renderer =  SDL_CreateRenderer( window, 0, SDL_RENDERER_ACCELERATED);

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

        // clear background
        SDL_SetRenderDrawColor( renderer, 0, 0, 0, 255 );
        SDL_RenderClear( renderer );

        SDL_Rect rect;
        rect.x = 100; rect.y = 100;
        rect.w = 100; rect.h = 100;

        SDL_SetRenderDrawColor( renderer, 255, 255, 255, 255 );
        SDL_RenderFillRect(renderer, &rect);

        // Render the rect to the screen
        SDL_RenderPresent(renderer);

        SDL_Delay(1000);

        // clear background
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255 );
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);
        SDL_Delay(1000);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();

    return EXIT_SUCCESS;
}
