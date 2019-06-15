## Drawable Triangle shape
#                                                      
#  Made by Earl Kennedy                               
#  https://github.com/Mnenmenth                        


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

type
    PTriangle = ref object of RootObj
        vert1*: graph.Point
        vert2*: graph.Point
        vert3*: graph.Point

proc newTriangle*(vert1, vert2, vert3: Coordinate): Triangle =
    ## Creates new triangle of given vertices
    Triangle(vert1: vert1, vert2: vert2, vert3: vert3)

proc newPTriangle(vert1, vert2, vert3: graph.Point): PTriangle =
    PTriangle(vert1: vert1, vert2: vert2, vert3: vert3)

method convPixel(triangle: Triangle, g: Graph): PTriangle {.base.} =
    newPTriangle(g.c2p(triangle.vert1), g.c2p(triangle.vert2), g.c2p(triangle.vert3))

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

method orderedVertices(triangle: Triangle): Triangle {.base.} =
    # Sorts triangle vertices into decending order based on y coordinate

    # Array to hold ordered vertices
    var ordered: array[3, Coordinate]

    # Lowest Y
    if triangle.vert1.y < triangle.vert2.y:
        if triangle.vert1.y < triangle.vert3.y:
            ordered[0] = triangle.vert1
        else:
            ordered[0] = triangle.vert3
    else:
        if triangle.vert2.y < triangle.vert3.y:
            ordered[0] = triangle.vert2
        else:
            ordered[0] = triangle.vert3

    # Highest Y
    if triangle.vert1.y > triangle.vert2.y:
        if triangle.vert1.y > triangle.vert3.y:
            ordered[2] = triangle.vert1
        else:
            ordered[2] = triangle.vert3
    else:
        if triangle.vert2.y > triangle.vert3.y:
            ordered[2] = triangle.vert2
        else:
            ordered[2] = triangle.vert3
        
    # Determine which vertice is in the middle
    if ordered.contains(triangle.vert1) and ordered.contains(triangle.vert3):
        ordered[1] = triangle.vert2
    elif ordered.contains(triangle.vert1) and ordered.contains(triangle.vert2):
        ordered[1] = triangle.vert3
    elif ordered.contains(triangle.vert2) and ordered.contains(triangle.vert3):
        ordered[1] = triangle.vert1

    # Create a new triangle with the ordered vertices
    Triangle(vert1: ordered[2], vert2: ordered[1], vert3: ordered[0])

method fillBottomFlat(triangle: PTriangle, renderer: sdl.Renderer) {.base.} =
    # Fills a triangle with a flat bottom

    # Reference to actual vertices for shorter names
    let v1 = triangle.vert1
    let v2 = triangle.vert2
    let v3 = triangle.vert3

    # Find the inverted slopes of the triangle
    let invslope1 = (v2.x - v1.x) / (v2.y - v1.y)
    let invslope2 = (v3.x - v1.x) / (v3.y - v1.y)

    # Current x values for incrementing in loop
    var curx1 = v1.x.float
    var curx2 = v1.x.float

    for scanY in v1.y .. v2.y:
        # Go through and draw each horizontal line in the given triangle
        discard renderer.renderDrawLine(curx1.int, scanY, curx2.int, scanY)
        # Increment the start and end x for the line
        curx1 += invslope1
        curx2 += invslope2

method fillTopFlat(triangle: PTriangle, renderer: sdl.Renderer) {.base} =
    # Fills a triangle with a flat top

    # Reference to actual vertices for shorter names
    let v1 = triangle.vert1
    let v2 = triangle.vert2
    let v3 = triangle.vert3

    # Find the inverted slopes of the triangle
    let invslope1 = (v3.x - v1.x) / (v3.y - v1.y)
    let invslope2 = (v3.x - v2.x) / (v3.y - v2.y)

    # Current x values for incrementing in loop
    var curx1 = v3.x.float
    var curx2 = v3.x.float

    for scanY in countdown(v3.y, v1.y):
        # Go through and draw each hotizontal line in the given triangle
        discard renderer.renderDrawLine(curx1.int, scanY, curx2.int, scanY)
        # Increment the start and end x for the line
        curx1 -= invslope1
        curx2 -= invslope2

method fillPixels(triangle: PTriangle, renderer: sdl.Renderer) {.base.} = 
    # Reference to actual vertices for shorter names
    let v1 = triangle.vert1
    let v2 = triangle.vert2
    let v3 = triangle.vert3
    
    # If the triangle i flat bottomed, use flat bottom fill
    if v2.y == v3.y:
        triangle.fillBottomFlat(renderer)
    # If the triangle is flat topped, use flat top fill
    elif v1.y == v2.y:
        triangle.fillTopFlat(renderer)
    # If the triangle is neither, cut the triangle in half, then treat the halves as two seperate triangles,
    # One with a flat bottom, and one with a flat top
    else:
        let v4 = newPoint((v1.x.float + ((v2.y - v1.y) / (v3.y - v1.y)) * (v3.x - v1.x).float).int, v2.y)
        newPTriangle(v1, v2, v4).fillBottomFlat(renderer)
        newPTriangle(v2, v4, v3).fillTopFlat(renderer)

method drawTriangle*(triangle: Triangle, filled: bool, g: Graph, renderer: sdl.Renderer) {.base.} =
    ## Draws the triangle

    # Convert the coordinate unit points into pixels on the screen
    let ordered = triangle.orderedVertices()

    let conv = ordered.convPixel(g)
    # Draw the triangle
    if filled:
        conv.fillPixels(renderer)
    else:
        discard renderer.renderDrawLine(conv.vert1.x, conv.vert1.y, conv.vert2.x, conv.vert2.y)
        discard renderer.renderDrawLine(conv.vert2.x, conv.vert2.y, conv.vert3.x, conv.vert3.y)
        discard renderer.renderDrawLine(conv.vert1.x, conv.vert1.y, conv.vert3.x, conv.vert3.y)
