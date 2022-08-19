import natu/[math, graphics, video, oam, utils]
import ../utils/[objs]

# NOTE(Kal): To control shared state, NEVER MAKE THESE MUTABLE

let objOrckFont* = initObj(
  tileId = allocObjTiles(gfxOrckFont.allTiles),  # Allocate tiles for a single frame of animation.
  palId = acquireObjPal(gfxOrckFont),   # Obtain palette.
  size = gfxOrckFont.size,              # Set to correct size.
)