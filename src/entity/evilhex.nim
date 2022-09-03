import natu/[math, graphics, video, bios, tte, utils, posprintf, mgba]
import ../utils/[labels, objs]
import ../components/[shooter, projectile, shared]

# TODO(Kal): Split CenterHexNumber into component

type
  EvilHex* = object
    initialised: bool

    tileId, paletteId: int
    hexBuffer: array[9, char]
    
    centerHexNumber: uint8
    updateCHN: bool
    labelCHN: Label  
    
    orbitRadius: Vec2i
    centerPoint: Vec2i
    # pos: Vec2f
    # angle: Angle

    shooter: Shooter
    modifierProj: Projectile

proc initEvilHex*(centerHexNumber: uint8): EvilHex =
  result.initialised = true
  result.orbitRadius = vec2i(15, 10)
  result.centerPoint = vec2i(ScreenWidth div 2, ScreenHeight div 2)
  # result.angle = 0
  # result.pos = vec2f(70, 70)
  
  result.centerHexNumber = centerHexNumber
  result.updateCHN = true
  result.tileId = allocObjTiles(gfxShipTemp)
  result.paletteId = acquireObjPal(gfxShipTemp)

  result.shooter = initShooter()
  posprintf(addr result.hexBuffer, "$%X", centerHexNumber)

  result.labelCHN.init(vec2i(ScreenWidth div 2, ScreenHeight div 2), s8x16, count = 22)
  result.labelCHN.obj.pal = getPalId(gfxShipTemp)
  result.labelCHN.ink = 1 # set the ink colour index to use from the palette
  result.labelCHN.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  result.labelCHN.put(addr result.hexBuffer)


# destructor - free the resources used by the hex object
proc `=destroy`*(self: var EvilHex) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxShipTemp)
    self.shooter.destroy()
    self.labelCHN.destroy()

proc `=copy`*(dest: var EvilHex; source: EvilHex) {.error: "Not implemented".}


# draw evilhex and related parts
proc draw*(self: var EvilHex) =
  self.shooter.draw()
  self.labelCHN.draw()
  self.modifierProj.draw()

  if self.updateCHN:
    var size = tte.getTextSize(addr self.hexBuffer)
    self.labelCHN.pos = vec2i(ScreenWidth div 2 - size.x div 2, ScreenHeight div 2 - size.y div 2)

    self.labelCHN.put(addr self.hexBuffer)
    self.updateCHN = false


proc fire*(self: var EvilHex, modifierIndex: int, playerShipPos: Vec2f) = 
  # TODO(Kal): Implement Blue Noise RNG to select the modifier type and angle+position of bullets
  let angleVariance = 10000
  let anglePlayer = ArcTan2(int16(-playerShipPos.x.toInt()), int16(-playerShipPos.y.toInt()))
  let angle = uint32(int(anglePlayer) + rand(-angleVariance..angleVariance)) 
  printf("in evilhex.nim proc fire anglePlayer = %l, playerShipPos.x = %l, playerShipPos.y = %l, angle = %l", anglePlayer, -playerShipPos.x.toInt(), -playerShipPos.y.toInt(), angle.uint16)
  printf("in evilhex.nim proc fire rand = %l", rand(-angleVariance..angleVariance))

  var pos: Vec2f

  pos.x = self.centerPoint.x - fp(luCos(
      angle) * self.orbitRadius.x)
  pos.y = self.centerPoint.y - fp(luSin(
      angle) * self.orbitRadius.y)
  
  self.modifierProj = initModifierProjectile(gfx=gfxHwaveFont, obj=objHwaveFont, fontIndex=modifierIndex)
  # var modHexInstance: Projectile = initBulletEnemyProjectile(gfxBulletTemp) # this is done for debugging purposes
  printf("in evilhex.nim proc fire x = %l, y = %l, angle = %l", pos.x.toInt(), pos.y.toInt(), angle.uint16)
  self.shooter.fire(projectile=self.modifierProj, pos=pos, angle=angle)

proc update*(self: var EvilHex) =

  # pos.x = pos.x - fp(luCos(
  #     self.angle)) * 2
  # pos.y = pos.y - fp(luSin(
  #      self.angle)) * 2

  self.shooter.update()
  self.modifierProj.update()
