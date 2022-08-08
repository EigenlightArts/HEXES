import natu/[math, graphics, video, tte]
import shooter

type
  EvilHex* = object
    initialised: bool
    centerHexNumber: uint8
    tileId, paletteId: int
    pos: Vec2i
  
    shooter: Shooter

proc InitEvilHex*(centerHexNumberStarting: uint8, pos: Vec2i): EvilHex =
  result.initialised = true
  result.pos = pos
  result.centerHexNumber = centerHexNumberStarting
  result.tileId = allocObjTiles(gfxShipTemp)
  result.paletteId = acquireObjPal(gfxShipTemp)

  result.shooter = initShooter()


  tte.initChr4c(bgnr = 0, initBgCnt(cbb = 0, sbb = 31))
  tte.setPos(pos)
  tte.write(result.centerHexNumber.toString())