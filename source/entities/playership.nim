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
  result.tid = allocObjTiles(gfxShipPlayer)
  result.paletteId = acquireObjPal(gfxShipPlayer)


# draw ship sprite and all the affine snazziness
proc draw*(self: var PlayerShip, gameState: GameState) =
  if gameState != GameOver:
    copyFrame(addr objTileMem[self.tid], gfxShipPlayer, 0)
    if not invisibilityOn and not screenStopOn:
      withObjAndAff:
        let delta = self.centerPoint - self.body.pos
        aff.setToRotationInv(ArcTan2(int16(delta.x), int16(delta.y)))
        obj.init:
          mode = omAff
          affId = affId
          pos = vec2i(self.body.pos) - vec2i(gfxShipPlayer.width div 2,
              gfxShipPlayer.height div 2)
          size = gfxShipPlayer.size
          tid = self.tid
          pal = self.paletteId
    elif invisibilityOn:
      if (invisibilityFrames div 20) mod 2 == 0:
        withObjAndAff:
          let delta = self.centerPoint - self.body.pos
          aff.setToRotationInv(ArcTan2(int16(delta.x), int16(delta.y)))
          obj.init:
            mode = omAff
            affId = affId
            pos = vec2i(self.body.pos) - vec2i(gfxShipPlayer.width div 2,
                gfxShipPlayer.height div 2)
            size = gfxShipPlayer.size
            tid = self.tid
            pal = self.paletteId


# calculate and update ship position
proc update*(self: var PlayerShip) =
  self.body.pos.x = self.centerPoint.x + fp(luCos(
      self.angle) * self.orbitRadius.x)
  self.body.pos.y = self.centerPoint.y + fp(luSin(
      self.angle) * self.orbitRadius.y)
  
