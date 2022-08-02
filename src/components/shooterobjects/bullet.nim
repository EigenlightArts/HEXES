import natu/[math, graphics, video, mgba]

type Bullet* = object
  pos*: Vec2f
  angle*: Angle
  index*: int
  finished*: bool

proc rect(b: Bullet): Rect =
  result.left = b.pos.x.toInt() - 5
  result.top = b.pos.y.toInt() - 5
  result.right = b.pos.x.toInt() + 5
  result.bottom = b.pos.y.toInt() + 5

proc update*(bullets: var Bullet) =
  # printf("in bullet.nim proc update x = %l, y = %l", bullets.pos.x.toInt(), bullets.pos.y.toInt())

  # make sure the bullets go where they are supposed to go
  # the *2 is for speed reasons, without it, the bullets are very slow
  bullets.pos.x = bullets.pos.x - fp(luCos(
      bullets.angle)) * 2
  bullets.pos.y = bullets.pos.y - fp(luSin(
       bullets.angle)) * 2
  # dec bullets.showTimer
  # if bullets.showTimer <= 0:
  #   dec bullets.fadeTimer
  #   if bullets.fadeTimer <= 0:
  if (not onscreen(bullets.rect())):
    bullets.finished = true
