import natu/[graphics, video, oam, utils]
import utils/[objs]

# IMPORTANT(Kal): To control shared state, try to avoid mutability here


# Shared Fonts
let objHwaveFont* = initObj(
  tid = allocObjTiles(gfxHwaveFont.allTiles), # Allocate tiles for a single frame of animation.
  pal = acquireObjPal(gfxHwaveFont), # Obtain palette.
  size = gfxHwaveFont.size,            # Set to correct size.
)

copyAllFrames(addr objTileMem[objHwaveFont.tid], gfxHwaveFont)


# Shared Procedures


# Shared Types
type ProjectileStatus* = enum
  Uninitialised
  Active
  Finished
