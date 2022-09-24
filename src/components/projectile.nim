import natu/[math, graphics, video, oam, utils, mgba]
import ../utils/[objs]

type
  ProjectileKind* = enum
    pkBulletPlayer
    pkBulletEnemy
    pkEnemy
    pkModifier
  ProjectileStatus* = enum
    Uninitialised
    Active
    Finished
  # ModifierKind = enum
  #   mkNumber
  #   mkOperator
  Projectile* = object
    # fields that all have in common
    status*: ProjectileStatus
    graphic*: Graphic
    tileId*, palId*: int

    # index*: int
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

proc `=destroy`(projectile: var Projectile) =
  if projectile.status == Active:
    projectile.status = Finished
    freeObjTiles(projectile.tileId)
    releaseObjPal(projectile.graphic)


# TODO(Kal): Have one initProjectile procedure?
proc initBulletPlayerProjectile*(gfx: Graphic): Projectile =
  result = Projectile(
    kind: pkBulletPlayer,
    graphic: gfx,

    tileId: allocObjTiles(gfx),
    palId: acquireObjPal(gfx),
  )
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)

proc initBulletEnemyProjectile*(gfx: Graphic): Projectile =
  result = Projectile(
    kind: pkBulletEnemy,
    graphic: gfx,

    tileId: allocObjTiles(gfx),
    palId: acquireObjPal(gfx),
  )
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)

proc initEnemyProjectile*(): Projectile =
  result = Projectile(
    kind: pkEnemy,
  )

proc initModifierProjectile*(gfx: Graphic, obj: ObjAttr,
    fontIndex: int): Projectile =
  result = Projectile(
    kind: pkModifier,
    graphic: gfx,
    mdFontIndex: fontIndex,
    mdObj: obj,
  )
  result.mdObj.tileId = obj.tileId * result.graphic.frameTiles


# General projectile procedures

proc toRect*(projectile: Projectile): Rect =
  # printf("in projectile.nim proc rect1: x = %l, y = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt())
  result.left = projectile.pos.x.toInt() - projectile.pos.x.toInt() div 2
  result.top = projectile.pos.y.toInt() - projectile.pos.x.toInt() div 2
  result.right = projectile.pos.x.toInt() + projectile.pos.x.toInt() div 2
  result.bottom = projectile.pos.y.toInt() + projectile.pos.x.toInt() div 2
  # printf("in projectile.nim proc rect2: x = %l, y = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt())

# TODO(Kal): Add speed parameter
proc update*(projectile: var Projectile, speed: int = 1) =
  if projectile.status == Active:
  # printf("in projectile.nim 1 (projectile) proc update x = %l, y = %l, angle = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt(), projectile.angle.uint16)

    # make sure the projectiles go where they are supposed to go
    # the *2 is for speed reasons, without it, the projectiles are very slow
    projectile.pos.x = projectile.pos.x - fp(luCos(
        projectile.angle)) * speed
    projectile.pos.y = projectile.pos.y - fp(luSin(
         projectile.angle)) * speed

  # printf("in projectile.nim 2 (projectile) proc update x = %l, y = %l, angle = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt(), projectile.angle.uint16)

    if (not onscreen(projectile.toRect())):
      projectile.status = Finished
  # else:
  # printf("in projectile.nim, update ASSERT!")

proc draw*(projectile: var Projectile) =
  if projectile.status == Active:
  # printf("in projectile.nim 1 (projectile) proc draw x = %l, y = %l, angle = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt(), projectile.angle.uint16)
    withObjAndAff:
      aff.setToRotationInv(projectile.angle.uint16)
      obj.init(
        mode = omAff,
        aff = affId,
        pos = vec2i(projectile.pos) - vec2i(
            projectile.graphic.width div 2,
            projectile.graphic.height div 2),
        tid = projectile.tileId,
        pal = projectile.palId,
        size = projectile.graphic.size
      )
  # printf("in projectile.nim 2 (projectile) proc draw x = %l, y = %l, angle = %l", projectile.pos.x.toInt(), projectile.pos.y.toInt(), projectile.angle.uint16)
  # else:
  # printf("in projectile.nim, draw ASSERT!")

# NOTE(Kal): Resources about AABB
# - https://www.amanotes.com/post/using-swept-aabb-to-detect-and-process-collision
# - https://tutorialedge.net/gamedev/aabb-collision-detection-tutorial/
# - https://developer.mozilla.org/en-US/docs/Games/Techniques/2D_collision_detection#circle_collision
proc isCollidingAABB*(projectileA: Rect, projectileB: Rect): bool =
  let left = projectileB.x - (projectileA.x + projectileA.width)
  let top = (projectileB.y + projectileB.height) - projectileA.y
  let right = (projectileB.x + projectileB.width) -
      projectileA.x
  let bottom = projectileB.y - (projectileA.y +
      projectileA.height)

  # inverting conditions to check faster
  return not (left > 0 or right < 0 or top < 0 or bottom > 0)


# Modifier specific procedures

# TODO(Kal): Add the `$` sprite to the left of the number modifier projectile
proc drawModifier*(modifier: var Projectile) =
  if modifier.status == Active:
  # printf("in projectile.nim 1 (modifier) proc draw x = %l, y = %l, angle = %l", modifier.pos.x.toInt(), modifier.pos.y.toInt(), modifier.angle.uint16)
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
  # else:
  # printf("in projectile.nim, drawModifier ASSERT!")

  # printf("Projectile Palette: %d", modifier.mdObj.pal)
# printf("in projectile.nim 2 (modifier) proc draw x = %l, y = %l, angle = %l", modifier.pos.x.toInt(), modifier.pos.y.toInt(), modifier.angle.uint16)
  # printf("in projectile.nim 3 (obj) proc draw x = %l, y = %l", obj.pos.x, obj.pos.y)
