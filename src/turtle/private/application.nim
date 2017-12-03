import sdl2.sdl
import libgraph
import frame_manager
from math import round

type 
    App* = ref object of RootObj
        # Contains window and renderer for turtle graphics
        window*: sdl.Window 
            # window stores the window for drawing graphics
        renderer*: sdl.Renderer 
            # renderer stores the renderer for drawing graphics

const
    # Constants for sdl window
    Title* = "Turtle"
    Width* = 1280
    Height* = 720
    WindowFlags* = 0
    RenderFlags* = 0
    FPS*: int = 60

let 
    app* = App(window: nil, renderer: nil)
    # New graph object for unit to pixel conversion
    g*: Graph = newGraph(newDimension(Width, Height), 100, 100, 100, 100)

var
    # FPS Manager for graphics loop
    fpsMgr* = newFpsManager(FPS)
    # Stores if sdl has been initialized
    sdlInit*: bool = false

method init*(app: App): bool {.base.} =
    # Only initialize sdl if it has not already been initialized
    if sdlInit == false:
        # Initialize sdl
        if sdl.init(sdl.InitVideo or sdl.InitTimer) != 0:
            # Print error if sdl cannot Initalize
            echo "Error: Cannot init sdl: ", sdl.getError()
            return false

        # Create new window
        app.window = sdl.createWindow(
            Title,
            sdl.WindowPosCentered,
            sdl.WindowPosCentered,
            Width,
            Height,
            WindowFlags
        )

        # Check if window was created successfully
        if app.window == nil:
            # If window failed creation, print out the error
            echo "Error: Cannot open window: ", sdl.getError()
            return false

        # Create the renderer for the window
        app.renderer = sdl.createRenderer(app.window, -1, RenderFlags)
        # Check if the renderer was created successfully
        if app.renderer == nil:
            # If renderer failed creation, print out the error
            echo "Error: Cannot open window: ", sdl.getError()
            return false

        # Check if the renderer is able to set the color for drawing
        if app.renderer.setRenderDrawColor(0xFF, 0xFF, 0xFF, 0xFF) != 0:
            # If renderer is unable to set draw color, print out the error
            echo "Error: Cannot set draw color" , sdl.getError()
            return false

        # Get the information about the current modeling the window is in
        var mode: DisplayMode
        
        discard sdl.getDisplayMode(0, 0, addr(mode))

        # The window should be 5/8 the resolution of the host monitor
        let scale = 5/8

        # Apply the scale
        let w = int(round(mode.h.float * scale))
        let h = int(round(mode.h.float * scale))

        # Set the window size
        app.window.setWindowSize(w, h)
        # Set the window position to be centered on the screen
        app.window.setWindowPosition(sdl.WindowPosCentered, sdl.WindowPosCentered)
        # Set the parent dimension of the conversion graph to the new size
        g.parentDim = newDimension(w, h)

        echo "SDL init successfully"
        sdlInit = true
    return true

method exit*(app: App) {.base.} = 
    # Destroy window and renderer, and quit sdl
    app.renderer.destroyRenderer()
    app.window.destroyWindow()
    sdl.quit()
    echo "SDL shutdown complete"

proc events*(pressed: var seq[sdl.Keycode]): bool =
    # Gathers input events. Returns if program should quit

    # False by default
    result = false
    # Current event
    var e: sdl.Event
    # Empty last list of pressed keys
    if pressed != nil:
        pressed = @[]

    while sdl.pollEvent(addr(e)) != 0:
        # If the window receives the quit signal, then exit
        if e.kind == sdl.Quit:
            return true
        elif e.kind == sdl.KeyDown:
            # If a key is pressed, add it to the list of pressed keys
            if pressed != nil:
                pressed.add(e.key.keysym.sym)
            # If escape is pressed, then exit
            if e.key.keysym.sym == sdl.K_ESCAPE:
                return true