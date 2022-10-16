import natu/[math, graphics, video, oam, utils, mgba]
import utils/[objs, body]
import components/shared

type
  SpeedKind* = enum
    skNone
    skSlow
    skMedium
    skFast
  EnemyKind* = enum
    ekNone
    ekTriangle
    ekSquare
    ekLozenge
    ekCircle
  Enemy* = object
    status*: ProjectileStatus
    graphic*: Graphic
    tileId*, palId*: int
    angle*: Angle
    body*: Body

    score*: int
    health*: int
    speed*: SpeedKind

    case kind*: EnemyKind
    of ekNone, ekSquare, ekCircle:
      nil
    of ekTriangle:
      flipDone*: bool
      flipTimer*: int
    of ekLozenge:
      shootEnable*: bool
      shootTimer*: int


proc `=destroy`*(enemy: var Enemy) =
  if enemy.status != Uninitialised:
    enemy.status = Uninitialised
    freeObjTiles(enemy.tileId)
    releaseObjPal(enemy.graphic)

proc `=copy`*(a: var Enemy; b: Enemy) {.error: "Not supported".}

var enemyEntitiesInstances*: List[3, Enemy]


proc initEnemy*(gfx: Graphic; enemySelect: int; enemySpeed: int;
    pos: Vec2f): Enemy =
  result = Enemy(
    graphic: gfx,
    tileId: allocObjTiles(gfx),
    palId: acquireObjPal(gfx),
    body: initBody(pos, 12, 12),
    speed: SpeedKind(enemySpeed),
    kind: EnemyKind(enemySelect)
  )
  if result.kind == ekTriangle:
    result.flipTimer = rand(30..55)
  if result.kind == ekLozenge:
    result.shootTimer = rand(25..40)

  copyFrame(addr objTileMem[result.tileId], result.graphic, 0)

proc update*(enemy: var Enemy) =
  if enemy.status == Active:
    let speed = case enemy.speed:
      of skNone:
        fp(0)
      of skSlow:
        fp(0.5)
      of skMedium:
        fp(1)
      of skFast:
        fp(2)

    # make sure the enemy players go where they are supposed to go
    enemy.body.pos.x = enemy.body.pos.x - fp(luCos(
        enemy.angle)) * speed
    enemy.body.pos.y = enemy.body.pos.y - fp(luSin(
         enemy.angle)) * speed

    # if enemy.kind == ekTriangle:
    #   dec enemy.flipTimer
    #   # TODO(Kal): Put in code to flip object to other side
    #   if enemy.flipTimer <= 0:
    #     # MP = pv - (pv - P)
    #     let pivot = vec2f(ScreenWidth div 2, ScreenHeight div 2)
    #     let diff = pivot - enemy.body.pos
    #     enemy.body.pos = pivot - diff
    # if enemy.kind == ekLozenge:
    #   dec enemy.shootTimer
    #   # TODO(Kal): Put in code to shoot bulletEnemies
    #   # if enemy.shootTimer <= 0:

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

