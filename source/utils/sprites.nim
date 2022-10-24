import natu/[utils, oam, video, math, graphics, tte, surfaces]
import utils/objs

type Sprite* = object
  initialised*: bool
  obj*: ObjAttr
  pos*: Vec2i
  tileId: int
  prevFrame: int
  frame*: int
  graphic*: Graphic

proc `=destroy`*(self: var Sprite) =
  if self.initialised:
    freeObjTiles(self.tileId)
    releaseObjPal(self.graphic)
    self.initialised = false

proc init*(self: var Sprite, g: Graphic, pos = vec2i()) =
  if self.initialised:
    self.destroy()
  
  self.graphic = g
  self.tileId = allocObjTiles(g)
  self.obj.init(
    pos = pos,
    tid = self.tileId,
    pal = acquireObjPal(g),
    size = g.size,
  )
  self.pos = pos
  self.prevFrame = -1
  self.frame = 0
  self.initialised = true


proc draw*(self: var Sprite) =
  if self.initialised:
  
    if self.prevFrame != self.frame:
      self.prevFrame = self.frame
      copyFrame(addr objTileMem[self.tileId], self.graphic, self.frame)
    
    withObj:
      obj = self.obj.dup(pos = self.pos)