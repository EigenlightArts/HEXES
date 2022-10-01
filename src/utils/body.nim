import natu/[math, video, oam]

type Body* {.bycopy.} = object
  ## Combination of position + size
  ## Used for collisions and movement.
  pos*: Vec2f
  size*: Vec2i

{.push inline.}

proc x*(body: Body): Fixed =            body.pos.x
proc x*(body: var Body): var Fixed =    body.pos.x
proc `x=`*(body: var Body, x: Fixed) =  body.pos.x = x

proc y*(body: Body): Fixed =            body.pos.y
proc y*(body: var Body): var Fixed =    body.pos.y
proc `y=`*(body: var Body, y: Fixed) =  body.pos.y = y

proc w*(body: Body): int =            body.size.x
proc w*(body: var Body): var int =    body.size.x
proc `w=`*(body: var Body, w: int) =  body.size.x = w

proc h*(body: Body): int =            body.size.y
proc h*(body: var Body): var int =    body.size.y
proc `h=`*(body: var Body, h: int) =  body.size.y = h

proc initBody*(x, y: Fixed, w, h: int): Body {.inline, noinit.} =
  result.x = x
  result.y = y
  result.w = w
  result.h = h

proc initBody*(x, y, w, h: int): Body {.noinit.} =
  initBody(fp(x), fp(y), w, h)

proc initBody*(pos: Vec2f, w, h: int): Body {.noinit.} =
  initBody(pos.x, pos.y, w, h)

proc hitbox*(b: Body): Rect {.noinit.} =
  result.x = flr(b.x)
  result.y = flr(b.y)
  result.width = b.w
  result.height = b.h

proc hitbox*(b: Body, offset: Vec2i): Rect {.noinit.} =
  result.x = flr(b.x + fp(offset.x))
  result.y = flr(b.y + fp(offset.y))
  result.width = b.w
  result.height = b.h

proc center*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + Fixed(b.w shl 7)
  result.y = b.y + Fixed(b.h shl 7)

proc topLeft*(b: Body): Vec2f {.noinit.} =
  result.x = b.x
  result.y = b.y
proc topRight*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + fp(b.w)
  result.y = b.y
proc bottomLeft*(b: Body): Vec2f {.noinit.} =
  result.x = b.x
  result.y = b.y + fp(b.h)
proc bottomRight*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + fp(b.w)
  result.y = b.y + fp(b.h)

proc centerLeft*(b: Body): Vec2f {.noinit.} =
  result.x = b.x
  result.y = b.y + Fixed(b.h shl 7)
proc centerRight*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + fp(b.w)
  result.y = b.y + Fixed(b.h shl 7)
proc centerTop*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + Fixed(b.w shl 7)
  result.y = b.y
proc centerBottom*(b: Body): Vec2f {.noinit.} =
  result.x = b.x + Fixed(b.w shl 7)
  result.y = b.y + fp(b.h)

proc left*(b: Body): Fixed = b.x
proc right*(b: Body): Fixed = b.x + b.w
proc top*(b: Body): Fixed = b.y
proc bottom*(b: Body): Fixed = b.y + b.h

proc centerX*(b: Body): Fixed = b.x + Fixed(b.w shl 7)
proc centerY*(b: Body): Fixed = b.y + Fixed(b.h shl 7)

proc translate*(b: var Body, v: Vec2f|Vec2i) =
  b.x += v.x
  b.y += v.y
proc translate*(b: var Body, x: Fixed|int, y: Fixed|int) =
  b.x += x
  b.y += y
proc resize*(b: var Body, v: Vec2i) =
  b.w = v.x
  b.h = v.y
proc resize*(b: var Body, w, h: int) =
  b.w = w
  b.h = h

proc collide*(b1, b2: Body): bool =
  let l1 = b1.x
  let u1 = b1.y
  let r1 = l1 + fp(b1.w)
  let d1 = u1 + fp(b1.h)
  let l2 = b2.x
  let u2 = b2.y
  let r2 = l2 + fp(b2.w)
  let d2 = u2 + fp(b2.h)
  r1 > l2 and l1 < r2 and d1 > u2 and u1 < d2

proc collide*(a, b: Rect): bool =
  a.right > b.left and a.left < b.right and a.bottom > b.top and a.top < b.bottom

proc contains*(r: Rect, p: Vec2i): bool =
  p.x >= r.left and p.x < r.right and p.y >= r.top and p.y < r.bottom

proc contains*(b: Body, p: Vec2f): bool =
  p.x >= b.x and p.y >= b.y and p.x < (b.x + b.w.fp) and p.y < (b.y + b.h.fp)

{.pop.} # inline