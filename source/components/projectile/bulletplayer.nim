import natu/[math, graphics, video, oam, utils]
import utils/[objs, body]
import components/shared

type BulletPlayer* = object
  status*: ProjectileStatus
  graphic*: Graphic
  tileId*, palId*: int
  angle*: Angle
  body*: Body

  bpDamage*: int

proc `=destroy`*(bp: var BulletPlayer) =
  if bp.status != Uninitialised:
    bp.status = Uninitialised
    freeObjTiles(bp.tileId)
    releaseObjPal(bp.graphic)

proc `=copy`*(a: var BulletPlayer; b: BulletPlayer) {.error: "Not supported".}

var bulletPlayerEntitiesInstances*: List[5, BulletPlayer]


proc initProjectileBulletPlayer*(gfx: Graphic; pos: Vec2f): BulletPlayer =
  result = BulletPlayer(
    graphic: gfx,
    tileId: allocObjTiles(gfx),
    palId: acquireObjPal(gfx),
    body: initBody(pos, 10, 6)
  )
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)

proc update*(bp: var BulletPlayer; speed: int = 2) =
  if bp.status == Active:
    # make sure the bp players go where they are supposed to go
    bp.body.pos.x = bp.body.pos.x - fp(luCos(
        bp.angle)) * speed
    bp.body.pos.y = bp.body.pos.y - fp(luSin(
         bp.angle)) * speed

    if (not onscreen(bp.body.hitbox())):
      bp.status = Finished

proc draw*(bp: var BulletPlayer) =
  if bp.status == Active:
    withObjAndAff:
      aff.setToRotationInv(bp.angle.uint16)
      obj.init(
        mode = omAff,
        aff = affId,
        pos = vec2i(bp.body.pos) - vec2i(
            bp.graphic.width div 2,
            bp.graphic.height div 2),
        tid = bp.tileId,
        pal = bp.palId,
        size = bp.graphic.size
      )

proc fireBulletPlayer*(bp: sink BulletPlayer; angle: Angle = 0) =

  bp.angle = angle
  bp.status = Active

  if not bulletPlayerEntitiesInstances.isFull:
    bulletPlayerEntitiesInstances.add(bp)
