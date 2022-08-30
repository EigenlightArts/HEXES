import natu/[math, graphics, video, oam, utils, mgba]
import ../utils/[objs]

type
  ProjectileKind* = enum
    pkBulletPlayer
    pkBulletEnemy
    pkEnemy
    pkModifier
  # ModifierKind = enum
  #   mkNumber
  #   mkOperator
  Projectile* = object
    # fields that all have in common
    graphic*: Graphic
    tileId*: int
    palId*: int

    pos*: Vec2f
    angle*: Angle
    index*: int
    finished*: bool

    case kind*: ProjectileKind
    of pkBulletPlayer, pkBulletEnemy:
      # fields that only bullets have
      blDamage*: int
    of pkEnemy:
      # fields that only enemies have
      emHealth*: int
      emShooter*: bool
    of pkModifier:
      # fields that only modifiers have
      mdFontIndex: int
      mdObj: ObjAttr

var bulletPlayerEntitiesInstances*: List[5, Projectile]
var bulletEnemyEntitiesInstances*: List[3, Projectile]
var enemyEntitiesInstances*: List[5, Projectile]
var modiferEntitiesInstances*: List[3, Projectile]

# TODO(Kal): Have one initProjectile procedure?
proc initBulletPlayerProjectile*(gfx: Graphic): Projectile =
  result.kind = pkBulletPlayer
  result.graphic = gfx

  result.tileId = allocObjTiles(result.graphic)
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)
  
  result.palId = acquireObjPal(result.graphic)

proc initBulletEnemyProjectile*(gfx: Graphic): Projectile =
  result.kind = pkBulletEnemy
  result.graphic = gfx

  result.tileId = allocObjTiles(result.graphic)
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)
  
  result.palId = acquireObjPal(result.graphic)

proc initEnemyProjectile*(): Projectile =
  result.kind = pkEnemy

proc initModifierProjectile*(gfx: Graphic, obj: ObjAttr, fontIndex: int): Projectile =
  result.kind = pkModifier
  result.graphic = gfx
  result.mdFontIndex = fontIndex
  result.mdObj = obj
  result.mdObj.tileId = obj.tileId * result.graphic.frameTiles

  # result.tileId = result.mdObj.tileId  
  # result.palId = result.mdObj.palId

# General projectile procedures

proc rect(projectile: Projectile): Rect =
  # printf("in projectile.nim proc rect1: x = %l, y = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt())
  result.left = projectile.pos.x.toInt() - 5
  result.top = projectile.pos.y.toInt() - 5
  result.right = projectile.pos.x.toInt() + 5
  result.bottom = projectile.pos.y.toInt() + 5
  # printf("in projectile.nim proc rect2: x = %l, y = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt())

proc update*(projectile: var Projectile) =

  # printf("POS 1: %d,%d", projectile.pos.x.toInt(), projectile.pos.y.toInt())

  # make sure the projectiles go where they are supposed to go
  # the *2 is for speed reasons, without it, the projectiles are very slow
  projectile.pos.x = projectile.pos.x - fp(luCos(
      projectile.angle)) * 2
  projectile.pos.y = projectile.pos.y - fp(luSin(
       projectile.angle)) * 2

  # printf("POS 2: %d,%d", projectile.pos.x.toInt(), projectile.pos.y.toInt())

  if (not onscreen(projectile.rect())):
    projectile.finished = true


# Modifier spefific procedures

# TODO(Kal): Add the `$` sprite to the left of the number modifier projectile
proc draw*(modifier: var Projectile) =
  # printf("in projectile.nim 1 (mdfy) proc draw x = %l, y = %l, angle = %l", modifier.pos.x.toInt(), modifier.pos.y.toInt(), modifier.angle.uint16)
  if not modifier.finished:
    withObjAndAff:
      aff.setToRotationInv(modifier.angle.uint16)
      obj.init(
        mode = omAff,
        aff = affId,
        pos = vec2i(modifier.pos) - vec2i(
            modifier.graphic.width div 2, modifier.graphic.height div 2),
        tid = modifier.mdObj.tid + (modifier.mdFontIndex *
            4),
        pal = modifier.mdObj.palId,
        size = modifier.graphic.size
      )
    # printf("Projectile Palette: %d", modifier.mdObj.pal)
    # printf("in projectile.nim 2 (mdfy) proc draw x = %l, y = %l, angle = %l", modifier.pos.x.toInt(), modifier.pos.y.toInt(), modifier.angle.uint16)
    # printf("in projectile.nim 3 (obj) proc draw x = %l, y = %l", obj.pos.x, obj.pos.y)
