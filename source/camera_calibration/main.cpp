// http://stackoverflow.com/questions/21890627/drawing-a-rectangle-with-sdl2

#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <SDL2/SDL.h>
#include <SDL2/SDL_events.h>

using namespace std;

void draw_checkerboard_pattern(SDL_Window* window, SDL_Renderer* r, int numrows, int numcols, bool points = false)
{
    int W = 0, H = 0;
    SDL_GetWindowSize(window, &W, &H);

    SDL_Rect rect;

    if (points) {
        rect.w = W/numcols/3;
        rect.h = H/numrows/3;
    } else {
        rect.w = W/numcols;
        rect.h = H/numrows;
    }

    for (int row = 0; row < numrows; ++row) {
        for (int col = 0; col < numcols; ++col) {
            if (points) {
                rect.x = col * rect.w * 3 + rect.w;
                rect.y = row * rect.h * 3 + rect.h;
                SDL_RenderFillRect(r, &rect);
            } else {
                if ((row % 2) == (col % 2)) {
                    rect.x = col * rect.w;
                    rect.y = row * rect.h;
                    SDL_RenderFillRect(r, &rect);
                }
            }
        }
    }
}

void draw_focus_pattern(SDL_Window* window, SDL_Renderer* r)
{
    int W = 0, H = 0;
    SDL_GetWindowSize(window, &W, &H);

    SDL_Rect rect;
    rect.w = W; //pow(2, floor(log2(std::max(W,H))));
    rect.h = rect.w;

    bool white = true;

    while (rect.w > 0) {
        if (white)
            SDL_SetRenderDrawColor(r, 255, 255, 255, 255 );
        else
            SDL_SetRenderDrawColor(r, 0, 0, 0, 255 );

        // draw centered rectangle
        rect.x = W/2 - rect.w/2;
        rect.y = H/2 - rect.h/2;

        SDL_RenderFillRect(r, &rect);

        rect.w = rect.w * 0.8;
        rect.h = rect.w;
        white = !white; // alternate colors
    }
}

int main(int argc, const char* argv[])
{
    int pattern = 0;
    if (argc == 2) {
        if (argv[1] == string("checkerboard"))
            pattern = 1;
        else if (argv[1] == string("points"))
            pattern = 2;
        else if (argv[1] == string("focus"))
            pattern = 3;
    }

    if (pattern == 0) {
        cout << "usage: " << argv[0] << " pattern" << endl;
        cout << "where pattern = 'checkerboard', 'points' or 'focus'" << endl;

        return EXIT_FAILURE;
    }

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

        switch (pattern) {
            case 1:
                draw_checkerboard_pattern(window, renderer, 6, 10);
                break;

            case 2:
                draw_checkerboard_pattern(window, renderer, 6, 10, true);
                break;

            case 3:
                draw_focus_pattern(window, renderer);
                break;
        }
        SDL_RenderPresent(renderer);

        //SDL_Delay(50);


        // show black window
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255 );
        SDL_RenderClear(renderer);
        SDL_RenderPresent(renderer);

        //SDL_Delay(50);
    }

    SDL_DestroyWindow(window);
    SDL_Quit();

    return EXIT_SUCCESS;
}
