import natu/[math, graphics, video, oam, utils, mgba]
import utils/[objs, body]
import components/shared

type BulletEnemy* = object
  status*: ProjectileStatus
  graphic*: Graphic
  tileId*, palId*: int
  angle*: Angle
  body*: Body

  beDamage*: int

proc `=destroy`*(be: var BulletEnemy) =
  if be.status != Uninitialised:
    be.status = Uninitialised
    freeObjTiles(be.tileId)
    releaseObjPal(be.graphic)

proc `=copy`*(a: var BulletEnemy; b: BulletEnemy) {.error: "Not supported".}

var bulletEnemyEntitiesInstances*: List[3, BulletEnemy]

proc initProjectileBulletEnemy*(gfx: Graphic; pos: Vec2f): BulletEnemy =
  result = BulletEnemy(
    graphic: gfx,
    tileId: allocObjTiles(gfx),
    palId: acquireObjPal(gfx),
    body: initBody(pos, 8, 2),
  )
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)

proc update*(be: var BulletEnemy; speed: int = 2) =
  if be.status == Active:
    # make sure the bullet enemies go where they are supposed to go
    be.body.pos.x = be.body.pos.x - fp(luCos(
        be.angle)) * speed
    be.body.pos.y = be.body.pos.y - fp(luSin(
         be.angle)) * speed

    if (not onscreen(be.body.hitbox())):
      be.status = Finished

proc draw*(be: var BulletEnemy) =
  if be.status == Active:
    withObjAndAff:
      aff.setToRotationInv(be.angle.uint16)
      obj.init(
        mode = omAff,
        aff = affId,
        pos = vec2i(be.body.pos) - vec2i(
            be.graphic.width div 2,
            be.graphic.height div 2),
        tid = be.tileId,
        pal = be.palId,
        size = be.graphic.size
      )

proc fireBulletEnemy*(be: sink BulletEnemy; pos: Vec2f = vec2f(0,
    0); angle: Angle = 0) =

  be.body.pos = pos
  be.angle = angle
  be.status = Active

  if not bulletEnemyEntitiesInstances.isFull:
    bulletEnemyEntitiesInstances.add(be)
