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

proc draw*(movement: Movement, g: graph.Graph, renderer: sdl.Renderer) =
    movement.line.draw(g, renderer)