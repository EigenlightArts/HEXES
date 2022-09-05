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
    finished*: bool
    tileId*, palId*: int
    graphic*: Graphic

    index*: int
    pos*: Vec2f
    angle*: Angle

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

proc initModifierProjectile*(gfx: Graphic, obj: ObjAttr,
    fontIndex: int): Projectile =
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
  result.left = projectile.pos.x.toInt() - projectile.pos.x.toInt() div 2
  result.top = projectile.pos.y.toInt() - projectile.pos.x.toInt() div 2
  result.right = projectile.pos.x.toInt() + projectile.pos.x.toInt() div 2
  result.bottom = projectile.pos.y.toInt() + projectile.pos.x.toInt() div 2
  # printf("in projectile.nim proc rect2: x = %l, y = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt())

proc update*(projectile: var Projectile) =

  # make sure the projectiles go where they are supposed to go
  # the *2 is for speed reasons, without it, the projectiles are very slow
  projectile.pos.x = projectile.pos.x - fp(luCos(
      projectile.angle)) * 2
  projectile.pos.y = projectile.pos.y - fp(luSin(
       projectile.angle)) * 2

  if (not onscreen(projectile.rect())):
    projectile.finished = true

proc draw*(projectile: var Projectile) =
  # if not projectile.finished:
  withObjAndAff:
    aff.setToRotationInv(projectile.angle.uint16)
    obj.init(
      mode = omAff,
      aff = affId,
      pos = vec2i(projectile.pos) - vec2i(
          projectile.graphic.width div 2,
          projectile.graphic.height div 2),
      tid = projectile.tileId + (projectile.index),
      pal = projectile.palId,
      size = projectile.graphic.size
    )

# NOTE(Kal): Resources about AABB
# - https://www.amanotes.com/post/using-swept-aabb-to-detect-and-process-collision
# - https://tutorialedge.net/gamedev/aabb-collision-detection-tutorial/
# - https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection#circle_collision
proc isCollidingAABB(projectileA: Projectile, projectileB: Projectile): bool =
  var left = projectileB.pos.x - (projectileA.pos.x + projectileA.graphic.width)
  var top = (projectileB.pos.y + projectileB.graphic.height) - projectileA.pos.y
  var right = (projectileB.pos.x + projectileB.graphic.width) -
      projectileA.pos.x
  var bottom = projectileB.pos.y - (projectileA.pos.y +
      projectileA.graphic.height)

  # inverting conditions to check faster
  return not (left > 0 or right < 0 or top < 0 or bottom > 0)

# Modifier spefific procedures

proc update*(modifier: var Projectile, bulletPlayer: var Projectile) =

  # make sure the modifiers go where they are supposed to go
  # the *2 is for speed reasons, without it, the modifiers are very slow
  modifier.pos.x = modifier.pos.x - fp(luCos(
      modifier.angle))
  modifier.pos.y = modifier.pos.y - fp(luSin(
       modifier.angle))

  # call the generic update procedure
  # if not bulletPlayer.finished:  
  #   bulletPlayer.update()

  if not onscreen(modifier.rect()):
    modifier.finished = true
  elif isCollidingAABB(modifier, bulletPlayer) and not bulletPlayer.finished:
    modifier.finished = true
    bulletPlayer.finished = true
  # printf("proc update modifier 2: %d,%d", modifier.finished, bulletPlayer.finished)

# TODO(Kal): Add the `$` sprite to the left of the number modifier projectile
proc drawMod*(modifier: var Projectile) =
  # printf("in projectile.nim 1 (mdfy) proc draw x = %l, y = %l, angle = %l", modifier.pos.x.toInt(), modifier.pos.y.toInt(), modifier.angle.uint16)
  # if not modifier.finished:
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