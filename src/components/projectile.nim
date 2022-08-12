import natu/[math, graphics, video, oam, utils, mgba]
import ../utils/[objs, labels]

type
  ProjectileKind* = enum
    pkBulletPlayer
    pkBulletEnemy
    pkEnemy
    pkModifier
  Projectile* = object
    # fields that all have in common
    pos*: Vec2f
    angle*: Angle
    index*: int
    finished*: bool

    case kind*: ProjectileKind
    of pkBulletPlayer, pkBulletEnemy:
      # fields that only bullets have
      damage*: int
    of pkEnemy:
      # fields that only enemies have
      health*: int
      doesItShoot*: bool
    of pkModifier:
      # fields that only modifiers have
      # modifier: Modifier
      modLabel*: Label
      modType*: string

var bulletPlayerEntitiesInstances*: List[5, Projectile]
var bulletEnemyEntitiesInstances*: List[3, Projectile]
var enemyEntitiesInstances*: List[5, Projectile]
var modiferEntitiesInstances*: List[3, Projectile]

proc initBulletPlayerProjectile*(): Projectile =
  result.kind = pkBulletPlayer

proc initBulletEnemyProjectile*(): Projectile =
  result.kind = pkBulletEnemy

proc initEnemyProjectile*(): Projectile =
  result.kind = pkEnemy

proc initModifierProjectile*(gfxText: Graphic = gfxShipTemp, pos: Vec2i, text: cstring): Projectile =
  result.kind = pkModifier

  result.modLabel.init(pos, s8x16, count = 22)
  result.modLabel.obj.pal = getPalId(gfxText)
  result.modLabel.ink = 1 # set the ink colour index to use from the palette
  result.modLabel.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)
  result.modLabel.put(text)
  
# Bullet spefific procedures

proc rect(bullet: Projectile): Rect =
  # printf("in projectile.nim proc rect1: x = %l, y = %l", bullet.pos.x.toInt(), bullet.pos.y.toInt())
  result.left = bullet.pos.x.toInt() - 5
  result.top = bullet.pos.y.toInt() - 5
  result.right = bullet.pos.x.toInt() + 5
  result.bottom = bullet.pos.y.toInt() + 5
  # printf("in projectile.nim proc rect2: x = %l, y = %l", bullet.pos.x.toInt(), bullet.pos.y.toInt())

proc update*(bullet: var Projectile) =

  # make sure the bullets go where they are supposed to go
  # the *2 is for speed reasons, without it, the bullets are very slow
  bullet.pos.x = bullet.pos.x - fp(luCos(
      bullet.angle)) * 2
  bullet.pos.y = bullet.pos.y - fp(luSin(
       bullet.angle)) * 2

  if (not onscreen(bullet.rect())):
    bullet.finished = true
