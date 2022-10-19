import natu/[math, graphics, posprintf, video, tte, utils]
import components/shared
import components/projectile/modifier
import utils/objs
import modules/shooter
import modules/types/hud

# TODO(Kal): Finish ModifierSlots

proc initModifierSlots*() =
  result.initialised = true
  result.updateFlag = true
