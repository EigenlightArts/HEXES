import natu/[utils, maxmod]
import components/projectile/[enemy, modifier]

const maxActiveBEs* = 6
const levelMax* = 16

import types/hud

type
  Level = object
    isBoss: bool
    bossEffect: seq[BossEffect]

    levelMusic: Module
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
    levelMusic: modAssociative,
    enemyRate: 30..90,
    modifierRate: 20..40,
    allowedTargetRange: 16..64,
    allowedEnemies: {ekTriangle, ekSquare},
    allowedOperators: {okAdd, okSub},
  ),
  2: Level(
    isBoss: false,
    levelMusic: modCommutative,
    enemyRate: 30..85,
    modifierRate: 17..42,
    allowedTargetRange: 8..72,
    allowedEnemies: {ekTriangle, ekSquare},
    allowedOperators: {okAdd, okSub},
  ),
  3: Level(
    isBoss: false,
    levelMusic: modDistributive,
    enemyRate: 35..80,
    modifierRate: 15..45,
    allowedTargetRange: 8..96,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub},
  ),
  4: Level(
    isBoss: true,
    levelMusic: modSequence,
    bossEffect: @[
      BossEffect(kind: beSequence, bseqActive: true, bseqChangeFrames: 600,
          bseqPattern: [2, 3, 2, 3, 4, 6])],
    enemyRate: 40..75,
    modifierRate: 10..60,
    allowedTargetRange: 0..128,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub},
  ),
  5: Level(
    isBoss: false,
    levelMusic: modCommutative,
    enemyRate: 32..83,
    modifierRate: 12..47,
    allowedTargetRange: 4..120,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub, okMul},
  ),
  6: Level(
    isBoss: false,
    levelMusic: modDistributive,
    enemyRate: 30..87,
    modifierRate: 12..50,
    allowedTargetRange: 4..128,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub, okMul, okDiv},
  ),
  7: Level(
    isBoss: false,
    levelMusic: modAssociative,
    enemyRate: 27..90,
    modifierRate: 10..55,
    allowedTargetRange: 4..140,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge, ekCircle},
    allowedOperators: {okAdd, okSub, okMul, okDiv},
  ),
  8: Level(
    isBoss: true,
    levelMusic: modSequence,
    bossEffect: @[
      BossEffect(kind: beSequence, bseqActive: true, bseqChangeFrames: 420,
          bseqPattern: [3, 6, 2, 3, 3, 6])],
    enemyRate: 30..80,
    modifierRate: 10..55,
    allowedTargetRange: 4..168,
    allowedEnemies: {ekTriangle, ekSquare, ekCircle},
    allowedOperators: {okAdd, okSub, okMul, okDiv},
  ),
  9: Level(
    isBoss: false,
    levelMusic: modDistributive,
    enemyRate: 32..83,
    modifierRate: 12..50,
    allowedTargetRange: 4..64,
    allowedEnemies: {ekTriangle, ekSquare},
    allowedOperators: {okAdd, okSub, okMod},
  ),
  10: Level(
    isBoss: false,
    levelMusic: modAssociative,
    enemyRate: 30..87,
    modifierRate: 12..55,
    allowedTargetRange: 8..128,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okMul, okDiv, okMod},
  ),
  11: Level(
    isBoss: false,
    levelMusic: modCommutative,
    enemyRate: 27..90,
    modifierRate: 10..55,
    allowedTargetRange: 0..180,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge, ekCircle},
    allowedOperators: {okAdd, okSub, okMul, okDiv, okMod},
  ),
  12: Level(
    isBoss: true,
    levelMusic: modSequence,
    bossEffect: @[
      BossEffect(kind: beSequence, bseqActive: true, bseqChangeFrames: 550,
          bseqPattern: [2, 6, 2, 6, 4, 3])],
    enemyRate: 30..80,
    modifierRate: 10..55,
    allowedTargetRange: 0..200,
    allowedEnemies: {ekTriangle, ekSquare, ekCircle},
    allowedOperators: {okAdd, okSub, okMod},
  ),
  13: Level(
    isBoss: false,
    levelMusic: modAssociative,
    enemyRate: 24..88,
    modifierRate: 10..55,
    allowedTargetRange: 0..200,
    allowedEnemies: {ekTriangle, ekSquare, ekPentagon},
    allowedOperators: {okAdd, okSub, okMul, okDiv},
  ),
  14: Level(
    isBoss: false,
    levelMusic: modCommutative,
    enemyRate: 20..90,
    modifierRate: 10..60,
    allowedTargetRange: 0..228,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge, ekPentagon},
    allowedOperators: {okAdd, okSub, okMul, okDiv, okMod},
  ),
  15: Level(
    isBoss: false,
    levelMusic: modDistributive,
    enemyRate: 10..95,
    modifierRate: 5..75,
    allowedTargetRange: 0..255,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge, ekCircle, ekPentagon},
    allowedOperators: {okAdd, okSub, okMul, okDiv, okMod},
  ),
  16: Level(
    isBoss: true,
    levelMusic: modSequence,
    bossEffect: @[
      BossEffect(kind: beSequence, bseqActive: true, bseqChangeFrames: 350,
          bseqPattern: [3, 1, 4, 1, 6, 8])],
    enemyRate: 5..100,
    modifierRate: 0..80,
    allowedTargetRange: 0..255,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge, ekCircle, ekPentagon},
    allowedOperators: {okAdd, okSub, okMul, okDiv, okMod},
  ),
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

proc getLevelMusic*(currentLevel: int): Module =
  let slice = levels[currentLevel].levelMusic
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
