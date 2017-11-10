## Movement made by a turtle
#                                                      
#  Made by Earl Kennedy                               
#  https://github.com/Mnenmenth                        
#  https://mnenmenth.com

import graph
import line
import sdl2.sdl

type
    Movement* = ref object of RootObj
        ## Holds information about the movement made by a turtle
        line*: Line
        heading*: float
        color*: tuple[r, g, b: int]
        visible*: bool
        animated*: bool

proc newMovement*(line: Line, heading: float, color: tuple[r, g, b: int], visible: bool, animated: bool = false): Movement =
    ## Creates a new movement
    Movement(line: line, heading: heading, color: color, visible: visible, animated: animated)

method draw*(movement: Movement, g: Graph, renderer: sdl.Renderer) {.base.} =
    ## Draws the movement
    movement.line.draw(g, renderer)