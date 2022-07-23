import natu/[math, graphics, video]
import ../utils/objs

type Bullet = object
  pos: Vec2i
  index: int
  finished: bool
  showTimer: int
  fadeTimer: int
  fadeTimerMax: int

type Shooter* = object
  bullets: seq[Bullet]
  bulletsTileId: int
  bulletsPalId: int

proc initShooter*(self: var Shooter) =
  self.bulletsTileId = allocObjTiles(gfxBulletTemp)
  copyFrame(addr objTileMem[self.bulletsTileId], gfxBulletTemp, 0)
  self.bulletsPalId = acquireObjPal(gfxBulletTemp)
  self.bullets.setLen(0)

proc destroy*(self: var Shooter) =
  freeObjTiles(self.bulletsTileId)
  releaseObjPal(gfxBulletTemp)

proc update(bullets: var Bullet) =
  dec bullets.showTimer
  if bullets.showTimer <= 0:
    dec bullets.fadeTimer
    if bullets.fadeTimer <= 0: bullets.finished = true

proc draw(bullets: Bullet, shooter: Shooter) =
  withObjAndAff:
    aff.setToScaleInv(fp 1, (fp bullets.fadeTimer / bullets.fadeTimerMax).clamp(fp 0, fp 1))
    obj.init(
      mode = omAff,
      aff = affId,
      pos = bullets.pos,
      tid = shooter.bulletsTileId + (bullets.index),
      pal = shooter.bulletsPalId,
      size = s16x16
    )

proc addBullet*(self: var Shooter, pos: Vec2i = vec2i(0,0), index = 0, showTimer = 25, fadeTimer = 10) = 
  
  var bullets: Bullet
  
  bullets.index = index
  bullets.pos = pos
  bullets.showTimer = showTimer
  bullets.fadeTimer = fadeTimer
  bullets.fadeTimerMax = fadeTimer
  bullets.finished = false
  
  self.bullets.insert(bullets)
  

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


