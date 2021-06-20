module creator.widgets.titlebar;
import bindbc.sdl;
import bindbc.imgui;
import creator.core;
import creator.widgets;

private {
    bool incUseNativeTitlebar;

    extern(C) SDL_HitTestResult _incHitTestCallback(SDL_Window* win, const(SDL_Point)* area, void* data) nothrow {
        int winWidth, winHeight;
        SDL_GetWindowSize(win, &winWidth, &winHeight);
        
        enum RESIZE_AREA = 4;
        enum RESIZE_AREAC = RESIZE_AREA*2;

        // Resize top
        if (area.x < RESIZE_AREAC && area.y < RESIZE_AREAC) return SDL_HitTestResult.SDL_HITTEST_RESIZE_TOPLEFT;
        if (area.x > winWidth-RESIZE_AREAC && area.y < RESIZE_AREAC) return SDL_HitTestResult.SDL_HITTEST_RESIZE_TOPRIGHT;
        if (area.x < RESIZE_AREA) return SDL_HitTestResult.SDL_HITTEST_RESIZE_LEFT;
        if (area.y < RESIZE_AREA) return SDL_HitTestResult.SDL_HITTEST_RESIZE_TOP;

        // Title bar
        if (area.y < 22 && area.x < winWidth-128) return SDL_HitTestResult.SDL_HITTEST_DRAGGABLE;

        if (area.x < RESIZE_AREAC && area.y > winHeight-RESIZE_AREAC) return SDL_HitTestResult.SDL_HITTEST_RESIZE_BOTTOMLEFT;
        if (area.x > winWidth-RESIZE_AREAC && area.y > winHeight-RESIZE_AREAC) return SDL_HitTestResult.SDL_HITTEST_RESIZE_BOTTOMRIGHT;
        if (area.x > winWidth-RESIZE_AREA) return SDL_HitTestResult.SDL_HITTEST_RESIZE_RIGHT;
        if (area.y > winHeight-RESIZE_AREA) return SDL_HitTestResult.SDL_HITTEST_RESIZE_BOTTOM;

        return SDL_HitTestResult.SDL_HITTEST_NORMAL;
    }
}

/**
    Gets whether to use the native titlebar
*/
bool incGetUseNativeTitlebar() {
    return incUseNativeTitlebar;
}

/**
    Set whether to use the native titlebar
*/
void incSetUseNativeTitlebar(bool value) {
    incUseNativeTitlebar = value;

    if (!incUseNativeTitlebar) {
        SDL_SetWindowBordered(incGetWindowPtr(), cast(SDL_bool)false);
        SDL_SetWindowHitTest(incGetWindowPtr(), &_incHitTestCallback, null);
    } else {
        SDL_SetWindowBordered(incGetWindowPtr(), cast(SDL_bool)true);
        SDL_SetWindowHitTest(incGetWindowPtr(), null, null);
    }
}

/**
    Draws the custom titlebar
*/
void incTitlebar() {
    auto flags = 
        ImGuiWindowFlags.NoSavedSettings |
        ImGuiWindowFlags.NoScrollbar |
        ImGuiWindowFlags.MenuBar;
    
    if (igBeginViewportSideBar("##Titlebar", igGetMainViewport(), ImGuiDir.Up, 22, flags)) {
        if (igBeginMenuBar()) {
            ImVec2 avail;
            igGetContentRegionAvail(&avail);
            igImage(
                cast(void*)incGetLogo(), 
                ImVec2(avail.y*2, avail.y*2), 
                ImVec2(0, 0), ImVec2(1, 1), 
                ImVec4(1, 1, 1, 1), 
                ImVec4(0, 0, 0, 0)
            );

            igSeparator();
            
            debug {
                igText("Inochi Creator (Debug Mode)");
            } else {
                igText("Inochi Creator");
            }

            igGetContentRegionAvail(&avail);
            igDummy(ImVec2(avail.x-(18*4), 0));
            igPushFont(incIconFont());

                igText("");
                if (igIsItemClicked()) {
                    SDL_MinimizeWindow(incGetWindowPtr());
                }

                bool isMaximized = (SDL_GetWindowFlags(incGetWindowPtr()) & SDL_WINDOW_MAXIMIZED) > 0;
                igText(isMaximized ? "" : "");
                if (igIsItemClicked()) {
                    if (!isMaximized) SDL_MaximizeWindow(incGetWindowPtr());
                    else SDL_RestoreWindow(incGetWindowPtr());
                }
                
                igText("");
                if (igIsItemClicked()) {
                    incExit();
                }
            igPopFont();

            igEndMenuBar();
        }
            
        igEnd();
    }
}