import natu/[math, graphics, video, oam, utils, mgba]
import ../../utils/[objs]
import ../shared

type BulletPlayer* = object
  status*: ProjectileStatus
  graphic*: Graphic
  tileId*, palId*: int
  pos*: Vec2f
  angle*: Angle
  
  bpDamage*: int

proc `=destroy`*(bp: var BulletPlayer) =
  if bp.status != Uninitialised:
    bp.status = Uninitialised
    freeObjTiles(bp.tileId)
    releaseObjPal(bp.graphic)

proc `=copy`*(a: var BulletPlayer; b: BulletPlayer) {.error: "Not supported".}

var bulletPlayerEntitiesInstances*: List[5, BulletPlayer]


proc initProjectileBulletPlayer*(gfx: Graphic): BulletPlayer =
  result = BulletPlayer(
    graphic: gfx,
    tileId: allocObjTiles(gfx),
    palId: acquireObjPal(gfx),
  )
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)

proc toRect*(bp: BulletPlayer): Rect =
  result.left = bp.pos.x.toInt() - bp.pos.x.toInt() div 2
  result.top = bp.pos.y.toInt() - bp.pos.x.toInt() div 2
  result.right = bp.pos.x.toInt() + bp.pos.x.toInt() div 2
  result.bottom = bp.pos.y.toInt() + bp.pos.x.toInt() div 2

proc update*(bp: var BulletPlayer; speed: int = 1) =
  if bp.status == Active:
    # make sure the bp players go where they are supposed to go
    bp.pos.x = bp.pos.x - fp(luCos(
        bp.angle)) * speed
    bp.pos.y = bp.pos.y - fp(luSin(
         bp.angle)) * speed

    if (not onscreen(bp.toRect())):
      bp.status = Finished

proc draw*(bp: var BulletPlayer) =
  if bp.status == Active:
    withObjAndAff:
      aff.setToRotationInv(bp.angle.uint16)
      obj.init(
        mode = omAff,
        aff = affId,
        pos = vec2i(bp.pos) - vec2i(
            bp.graphic.width div 2,
            bp.graphic.height div 2),
        tid = bp.tileId,
        pal = bp.palId,
        size = bp.graphic.size
      )

proc fireBulletPlayer*(bp: sink BulletPlayer; pos: Vec2f = vec2f(0,
    0); angle: Angle = 0) =

  bp.pos = pos
  bp.angle = angle
  bp.status = Active

  if not bulletPlayerEntitiesInstances.isFull:
    bulletPlayerEntitiesInstances.add(bp)