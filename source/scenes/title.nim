import natu/[bios, irq, oam, input, video, mgba, math]
import natu/[graphics, backgrounds]
import utils/[objs, levels, scene]

# TODO(Kal): Implement Title Screen

# var menuItems: array[2, int]
# var menuCur: int

proc onShow =
  # background color, approximating eigengrau
  bgColorBuf[0] = rgb8(22, 22, 29)

    # Use a BG Control register to select a charblock and screenblock:
  bgcnt[1].init(cbb = 0, sbb = 31)

  # Load the tiles, map and palette into memory:
  bgcnt[1].load(bgHexesSegments)

  # Show the background:
  dispcnt.init(layers = {lBg0, lBg1})

  display.layers = {lBg0, lBg1, lObj}
  display.obj1d = true

  printf("ASSERT TITLE.NIM")

  # enable VBlank interrupt so we can wait for
  # the end of the frame without burning CPU cycles
  irq.enable(iiVBlank)

proc onHide =
  display.layers = display.layers - { lBg0, lBg1 , lObj }

const TitleScene* = Scene(
  show: onShow,
  hide: onHide,
)