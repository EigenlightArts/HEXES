import natu/utils
import components/projectile/[enemy, modifier]

type
  Level = object
    isBoss: bool

    enemyRate: Slice[int]
    modifierRate: Slice[int]

    allowedTargetRange: Slice[int]
    allowedEnemies: set[EnemyKind]
    allowedOperators: set[OperatorKind]


const levelMax* = 4

# TODO(Kal): Split configuration to TOML files?
# Using https://github.com/status-im/nim-toml-serialization

const levels: array[1..levelMax, Level] = [
  1: Level(
    isBoss: false,
    enemyRate: 30..90,
    modifierRate: 15..40,
    allowedEnemies: {ekTriangle, ekSquare},
    allowedOperators: {okAdd, okSub},
  ),
  2: Level(
    isBoss: false,
    enemyRate: 30..85,
    modifierRate: 10..45,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub},
  ),
  3: Level(
    isBoss: false,
    enemyRate: 35..80,
    modifierRate: 10..50,
    allowedEnemies: {ekTriangle, ekSquare, ekLozenge},
    allowedOperators: {okAdd, okSub},
  ),
  4: Level(
    isBoss: true,
    enemyRate: 40..75,
    modifierRate: 10..60,
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


proc selectEnemy*(currentLevel: int): EnemyKind =
  let slice = levels[currentLevel].allowedEnemies
  result = randSet(slice)

proc selectOperator*(currentLevel: int): OperatorKind =
  let slice = levels[currentLevel].allowedOperators
  result = randSet(slice)

proc enemyShoot*(currentLevel: int): int =
  let slice = levels[currentLevel].enemyRate
  result = rand(slice)

proc enemyModifier*(currentLevel: int): int =
  let slice = levels[currentLevel].modifierRate
  result = rand(slice)