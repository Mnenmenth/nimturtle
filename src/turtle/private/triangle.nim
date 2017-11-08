import sdl2.sdl
import graph
import algorithm
import math

type
    Triangle* = ref object of RootObj
        vert1*: Coordinate
        vert2*: Coordinate
        vert3*: Coordinate

proc newTriangle*(vert1, vert2, vert3: Coordinate): Triangle =
    Triangle(vert1: vert1, vert2: vert2, vert3: vert3)

method rot_point(affected: var Coordinate, triangle_point: var Coordinate, angle: float) {.base.} =

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

method rotate*(triangle: Triangle, angle: float) {.base.} =
    triangle.vert2.rot_point(triangle.vert1, angle)
    triangle.vert3.rot_point(triangle.vert1, angle)

method drawTriangle*(triangle: Triangle, g: Graph, renderer: sdl.Renderer) {.base.} =
    let vert1 = g.c2p(triangle.vert1)
    let vert2 = g.c2p(triangle.vert2)
    let vert3 = g.c2p(triangle.vert3)
    discard renderer.renderDrawLine(vert1.x, vert1.y, vert2.x, vert2.y)
    discard renderer.renderDrawLine(vert2.x, vert2.y, vert3.x, vert3.y)
    discard renderer.renderDrawLine(vert1.x, vert1.y, vert3.x, vert3.y)