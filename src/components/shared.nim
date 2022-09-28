import natu/[math, graphics, video, oam, utils]
import ../utils/[objs]

# NOTE(Kal): To control shared state, try to avoid mutability


# Shared Fonts
let objHwaveFont* = initObj(
  tileId = allocObjTiles(gfxHwaveFont.allTiles), # Allocate tiles for a single frame of animation.
  palId = acquireObjPal(gfxHwaveFont), # Obtain palette.
  size = gfxHwaveFont.size,            # Set to correct size.
)

copyAllFrames(addr objTileMem[objHwaveFont.tileId], gfxHwaveFont)

# Shared Procedures
proc isCollidingAABB*(projectileA: Rect; projectileB: Rect): bool =
  let left = projectileB.x - (projectileA.x + projectileA.width)
  let top = (projectileB.y + projectileB.height) - projectileA.y
  let right = (projectileB.x + projectileB.width) -
      projectileA.x
  let bottom = projectileB.y - (projectileA.y +
      projectileA.height)

  # inverting conditions to check faster
  return not (left > 0 or right < 0 or top < 0 or bottom > 0)

# Shared Types
type ProjectileStatus* = enum
  Uninitialised
  Active
  Finished
