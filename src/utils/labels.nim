include prelude
import natu/[tte, surface]

export tte

var tc: TextContextObj

# init
tte.setContext(addr tc)
tte.initBase(fntDialogue, chr4cDrawgB4cts, chr4cErase)

type Label* = object
  obj*: ObjAttr  # base sprite
  text: cstring
  font*: Font
  dirty* {.bitsize: 1.}: bool     # whether to redraw the text
  count* {.bitsize: 7.}: uint     # how many sprites to stitch together
  width*: uint8                   # size of rendered text in pixels.
  ink* {.bitsize: 4.}: uint16
  shadow* {.bitsize: 4.}: uint16
  tilesPerObj: uint8

func initialized*(self: Label): bool {.inline.} =
  (self.tilesPerObj > 0)

proc `=destroy`*(self: var Label)  =
  if self.initialized:
    self.count = 0
    self.tilesPerObj = 0   # marks as deinitialised
    freeObjTiles(self.obj.tid)

func pos*(self: Label): Vec2i {.inline.} =
  self.obj.pos

func `pos=`*(self: var Label, pos: Vec2i) {.inline.} =
  self.obj.pos = pos

proc put*(self: var Label; text: cstring) =
  ## 
  ## Update the label text.
  ## 
  ## Note! Any buffer pointed to by `text` must persist until the next call to `draw` or `render`.
  ## 
  self.text = text
  self.dirty = true
  if text != nil:
    let (w, h) = getSize(self.obj)
    let old = tte.getContext()
    tte.setContext(addr tc)
    tte.setFont(self.font)
    tte.setPos(0, 0)
    tte.setMargins(0, 0, w * self.count.int, h)
    self.width = tte.getTextSize(text).x.uint8
    tte.setContext(old)
  else:
    self.width = 0

proc init*(self: var Label, pos: Vec2i, size: ObjSize, count: range[1..32], text: cstring = nil, font = fntDialogue, ink = 1, shadow = 2) =
  let (w, h) = getSize(size)
  var tid = self.obj.tid
  
  let tilesPerObj = (w*h) div (8*8)
  let numTiles = count * tilesPerObj
  let prevTiles = self.count * self.tilesPerObj
  
  if prevTiles == numTiles.uint:
    # already allocated the right number of tiles
    discard
  else:
    if self.initialized:
      # reallocate
      freeObjTiles(tid)
    tid = allocObjTiles(numTiles, logPowerOfTwo(tilesPerObj.uint).int)
  self.tilesPerObj = tilesPerObj.uint8
  self.count = count.uint
  self.obj.init(
    pos = pos,
    size = size,
    tid = tid,
    prio = prioGui,
  )
  self.ink = ink.uint16
  self.shadow = shadow.uint16
  self.font = font
  self.put(text)

proc destroy*(self: var Label) {.inline.} =
  `=destroy`(self)

proc render*(self: var Label) =
  ## 
  ## Repaint the text for a label.
  ## 
  ## This should be done during vblank or while the label is not visible.
  ## 
  ## If desired, you can call this immediately after creating the label, but
  ## keep in mind that visual glitches may appear if the label happened to be
  ## created on the next frame after a sprite was destroyed.
  ## 
  let (w, h) = getSize(self.obj)
  tte.setContext(addr tc)
  let surface = addr tc.dst.SurfaceChr4c
  surface[].init(
    data = addr objTileMem[self.obj.tid],
    width = (w * self.count.int).uint,
    height = h.uint,
    pal = addr objPalMem[0], # arbitrary
  )
  tte.setPos(0, 0)
  tte.setMargins(0, 0, w * self.count.int, h)
  tte.eraseScreen()
  tc.font = self.font
  tc.ink = self.ink
  tc.shadow = self.shadow
  if self.text != nil:
    tte.write(self.text)
  self.dirty = false

proc draw*(self: var Label) =
  if self.initialized:
    
    if self.dirty:
      self.render()
    
    withObjs(self.count.int):
      let w = getWidth(self.obj)
      let tilesPerObj = self.tilesPerObj.int
      var tid = self.obj.tid
      var x = self.obj.x
      for i in 0..<self.count:
        objs[i] = self.obj.dup(x = x, tid = tid)
        tid += tilesPerObj
        x += w
