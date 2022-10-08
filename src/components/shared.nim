import natu/[math, graphics, video, oam, utils]
import utils/[objs]

# NOTE(Kal): To control shared state, try to avoid mutability


# Shared Fonts
let objHwaveFont* = initObj(
  tileId = allocObjTiles(gfxHwaveFont.allTiles), # Allocate tiles for a single frame of animation.
  palId = acquireObjPal(gfxHwaveFont), # Obtain palette.
  size = gfxHwaveFont.size,            # Set to correct size.
)

copyAllFrames(addr objTileMem[objHwaveFont.tileId], gfxHwaveFont)


# Shared Procedures


# Shared Types
type ProjectileStatus* = enum
  Uninitialised
  Active
  Finished
