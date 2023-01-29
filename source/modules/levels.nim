import natu/utils
import components/projectile/[enemy, modifier]

const maxActiveBEs* = 6
const levelMax* = 4

import types/hud

type
  Level = object
    isBoss: bool
    bossEffect: seq[BossEffect]

    enemyRate: Slice[int]
    modifierRate: Slice[int]

    allowedTargetRange: Slice[int]
    allowedEnemies: set[EnemyKind]
    allowedOperators: set[OperatorKind]


# TODO(Kal): Split configuration to TOML files?
# Using https://github.com/status-im/nim-toml-serialization

const levels: array[1..levelMax, Level] = [
  1: Level(
    isBoss: false,
    enemyRate: 30..90,
    modifierRate: 15..40,
    allowedTargetRange: 16..64,
    allowedEnemies: {ekTriangle, ekSquare},
    allowedOperators: {okAdd, okSub},
  ),
  2: Level(
    isBoss: false,
    enemyRate: 30..85,
    modifierRate: 10..45,
    allowedTargetRange: 8..64,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub},
  ),
  3: Level(
    isBoss: false,
    enemyRate: 35..80,
    modifierRate: 10..50,
    allowedTargetRange: 8..96,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub},
  ),
  4: Level(
    isBoss: true,
    bossEffect: @[
      BossEffect(kind: beSequence, bseqActive: true, bseqChangeFrames: 600,
          bseqPattern: [2, 3, 2, 3, 4, 6])],
    enemyRate: 40..75,
    modifierRate: 10..60,
    allowedTargetRange: 0..128,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub},
  )
]

proc randSet[T](slice: set[T]): T =
  let r = rand(card(slice) - 1)

  var i = 0
  for kind in slice:
    if i == r:
      return kind
    else:
      inc i

  # if the for loop doesn't return something, return the type's None value
  # there shouldn't really be an occasion where this gets reached
  # but it's here just in case
  return T(0)

proc bossCheck*(currentLevel: int): bool =
  let slice = levels[currentLevel].isBoss
  result = slice

proc getEffects*(currentLevel: int): seq[BossEffect] =
  let slice = levels[currentLevel].bossEffect
  result = slice

proc selectEnemy*(currentLevel: int): EnemyKind =
  let slice = levels[currentLevel].allowedEnemies
  result = randSet(slice)

proc selectOperator*(currentLevel: int): OperatorKind =
  let slice = levels[currentLevel].allowedOperators
  result = randSet(slice)

proc selectTargetRange*(currentLevel: int): int =
  let slice = levels[currentLevel].allowedTargetRange
  result = rand(slice)

proc enemyShoot*(currentLevel: int): int =
  let slice = levels[currentLevel].enemyRate
  result = rand(slice)

proc modifierShoot*(currentLevel: int): int =
  let slice = levels[currentLevel].modifierRate
  result = rand(slice)
