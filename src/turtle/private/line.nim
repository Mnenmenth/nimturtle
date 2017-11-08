import graph
import sdl2.sdl

type
    Line* = ref object of RootObj
        lineStart*: graph.Coordinate
        lineEnd*: graph.Coordinate

proc newLine*(lineStart, lineEnd: graph.Coordinate): Line =
    Line(lineStart: lineStart, lineEnd: lineEnd)

proc newLine*(lineStart, lineEnd: tuple[x: float, y: float]): Line =
    newLine(newCoordinate(lineStart.x, lineStart.y), newCoordinate(lineEnd.x, lineEnd.y))

method draw*(line: Line, g: graph.Graph, renderer: sdl.Renderer) {.base.} =
    let lineStart = g.c2p(line.lineStart)
    let lineEnd = g.c2p(line.lineEnd)
    discard sdl.renderDrawLine(renderer, lineStart.x, lineStart.y, lineEnd.x, lineEnd.y)