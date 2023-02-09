import natu/[math, graphics, video, oam, utils]
import utils/[objs, body, sprites, camera]
import components/shared

type BulletEnemy* = object
  status*: ProjectileStatus
  sprite*: Sprite
  angle*: Angle
  body*: Body

  beDamage*: int

proc `=destroy`*(be: var BulletEnemy) =
  if be.status != Uninitialised:
    be.status = Uninitialised
    freeObjTiles(be.sprite.tid)
    releaseObjPal(be.sprite.graphic)

proc `=copy`*(a: var BulletEnemy; b: BulletEnemy) {.error: "Not supported".}

var bulletEnemyEntitiesInstances*: List[3, BulletEnemy]

proc initProjectileBulletEnemy*(gfx: Graphic; pos: Vec2f): BulletEnemy =
  result = BulletEnemy(
    sprite: initSprite(gfx, vec2i(pos)),
    body: initBody(pos, 8, 2),
  )
  copyFrame(addr objTileMem[result.sprite.tid], result.sprite.graphic, 0)

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
        pos = vec2i(be.body.pos) - cameraOffset - vec2i(
            be.sprite.graphic.width div 2,
            be.sprite.graphic.height div 2),
        tid = be.sprite.tid,
        pal = be.sprite.pal,
        size = be.sprite.graphic.size
      )

proc fireBulletEnemy*(be: sink BulletEnemy; pos: Vec2f = vec2f(0,
    0); angle: Angle = 0) =

  be.body.pos = pos
  be.angle = angle
  be.status = Active

  if not bulletEnemyEntitiesInstances.isFull:
    bulletEnemyEntitiesInstances.add(be)
