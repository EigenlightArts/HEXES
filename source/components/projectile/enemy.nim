import natu/[math, graphics, video, oam, utils]
import utils/[objs, body, audio, sprites]
import components/shared
import components/projectile/bulletenemy

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
    sprite*: Sprite
    angle*: Angle
    body*: Body

    timeScore*: int
    health*: int
    speed*: Fixed
    speedKind*: SpeedKind

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
    freeObjTiles(enemy.sprite.tid)
    releaseObjPal(enemy.sprite.graphic)

proc `=copy`*(a: var Enemy; b: Enemy) {.error: "Not supported".}

var enemyEntitiesInstances*: List[3, Enemy]


proc initEnemy*(gfx: Graphic; enemySelect: EnemyKind; enemySpeed: SpeedKind;
    enemyHealth: int; enemyTimeScore: int;pos: Vec2f): Enemy =
  result = Enemy(
    sprite: initSprite(gfx, vec2i(pos)),
    body: initBody(pos, 12, 12),
    kind: enemySelect,
    timeScore: enemyTimeScore,
    health: enemyHealth,
    speedKind: enemySpeed
  )

  if result.kind == ekTriangle:
    result.flipTimer = rand(30..85)
  if result.kind == ekLozenge:
    result.shootTimer = rand(25..60)

  result.speed = case result.speedKind:
    of skNone:
      fp(0)
    of skSlow:
      fp(0.5)
    of skMedium:
      fp(1)
    of skFast:
      fp(2)

  copyFrame(addr objTileMem[result.sprite.tid], result.sprite.graphic, 0)

proc update*(enemy: var Enemy) =
  if enemy.status == Active:

    # make sure the enemy players go where they are supposed to go
    enemy.body.pos.x = enemy.body.pos.x - fp(luCos(
        enemy.angle)) * enemy.speed
    enemy.body.pos.y = enemy.body.pos.y - fp(luSin(
         enemy.angle)) * enemy.speed

    if enemy.kind == ekTriangle and not enemy.flipDone:
      dec enemy.flipTimer
      if enemy.flipTimer <= 0:
        enemy.speed = enemy.speed * -1
        # MP = pv - (pv - P)
        let pivot = vec2f(ScreenWidth div 2, ScreenHeight div 2)
        let diff = pivot - enemy.body.pos
        enemy.body.pos = pivot - diff
        enemy.flipDone = true
    if enemy.kind == ekLozenge:
      dec enemy.shootTimer
      if enemy.shootTimer <= 0:
        audio.playSound(sfxEnemyShoot)
        let bulEnemyProj = initProjectileBulletEnemy(gfxBulletEnemy,
            enemy.body.pos)
        fireBulletEnemy(bulEnemyProj, enemy.body.pos, enemy.angle)
        enemy.shootTimer = rand(25..60)
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
            enemy.sprite.graphic.width div 2,
            enemy.sprite.graphic.height div 2),
        tid = enemy.sprite.tid,
        pal = enemy.sprite.pal,
        size = enemy.sprite.graphic.size
      )

proc fireEnemy*(enemy: sink Enemy; angle: Angle = 0) =

  enemy.angle = angle
  enemy.status = Active

  if not enemyEntitiesInstances.isFull:
    enemyEntitiesInstances.add(enemy)

