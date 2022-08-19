import natu/[math, graphics, video, oam, utils]
import ../utils/[objs]

var orckFont* = initObj(
  pos = vec2i(100, 50),
  tileId = allocObjTiles(gfxOrckFont.allTiles),  # Allocate tiles for a single frame of animation.
  palId = acquireObjPal(gfxOrckFont),   # Obtain palette.
  size = gfxOrckNumbers.size,              # Set to correct size.
)