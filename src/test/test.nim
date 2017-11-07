import ../turtle

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

proc next_layer(turtle: Turtle, size1, size2: float) =
    turtle.pu()
    turtle.setheading(270)
    turtle.fd(size1/2 + size2/2)

proc layer_cake(turtle: Turtle) =
    let square_size = 4
    let num_squares = 6
    turtle.pu()

    for i in 1..num_squares:
        let size_i = square_size.float*i.float
        if i == 1:
            turtle.next_layer(size_i, 0.0)
        else:
            turtle.next_layer(size_i, square_size.float*(i-1).float)
        turtle.dsfc(size_i)
    turtle.pu()
    turtle.fd((square_size*num_squares)/2)
    turtle.rt(90)
    turtle.fd((square_size*num_squares)/2)
    turtle.rt(180)

let bob = newTurtle()
#bob.layer_cake()

bob.fd(20)
bob.lt(90)
bob.fd(20)

let fred = newTurtle()
fred.lt(45)
fred.fd(28.2842712475)

fred.pu()
fred.fd(200)
bob.pu()
bob.fd(200)

#[bob.pd()
bob.setcolor(255, 0, 0)
bob.fd(40)

bob.lt(90)
bob.setcolor(255, 255, 255)
bob.fd(20)

bob.lt(90)
bob.setcolor(0, 255, 0)
bob.fd(40)

bob.lt(90)
bob.setcolor(0, 0, 0)


bob.rt(45)
bob.fd(20)

bob.lt(90)
bob.fd(20)]#

#bob.setcolor(124, 124, 124)
#bob.setpos(-20, 40)

turtle.mainloop()