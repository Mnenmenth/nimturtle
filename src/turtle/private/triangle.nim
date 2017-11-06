import sdl2.sdl
import graph
import algorithm
import math
from turtle_global import g

type
    Triangle* = ref object of RootObj
        vert1*: graph.Coordinate
        vert2*: graph.Coordinate
        vert3*: graph.Coordinate

proc rot_point(affected: var graph.Coordinate, triangle_point: var graph.Coordinate, angle: float) =
    
        let pi = arccos(float32(-1))
        let rot_angle = angle / 180.0 * pi
    
        let s = sin(rot_angle)
        let c = cos(rot_angle)
    
        affected.x -= triangle_point.x
        affected.y -= triangle_point.y
    
        let xnew = float(affected.x) * c - float(affected.y) * s
        let ynew = float(affected.x) * s + float(affected.y) * c
    
        affected.x = xnew + float(triangle_point.x)
        affected.y = ynew + float(triangle_point.y)

proc rotate*(triangle: Triangle, angle: float) =
    triangle.vert2.rot_point(triangle.vert1, angle)
    triangle.vert3.rot_point(triangle.vert1, angle)

proc drawTriangle*(renderer: sdl.Renderer, triangle: Triangle) =
    let vert1 = g.c2p(triangle.vert1)
    let vert2 = g.c2p(triangle.vert2)
    let vert3 = g.c2p(triangle.vert3)
    discard renderer.renderDrawLine(vert1.x, vert1.y, vert2.x, vert2.y)
    discard renderer.renderDrawLine(vert2.x, vert2.y, vert3.x, vert3.y)
    discard renderer.renderDrawLine(vert1.x, vert1.y, vert3.x, vert3.y)