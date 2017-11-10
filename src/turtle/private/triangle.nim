## Drawable Triangle shape
#                                                      
#  Made by Earl Kennedy                               
#  https://github.com/Mnenmenth                        
#  https://mnenmenth.com

import sdl2.sdl
import graph
import algorithm
import math

type
    Triangle* = ref object of RootObj
        ## Holds three vertices that make up triangle points
        vert1*: Coordinate
        vert2*: Coordinate
        vert3*: Coordinate

proc newTriangle*(vert1, vert2, vert3: Coordinate): Triangle =
    ## Creates new triangle of given vertices
    Triangle(vert1: vert1, vert2: vert2, vert3: vert3)

method rotPoint(affected: var Coordinate, triangle_point: var Coordinate, angle: float) {.base.} =
        # Rotates a point around another given point

        # Calculates the rotation angle
        let pi = arccos(float32(-1))
        let rot_angle = angle / 180.0 * pi
    
        # Sin and Cos of the rotation angle
        let s = sin(rot_angle)
        let c = cos(rot_angle)
    
        # Subtracts the position of the center point 
        # from the point that is being rotated
        affected.x -= triangle_point.x
        affected.y -= triangle_point.y
    
        # Calculates the new coordinates for the point
        let xnew = float(affected.x) * c - float(affected.y) * s
        let ynew = float(affected.x) * s + float(affected.y) * c
    
        # Applies the new coordinates and moves back out to original distance
        affected.x = xnew + float(triangle_point.x)
        affected.y = ynew + float(triangle_point.y)

method rotate*(triangle: Triangle, angle: float) {.base.} =
    ## Rotate the base of the triangle around the tip
    triangle.vert2.rotPoint(triangle.vert1, angle)
    triangle.vert3.rotPoint(triangle.vert1, angle)

method drawTriangle*(triangle: Triangle, g: Graph, renderer: sdl.Renderer) {.base.} =
    ## Draws the triangle

    # Convert the coordinate unit points into pixels on the screen
    let vert1 = g.c2p(triangle.vert1)
    let vert2 = g.c2p(triangle.vert2)
    let vert3 = g.c2p(triangle.vert3)
    # Draw the sides of the triangle between the vertices
    discard renderer.renderDrawLine(vert1.x, vert1.y, vert2.x, vert2.y)
    discard renderer.renderDrawLine(vert2.x, vert2.y, vert3.x, vert3.y)
    discard renderer.renderDrawLine(vert1.x, vert1.y, vert3.x, vert3.y)