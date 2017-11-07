from math import round
type
    Coordinate* = ref object of RootObj
        x*: float
        y*: float

proc newCoordinate*(x, y: float): Coordinate =
    Coordinate(x: x, y: y)

proc newCoordinate*(t: tuple[x: float, y: float]): Coordinate =
    newCoordinate(t.x, t.y)

proc astuple*(c: Coordinate): tuple[x: float, y: float] =
    (c.x, c.y)

type
    Point* = ref object of RootObj
        x*: int
        y*: int

proc newPoint*(x, y: int): Point =
    Point(x: x, y: y)

proc newPoint*(t: tuple[x: int, y: int]): Point =
    newPoint(t.x, t.y)

proc astuple*(p: Point): tuple[x: int, y: int] =
    (p.x, p.y)

type
    Dimension* = ref object of RootObj
        width*: int
        height*: int

proc newDimension*(width, height: int): Dimension =
    Dimension(width: width, height: height)

proc newDimension*(t: tuple[width: int, height: int]): Dimension =
    newDimension(t.width, t.height)

proc astuple*(d: Dimension): tuple[width: int, height: int] =
    (d.width, d.height)

type
    Graph* = ref object of RootObj
        parentDim*: Dimension
        xmax*: int
        xmin*: int
        ymax*: int
        ymin*: int

proc newGraph*(parentDim: Dimension, xmax, xmin, ymax, ymin: int): Graph =
    Graph(parentDim: parentDim, xmax: xmax, xmin: xmin, ymax: ymax, ymin: ymin)

proc xunits(graph: Graph): float =
    float((if graph.xmax < 0: -graph.xmax else: graph.xmax) + (if graph.xmin < 0: -graph.xmin else: graph.xmin))

proc xtick(graph: Graph): float =
    float(graph.parentDim.width)/graph.xunits()

proc yunits(graph: Graph): float =
    float((if graph.ymax < 0: -graph.ymax else: graph.ymax) + (if graph.ymin < 0: -graph.ymin else: graph.ymin))

proc ytick(graph: Graph): float =
    float(graph.parentDim.height)/graph.yunits()

proc coordinateToPixelPoint*(g: Graph, c: Coordinate): Point =
    Point(
        x: int(round(c.x + float(if g.xmin < 0: -g.xmin else: g.xmin)) * g.xtick()), 
        y: int(round(-c.y + float(if g.ymin < 0: -g.ymin else: g.ymin)) * g.ytick())
        )

proc c2p*(g: Graph, c: Coordinate): Point = 
    g.coordinateToPixelPoint(c)

proc pixelPointToCoordinate*(g: Graph, p: Point): Coordinate =
    Coordinate(
        x: float(p.x) / g.xtick() - float(if g.xmin < 0: -g.xmin else: g.xmin),
        y: float(p.y) / g.ytick() - float(if g.ymin < 0: -g.ymin else: g.ymin)
    )

proc p2c*(g: Graph, p: Point): Coordinate =
    g.pixelPointToCoordinate(p)