import natu/[video, tte]

proc centralHex*() =
    tte.initChr4c(bgnr = 0, initBgCnt(cbb = 0, sbb = 31))
    tte.setPos(100, 68)
    tte.write("$100")