import natu/[math, graphics, video, bios]
import utils/objs
import types/[entities, scenes]


# constructor - create a ship object
proc initPlayerShip*(pos: Vec2f): PlayerShip =
  result.initialised = true # you should add an extra field
  result.orbitRadius = vec2i(90, 60)
  result.body = initBody(pos, 14, 14)
  result.angle = 0
  result.centerPoint = vec2i(ScreenWidth div 2, ScreenHeight div 2)
  result.tileId = allocObjTiles(gfxShipTemp)
  result.paletteId = acquireObjPal(gfxShipTemp)


# draw ship sprite and all the affine snazziness
proc draw*(self: var PlayerShip, gameStatus: GameStatus) =
  if gameStatus != GameOver:
    copyFrame(addr objTileMem[self.tileId], gfxShipTemp, 0)
    if not invisibilityOn and not screenStopOn:
      withObjAndAff:
        let delta = self.centerPoint - self.body.pos
        aff.setToRotationInv(ArcTan2(int16(delta.x), int16(delta.y)))
        obj.init:
          mode = omAff
          affId = affId
          pos = vec2i(self.body.pos) - vec2i(gfxShipTemp.width div 2,
              gfxShipTemp.height div 2)
          size = gfxShipTemp.size
          tileId = self.tileId
          palId = self.paletteId
    elif invisibilityOn:
      if (invisibilityFrames div 20) mod 2 == 0:
        withObjAndAff:
          let delta = self.centerPoint - self.body.pos
          aff.setToRotationInv(ArcTan2(int16(delta.x), int16(delta.y)))
          obj.init:
            mode = omAff
            affId = affId
            pos = vec2i(self.body.pos) - vec2i(gfxShipTemp.width div 2,
                gfxShipTemp.height div 2)
            size = gfxShipTemp.size
            tileId = self.tileId
            palId = self.paletteId


# calculate and update ship position
proc update*(self: var PlayerShip) =
  self.body.pos.x = self.centerPoint.x + fp(luCos(
      self.angle) * self.orbitRadius.x)
  self.body.pos.y = self.centerPoint.y + fp(luSin(
      self.angle) * self.orbitRadius.y)
  
