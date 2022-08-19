import natu/[math, graphics, video, tte, posprintf, mgba]
import ../utils/labels
import ../components/[shooter, projectile, shared]

type
  EvilHex* = object
    initialised: bool
    centerHexNumber: uint8
    updateCHN: bool
    labeledCHN: Label
    tileId, paletteId: int
    hexBuffer: array[9, char]
    angle: Angle
    pos: Vec2f

    shooter: Shooter

proc initEvilHex*(centerHexNumber: uint8): EvilHex =
  result.initialised = true
  result.updateCHN = true
  result.angle = 20
  result.centerHexNumber = centerHexNumber
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
  if self.updateCHN:
    var size = tte.getTextSize(addr self.hexBuffer)
    self.labeledCHN.pos = vec2i(ScreenWidth div 2 - size.x div 2, ScreenHeight div 2 - size.y div 2)

    self.labeledCHN.put(addr self.hexBuffer)
    self.updateCHN = false

  self.shooter.draw()
  self.labeledCHN.draw()

  # copyFrame(addr objTileMem[self.tileId], gfxShipTemp, 0)
  # withObjAndAff:
  #   let delta = self.centerPoint - self.pos
  #   aff.setToRotationInv(ArcTan2(int16(delta.x), int16(delta.y)))
  #   obj.init:
  #     mode = omAff
  #     affId = affId
  #     pos = vec2i(self.pos) - vec2i(gfxShipTemp.width div 2, gfxShipTemp.height div 2)
  #     size = gfxShipTemp.size
  #     tileId = self.tileId
  #     palId = self.paletteId

proc update*(self: var EvilHex) = 
  # TODO(Kal): Implement Blue Noise RNG to select the modifier type
  var modHexInstance: Projectile = initModifierProjectile(gfx=gfxOrckFont, obj=objOrckFont, orckIndex=4)
  printf(gfx)
  self.shooter.fire(projectile=modHexInstance, pos=vec2f(100, 50), angle=self.angle)
