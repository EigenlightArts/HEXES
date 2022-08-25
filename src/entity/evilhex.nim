import natu/[math, graphics, video, bios, tte, utils, posprintf, mgba]
import ../utils/[labels, objs]
import ../components/[shooter, projectile, shared]

# TODO(Kal): Split CenterHexNumber into new type

type
  EvilHex* = object
    initialised: bool

    tileId, paletteId: int
    hexBuffer: array[9, char]
    
    centerHexNumber: uint8
    updateCHN: bool
    labeledCHN: Label  
    
    orbitRadius: Vec2i
    centerPoint: Vec2i
    pos: Vec2f
    angle: Angle
    shooter: Shooter

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

  result.labeledCHN.init(vec2i(ScreenWidth div 2, ScreenHeight div 2), s8x16, count = 22)
  result.labeledCHN.obj.pal = getPalId(gfxShipTemp)
  result.labeledCHN.ink = 1 # set the ink colour index to use from the palette
  result.labeledCHN.shadow = 2 # set the shadow colour (only relevant if the font actually has more than 1 colour)

  result.labeledCHN.put(addr result.hexBuffer)


# destructor - free the resources used by the hex object
proc `=destroy`*(self: var EvilHex) =
  if self.initialised:
    self.initialised = false
    freeObjTiles(self.tileId)
    releaseObjPal(gfxShipTemp)
    self.shooter.destroy()
    self.labeledCHN.destroy()

proc `=copy`*(dest: var EvilHex; source: EvilHex) {.error: "Not implemented".}


# draw evilhex and related parts
proc draw*(self: var EvilHex) =
  self.shooter.draw()
  self.labeledCHN.draw()

  if self.updateCHN:
    var size = tte.getTextSize(addr self.hexBuffer)
    self.labeledCHN.pos = vec2i(ScreenWidth div 2 - size.x div 2, ScreenHeight div 2 - size.y div 2)

    self.labeledCHN.put(addr self.hexBuffer)
    self.updateCHN = false

  #[ withObjAndAff:
    let delta = self.centerPoint - self.pos
    aff.setToRotationInv(ArcTan2(int16(delta.x), int16(delta.y)))
    obj.init:
      mode = omAff
      affId = affId
      pos = vec2i(self.pos) - vec2i(gfxShipTemp.width div 2, gfxShipTemp.height div 2)
      size = gfxShipTemp.size
      tileId = self.tileId
      palId = self.paletteId ]#

proc fire*(self: var EvilHex) = 
  # TODO(Kal): Implement Blue Noise RNG to select the modifier type and angle+position of bullets
  self.angle = rand(uint16)

  self.pos.x = self.centerPoint.x - fp(luCos(
      self.angle) * self.orbitRadius.x)
  self.pos.y = self.centerPoint.y - fp(luSin(
      self.angle) * self.orbitRadius.y)
  
  var modHexInstance: Projectile = initModifierProjectile(gfx=gfxOrckFont, obj=objOrckFont, orckIndex=4)
  # var modHexInstance: Projectile = initBulletEnemyProjectile(gfxBulletTemp) # this is done for debugging purposes
  printf("in evilhex.nim proc fire x = %l, y = %l, angle = %l", self.pos.x.toInt(), self.pos.y.toInt(), self.angle.uint16)
  self.shooter.fire(projectile=modHexInstance, pos=self.pos, angle=self.angle)

proc update*(self: var EvilHex) =

  # self.pos.x = self.centerPoint.x + fp(luCos(
  #     self.angle) * self.orbitRadius.x)
  # self.pos.y = self.centerPoint.y + fp(luSin(
  #     self.angle) * self.orbitRadius.y)

  self.shooter.update()