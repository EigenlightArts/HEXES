import natu/[math, graphics, video, oam, utils]
import ../utils/[objs]

# NOTE(Kal): To control shared state, try to avoid mutability

let objOrckFont* = initObj(
  tileId = allocObjTiles(gfxOrckFont.allTiles),  # Allocate tiles for a single frame of animation.
  palId = acquireObjPal(gfxBulletTemp),   # Obtain palette.
  size = gfxOrckFont.size,              # Set to correct size.
)

copyAllFrames(addr objTileMem[objOrckFont.tileId], gfxOrckFont)
