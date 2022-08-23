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
  result.angle = 30
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
  self.shooter.draw()
  self.labeledCHN.draw()

  if self.updateCHN:
    var size = tte.getTextSize(addr self.hexBuffer)
    self.labeledCHN.pos = vec2i(ScreenWidth div 2 - size.x div 2, ScreenHeight div 2 - size.y div 2)

    self.labeledCHN.put(addr self.hexBuffer)
    self.updateCHN = false

proc fire*(self: var EvilHex) = 
  # TODO(Kal): Implement Blue Noise RNG to select the modifier type
  var modHexInstance: Projectile = initModifierProjectile(gfx=gfxOrckFont, obj=objOrckFont, orckIndex=4)
  # var modHexInstance: Projectile = initBulletEnemyProjectile(gfxBulletTemp)
  printf("labeledCHN.pos is X:%d Y:%d", self.labeledCHN.pos.x, self.labeledCHN.pos.y)
  self.shooter.fire(projectile=modHexInstance, pos=vec2f(self.labeledCHN.pos), angle=self.angle)

proc update*(self: var EvilHex) =
  self.shooter.update()