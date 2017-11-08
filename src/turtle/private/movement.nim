import graph
import line
import sdl2.sdl

type
    Movement* = ref object of RootObj
        line*: Line
        heading*: float
        color*: tuple[r, g, b: int]
        visible*: bool
        animated*: bool

proc newMovement*(line: Line, heading: float, color: tuple[r, g, b: int], visible: bool, animated: bool = false): Movement =
    Movement(line: line, heading: heading, color: color, visible: visible, animated: animated)

method draw*(movement: Movement, g: Graph, renderer: sdl.Renderer) {.base.} =
    movement.line.draw(g, renderer)