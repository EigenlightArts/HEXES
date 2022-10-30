import natu/utils

type
  Level = object
    enemySelect: Slice[int]
    enemyShoot: Slice[int]
    modifierShoot: Slice[int]

const levelMax* = 4

const levels: array[1..levelMax, Level] = [
  1: Level(
    enemySelect: 1..2,
    enemyShoot: 30..90,
    modifierShoot: 15..40,
  ),
  2: Level(
    enemySelect: 1..3,
    enemyShoot: 30..85,
    modifierShoot: 10..45,
  ),
  3: Level(
    enemySelect: 1..3,
    enemyShoot: 35..80,
    modifierShoot: 10..50,
  ),
  4: Level(
    enemySelect: 1..4,
    enemyShoot: 40..75,
    modifierShoot: 10..60,
  )
]

proc selectEnemy*(currentLevel: int): int =
  let slice = levels[currentLevel].enemySelect
  result = rand(slice)

proc enemyShoot*(currentLevel: int): int =
  let slice = levels[currentLevel].enemyShoot
  result = rand(slice)

proc enemyModifier*(currentLevel: int): int =
  let slice = levels[currentLevel].modifierShoot
  result = rand(slice)