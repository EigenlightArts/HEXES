import natu/[math, graphics, video, oam, utils, mgba]
import utils/[objs, body]
import components/shared

# FIXME(Kal): Actually implement this lol
# TODO(Kal): Add enemy kinds
type Enemy* = object
  status*: ProjectileStatus
  graphic*: Graphic
  tileId*, palId*: int
  angle*: Angle
  body*: Body

  enemyHealth*: int
  enemyShooter*: bool

proc `=destroy`*(enemy: var Enemy) =
  if enemy.status != Uninitialised:
    enemy.status = Uninitialised
    freeObjTiles(enemy.tileId)
    releaseObjPal(enemy.graphic)

proc `=copy`*(a: var Enemy; b: Enemy) {.error: "Not supported".}

var enemyEntitiesInstances*: List[3, Enemy]


proc initEnemy*(gfx: Graphic; pos: Vec2f): Enemy =
  result = Enemy(
    graphic: gfx,
    tileId: allocObjTiles(gfx),
    palId: acquireObjPal(gfx),
    body: initBody(pos, 12, 12)
  )
  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)

proc update*(enemy: var Enemy; speed: int = 1) =
  if enemy.status == Active:
    # make sure the enemy players go where they are supposed to go
    enemy.body.pos.x = enemy.body.pos.x - fp(luCos(
        enemy.angle)) * speed
    enemy.body.pos.y = enemy.body.pos.y - fp(luSin(
         enemy.angle)) * speed

    if (not onscreen(enemy.body.hitbox())):
      enemy.status = Finished

proc draw*(enemy: var Enemy) =
  if enemy.status == Active:
    withObjAndAff:
      aff.setToRotationInv(enemy.angle.uint16)
      obj.init(
        mode = omAff,
        aff = affId,
        pos = vec2i(enemy.body.pos) - vec2i(
            enemy.graphic.width div 2,
            enemy.graphic.height div 2),
        tid = enemy.tileId,
        pal = enemy.palId,
        size = enemy.graphic.size
      )

proc fireEnemy*(enemy: sink Enemy; angle: Angle = 0) =

  enemy.angle = angle
  enemy.status = Active

  if not enemyEntitiesInstances.isFull:
    enemyEntitiesInstances.add(enemy)

