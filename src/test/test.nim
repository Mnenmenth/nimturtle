#[
    Test file for nimturtle

    Made by Earl Kennedy
    https://github.com/Mnenmenth
    https://mnenmenth.com
]#

import ../turtle
import rdstdin, strutils

proc dsfc(turtle: Turtle, x: float) =
    turtle.pu()
    turtle.fd(-x/2)
    turtle.rt(90)
    turtle.fd(x/2)
    turtle.lt(90)
    turtle.pd()
    turtle.fd(x)
    turtle.lt(90)
    turtle.fd(x)
    turtle.lt(90)
    turtle.fd(x)
    turtle.lt(90)
    turtle.fd(x)
    turtle.lt(90)
    turtle.pu()
    turtle.fd(x/2)
    turtle.lt(90)
    turtle.fd(x/2)
    turtle.rt(90)

proc nextLayer(turtle: Turtle, size1, size2: float) =
    turtle.pu()
    turtle.setheading(270)
    turtle.fd(size1/2 + size2/2)

proc layerCake(turtle: Turtle) =
    let square_size = 4
    let num_squares = 6
    turtle.pu()

    for i in 1..num_squares:
        let size_i = square_size.float*i.float
        if i == 1:
            turtle.nextLayer(size_i, 0.0)
        else:
            turtle.nextLayer(size_i, square_size.float*(i-1).float)
        turtle.dsfc(size_i)
    turtle.pu()
    turtle.fd((square_size*num_squares)/2)
    turtle.rt(90)
    turtle.fd((square_size*num_squares)/2)
    turtle.rt(180)

let bob = newTurtle()
bob.pd()
bob.setSpeed(50)

let larry = newTurtle()
larry.setSpeed(100)
larry.pd()

bob.lt(90)
larry.lt(60)
bob.fd(20)

bob.lt(90)
bob.fd(20)

#let dist = parseFloat(readLineFromStdin "Input a distance: ")
#larry.fd(dist)

bob.lt(90)
bob.fd(20)

bob.lt(90)
bob.fd(20)

bob.lt(45)
larry.fd(20)
bob.fd(30)

bob.lt(30)
bob.fd(10)

bob.lt(90)

turtle.setSkipAnimation(true)
for i in 0..360:
    bob.lt(1)
    bob.fd(1)

turtle.setSkipAnimation(false)
bob.fd(20)

let h = if 3 == 3: true else: false

larry.setSpeed(5)
larry.layerCake()

turtle.finished()