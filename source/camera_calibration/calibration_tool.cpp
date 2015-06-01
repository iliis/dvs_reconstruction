/*
 * CALIBRATION TOOL FOR DVS
 *
 * This is a simple tool for calibrating the camera intrinsics and focus of a
 * dynamic vision sensor. As a DVS only shows changes, this program displays a
 * standard checkerboard pattern by quickly turning it on and off.
 *
 * WARNING: prolonged exposure might result in eye cancer!
 *
 *
 * COMPILATION:
 *
 * requires SDL2 to work
 * use provided makefile or simply compile with
 *      g++ $(sdl2-config --cflags --libs) main.cpp -o calibrate
 *
 *
 * USAGE:
 *
 *      ./calibrate pattern
 *
 * Where pattern is one of the following:
 *
 *-> checkerboard
 *      Standard checkerboard pattern for calibrating camera intrinsics.
 *
 *-> points
 *      Rectangular array of square points. Might come in handy.
 *
 *-> focus
 *      Concentric squares with progressively smaller sizes. Can be used to
 *      focus camera optics.
 *
 * How to calibrate a dynamic vision sensor:
 * 1. Execute this program and make if fullscreen.
 * 2. Use jAER to record a second or two of events while holding the camera
 *    pointed still at the screen.
 * 3. Convert the recordings to PNG files with convert_recordings.m
 * 4. Use your prefered camera calibration toolbox (for example Matlab's
 *    cameraCalibrator) with the converted images.
 *
 */

// based partly on
// http://stackoverflow.com/questions/21890627/drawing-a-rectangle-with-sdl2

#include <stdlib.h>
#include <math.h>
#include <iostream>
#include <string>
#include <algorithm>
#include <SDL2/SDL.h>
#include <SDL2/SDL_events.h>

using namespace std;

const int RECTSIZE = 180;

void draw_checkerboard_pattern(SDL_Window* window, SDL_Renderer* r, int rect_size, bool points = false)
{
    int W = 0, H = 0;
    SDL_GetWindowSize(window, &W, &H);

    SDL_Rect rect;

    int numcols = floor(W/rect_size);
    int numrows = floor(H/rect_size);

    if (points) {
        rect.w = W/numcols/3;
        rect.h = H/numrows/3;
    } else {
        //rect.w = W/numcols;
        rect.h = rect_size;
        rect.w = rect_size;
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
        SDL_WINDOW_SHOWN |
        SDL_WINDOW_BORDERLESS |
        SDL_WINDOW_MAXIMIZED |
        SDL_WINDOW_RESIZABLE
        //SDL_WINDOW_FULLSCREEN_DESKTOP
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
                //case SDL_KEYDOWN:
                //case SDL_MOUSEBUTTONDOWN:
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
                draw_checkerboard_pattern(window, renderer, RECTSIZE);
                break;

            case 2:
                draw_checkerboard_pattern(window, renderer, RECTSIZE, true);
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
