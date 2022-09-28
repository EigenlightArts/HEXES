import natu/[math, graphics, video, oam, utils, mgba]
import ../../utils/[objs]
import ../shared

type BulletEnemy* = object
  status*: ProjectileStatus
  graphic*: Graphic
  tileId*, palId*: int
  pos*: Vec2f
  angle*: Angle

  beDamage*: int

proc `=destroy`*(be: var BulletEnemy) =
  if be.status != Uninitialised:
    be.status = Uninitialised
    freeObjTiles(be.tileId)
    releaseObjPal(be.graphic)

proc `=copy`*(a: var BulletEnemy; b: BulletEnemy) {.error: "Not supported".}

var bulletEnemyEntitiesInstances*: List[3, BulletEnemy]

proc initProjectileBulletEnemy*(gfx: Graphic): BulletEnemy =
  result = BulletEnemy(
    graphic: gfx,
    tileId: allocObjTiles(gfx),
    palId: acquireObjPal(gfx),
  )
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)

proc toRect*(be: BulletEnemy): Rect =
  result.left = be.pos.x.toInt() - be.pos.x.toInt() div 2
  result.top = be.pos.y.toInt() - be.pos.x.toInt() div 2
  result.right = be.pos.x.toInt() + be.pos.x.toInt() div 2
  result.bottom = be.pos.y.toInt() + be.pos.x.toInt() div 2

proc update*(be: var BulletEnemy; speed: int = 1) =
  if be.status == Active:
    # make sure the bullet enemies go where they are supposed to go
    be.pos.x = be.pos.x - fp(luCos(
        be.angle)) * speed
    be.pos.y = be.pos.y - fp(luSin(
         be.angle)) * speed

    if (not onscreen(be.toRect())):
      be.status = Finished

proc draw*(be: var BulletEnemy) =
  if be.status == Active:
    withObjAndAff:
      aff.setToRotationInv(be.angle.uint16)
      obj.init(
        mode = omAff,
        aff = affId,
        pos = vec2i(be.pos) - vec2i(
            be.graphic.width div 2,
            be.graphic.height div 2),
        tid = be.tileId,
        pal = be.palId,
        size = be.graphic.size
      )

proc fireBulletEnemy*(be: sink BulletEnemy; pos: Vec2f = vec2f(0,
    0); angle: Angle = 0) =

  be.pos = pos
  be.angle = angle
  be.status = Active

  if not bulletEnemyEntitiesInstances.isFull:
    bulletEnemyEntitiesInstances.add(be)