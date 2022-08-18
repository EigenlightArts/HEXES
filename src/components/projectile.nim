import natu/[math, graphics, video, oam, utils, mgba]
import ../utils/[objs]


type
  ProjectileKind* = enum
    pkBulletPlayer
    pkBulletEnemy
    pkEnemy
    pkModifier
  ModifierKind = enum
    mkNumber
    mkOperator
  Projectile* = object
    # fields that all have in common
    pos*: Vec2f
    angle*: Angle
    index*: int
    finished*: bool

    case kind*: ProjectileKind
    of pkBulletPlayer, pkBulletEnemy:
      # fields that only bullets have
      blDamage*: int
    of pkEnemy:
      # fields that only enemies have
      emHealth*: int
      emShooter*: bool
    of pkModifier:
      # fields that only modifiers have
      # modifier: Modifier
      # mkCharLength*: int 
      case mkKind*: ModifierKind
      of mkNumber:
        mkNumberChars: array[2, int]
      of mkOperator:
        mkOperatorChar: int

var bulletPlayerEntitiesInstances*: List[5, Projectile]
var bulletEnemyEntitiesInstances*: List[3, Projectile]
var enemyEntitiesInstances*: List[5, Projectile]
var modiferEntitiesInstances*: List[3, Projectile]

proc initBulletPlayerProjectile*(): Projectile =
  result.kind = pkBulletPlayer

proc initBulletEnemyProjectile*(): Projectile =
  result.kind = pkBulletEnemy

proc initEnemyProjectile*(): Projectile =
  result.kind = pkEnemy

proc initModifierProjectile*(pos: Vec2f, chars: array[2, int]): Projectile =
  result.kind = pkModifier
  result.mkKind = mkNumber
  result.pos = pos

proc initModifierProjectile*(pos: Vec2f, chars: int): Projectile =
  result.kind = pkModifier
  result.mkKind = mkOperator
  result.pos = pos
  

# Bullet spefific procedures

proc rect(bullet: Projectile): Rect =
  # printf("in projectile.nim proc rect1: x = %l, y = %l", bullet.pos.x.toInt(), bullet.pos.y.toInt())
  result.left = bullet.pos.x.toInt() - 5
  result.top = bullet.pos.y.toInt() - 5
  result.right = bullet.pos.x.toInt() + 5
  result.bottom = bullet.pos.y.toInt() + 5
  # printf("in projectile.nim proc rect2: x = %l, y = %l", bullet.pos.x.toInt(), bullet.pos.y.toInt())

proc update*(bullet: var Projectile) =

  # make sure the bullets go where they are supposed to go
  # the *2 is for speed reasons, without it, the bullets are very slow
  bullet.pos.x = bullet.pos.x - fp(luCos(
      bullet.angle)) * 2
  bullet.pos.y = bullet.pos.y - fp(luSin(
       bullet.angle)) * 2

  if (not onscreen(bullet.rect())):
    bullet.finished = true


# Modifier spefific procedures

proc draw*(modifier: var Projectile) =
  if not modifier.finished:
   if modifier.mkKind == ModifierKind.mkNumber:
    
      withObjs(modifier.mkNumberChars.len):
        let w = getWidth(modifier.obj)
        let tilesPerObj = modifier.tilesPerObj.int
        var x = modifier.obj.x
        for i in 0..<spriteCount:
          let tid = modifier.obj.tid + (modifier.mkNumberChars[i]*tilesPerObj)
          objs[i] = modifier.obj.dup(x = x, tid = tid)
          x += w

proc update*(modifier: var Projectile) =
  modifier.mkKind = mkNumber # or mkOperator
