import natu/[math, graphics, video, bios, tte, utils, posprintf, mgba]
import ../utils/[labels, objs]
import ../components/shared
import ../modules/shooter
import ecn

# TODO(Kal): Split EvilHexCenterNumber into a new component or type

type EvilHex* = object
  initialised: bool

  tileId, paletteId: int
  hexBuffer: array[9, char]
  evilHexCenterNumber: EvilHexCenterNumber

  orbitRadius: Vec2i
  centerPoint: Vec2i


proc initEvilHex*(evilHexCenterNumber: sink EvilHexCenterNumber): EvilHex =
  result.initialised = true
  result.orbitRadius = vec2i(15, 10)
  result.centerPoint = vec2i(ScreenWidth div 2, ScreenHeight div 2)
  result.evilHexCenterNumber = evilHexCenterNumber

  result.tileId = allocObjTiles(gfxShipTemp)
  result.paletteId = acquireObjPal(gfxShipTemp)

  posprintf(addr result.hexBuffer, "$%X", result.evilHexCenterNumber)
  result.evilHexCenterNumber.label.put(addr result.hexBuffer)
  
# destructor - free the resources used by the hex object
proc `=destroy`*(self: var EvilHex) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxShipTemp)

proc `=copy`*(dest: var EvilHex; source: EvilHex) {.error: "Not implemented".}

# draw evilhex and related parts
proc draw*(self: var EvilHex) =
  self.evilHexCenterNumber.label.draw()

  if self.evilHexCenterNumber.update:
    var size = tte.getTextSize(addr self.hexBuffer)
    self.evilHexCenterNumber.label.pos = vec2i(ScreenWidth div 2 - size.x div 2,
        ScreenHeight div 2 - size.y div 2)

    self.evilHexCenterNumber.label.put(addr self.hexBuffer)
    self.evilHexCenterNumber.update = false


proc fireModifierHex*(self: var EvilHex; modifierIndex: int;
    playerShipPos: Vec2f) =
  # TODO(Kal): Implement Blue Noise RNG to select the modifier type and angle+position of bullets

  # FIXME(Kal): Fix the broken ranged shoot
  # TODO(Kal): Consider if this is even necessary for the game?
  # let angleVariance = 1
  # let anglePlayer = ArcTan2(int16(playerShipPos.x.toInt()), int16(playerShipPos.y.toInt()))
  # let angle = uint32(int(anglePlayer) + rand(-angleVariance..angleVariance))
  # printf("in evilhex.nim proc fire anglePlayer = %l, playerShipPos.x = %l, playerShipPos.y = %l, angle = %l", anglePlayer, -playerShipPos.x.toInt(), -playerShipPos.y.toInt(), angle.uint16)
  # printf("in evilhex.nim proc fire rand = %l", rand(-angleVariance..angleVariance))

  # let angle: Angle = rand(uint16)
  let angle: Angle = 45368 # for testing and debugging
  let pos: Vec2f = vec2f(
      self.centerPoint.x - fp(luCos(angle) * self.orbitRadius.x),
      self.centerPoint.y - fp(luSin(angle) * self.orbitRadius.y))

  let modifierProj = initProjectileModifier(gfxHwaveFont,
      objHwaveFont, modifierIndex, pos)
  # var modHexInstance: Projectile = initBulletEnemyProjectile(gfxBulletTemp) # this was done for debugging purposes

  # printf("in evilhex.nim proc fire x = %l, y = %l, angle = %l", pos.x.toInt(),
  #     pos.y.toInt(), angle.uint16)

  shooter.fireModifier(modifierProj, angle)

proc update*(self: var EvilHex) =

  shooter.update()
