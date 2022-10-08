import natu/[math, graphics, video, oam, utils, mgba]
import utils/[objs, body]
import components/shared

# FIXME(Kal): Actually implement this lol

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


#[
proc initProjectileEnemy*(): Projectile =
  result = Projectile(
  ,
  )

proc fireEnemy*(enemy: sink Enemy; pos: Vec2f = vec2f(0,
  0); angle: Angle = 0) =

  enemy.pos = pos
  enemy.angle = angle
  enemy.status = Active

  if not enemyEntitiesInstances.isFull:
  enemyEntitiesInstances.add(enemy)
]#
