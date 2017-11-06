import graph
import turtle_global
import sdl2.sdl

type
    Line* = ref object of RootObj
        lineStart*: graph.Coordinate
        lineEnd*: graph.Coordinate
        color*: tuple[r: int, g: int, b: int]                

#proc newLine*(lineStart: graph.Point, lineEnd: graph.Point): Line =
#    Line(lineStart: lineStart, lineEnd: lineEnd)

proc draw*(line: Line, renderer: sdl.Renderer) =
    let lineStart = g.c2p(line.lineStart)
    let lineEnd = g.c2p(line.lineEnd)
    discard sdl.renderDrawLine(renderer, lineStart.x, lineStart.y, lineEnd.x, lineEnd.y)