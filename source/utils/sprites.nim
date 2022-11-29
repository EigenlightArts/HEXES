import natu/[utils, oam, video, math, graphics]
import utils/objs

type Sprite* = object
  initialised*: bool
  obj*: ObjAttr
  pos*: Vec2i
  tid*, pal*: int
  prevFrame: int
  frame*: int
  graphic*: Graphic

proc `=destroy`*(self: var Sprite) =
  if self.initialised:
    freeObjTiles(self.tid)
    releaseObjPal(self.graphic)
    self.initialised = false

proc initSprite*(g: Graphic, pos = vec2i()): Sprite =
  result.graphic = g
  result.tid = allocObjTiles(g)
  result.pal = acquireObjPal(g)
  result.obj.init(
    pos = pos,
    tid = result.tid,
    pal = result.pal,
    size = g.size,
  )
  result.pos = pos
  result.prevFrame = -1
  result.frame = 0
  result.initialised = true


proc draw*(self: var Sprite) =
  if self.initialised:
  
    if self.prevFrame != self.frame:
      self.prevFrame = self.frame
      copyFrame(addr objTileMem[self.tid], self.graphic, self.frame)
    
    withObj:
      obj = self.obj.dup(pos = self.pos)