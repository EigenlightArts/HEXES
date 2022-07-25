import natu/[math, graphics, video, mgba]
import ../utils/objs

type Bullet = object
  pos: Vec2f
  angle: Angle
  index: int
  finished: bool
  showTimer: int
  fadeTimer: int
  fadeTimerMax: int

type Shooter* = object
  bullets: seq[Bullet]
  bulletsLimit: int
  bulletsTileId: int
  bulletsPalId: int

proc initShooter*(limit = 5): Shooter =
  result.bulletsTileId = allocObjTiles(gfxBulletTemp)
  copyFrame(addr objTileMem[result.bulletsTileId], gfxBulletTemp, 0)
  result.bulletsPalId = acquireObjPal(gfxBulletTemp)
  result.bulletsLimit = limit
  result.bullets.setLen(0)

proc destroy*(self: var Shooter) =
  freeObjTiles(self.bulletsTileId)
  releaseObjPal(gfxBulletTemp)

proc update(bullets: var Bullet) =
  printf("in bullet.nim proc update x = %l, y = %l", bullets.pos.x.toInt(), bullets.pos.y.toInt())
  bullets.pos.x = bullets.pos.x - fp(luCos(
      bullets.angle))
  bullets.pos.y = bullets.pos.y - fp(luSin(
       bullets.angle))
  dec bullets.showTimer
  if bullets.showTimer <= 0:
    dec bullets.fadeTimer
    if bullets.fadeTimer <= 0: bullets.finished = true

proc draw(bullets: Bullet, shooter: Shooter) =
  withObjAndAff:
    # aff.setToScaleInv(fp 1, (fp bullets.fadeTimer / bullets.fadeTimerMax).clamp(fp 0, fp 1))
    obj.init(
      mode = omAff,
      aff = affId,
      pos = vec2i(bullets.pos) - vec2i(gfxBulletTemp.width div 2, gfxBulletTemp.height div 2),
      tid = shooter.bulletsTileId + (bullets.index),
      pal = shooter.bulletsPalId,
      size = gfxBulletTemp.size
    )
  printf("in bullet.nim proc draw: x = %l, y = %l", bullets.pos.x.toInt(), bullets.pos.y.toInt())
  

proc fireBullet*(self: var Shooter, pos: Vec2f = vec2f(0, 0), index = 0,
    angle: Angle = 0, showTimer = 25, fadeTimer = 10) =

  var bullets: Bullet
  var bulletsFired: int

  bullets.index = index
  bullets.pos = pos
  bullets.angle = angle
  bullets.showTimer = showTimer
  bullets.fadeTimer = fadeTimer
  bullets.fadeTimerMax = fadeTimer
  bullets.finished = false

  if bulletsFired <= self.bulletsLimit:
    printf("in bullet.nim proc fireBullet: x = %l, y = %l", bullets.pos.x.toInt(), bullets.pos.y.toInt())
    self.bullets.insert(bullets)
    bulletsFired += 1
  # TODO(Kal): else play sfx


proc update*(self: var Shooter) =
  var i = 0

  while i < self.bullets.len:
    self.bullets[i].update()
    if self.bullets[i].finished:
      self.bullets.delete(i)
    else:
      inc i


proc draw*(self: Shooter) =
  for bullets in self.bullets:
    bullets.draw(self)
