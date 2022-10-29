import natu/[memory, maxmod, math]

export vblank, frame, Module, Sample

const
  channels = 16
  waveMemSize = channels * (mmSizeofModCh + mmSizeofActCh + mmSizeofMixCh) + mmMixLen16Khz 

var
  waveMem {.codegenDecl:EWRAM_DATA.}: array[waveMemSize, uint8]
  mixMem {.align:4.}: array[mmMixLen16Khz, uint8]

proc init* =
  var config = MmGbaSystem(
    mixingMode: mmMix16Khz,
    modChannelCount: channels,
    mixChannelCount: channels,
    moduleChannels: addr waveMem[0],
    activeChannels: addr waveMem[channels * mmSizeofModCh],
    mixingChannels: addr waveMem[channels * (mmSizeofModCh + mmSizeofActCh)],
    mixingMemory: addr mixMem[0],
    waveMemory: addr waveMem[channels * (mmSizeofModCh + mmSizeofActCh + mmSizeofMixCh)],
    soundbank: soundbankBin,
  )
  maxmod.init(addr config)


proc playSound*(sampleId: Sample) {.inline.} =
  maxmod.effect(sampleId)

proc playMusic*(moduleId: Module) {.inline.} =
  maxmod.start(moduleId, mmPlayLoop)
  maxmod.setModuleVolume(0.5.toFixed(10))

proc pauseSong*() {.inline.} =
  maxmod.pause()

proc resumeSong*() {.inline.} =
  maxmod.resume()

proc stopSong* {.inline.} =
  maxmod.stop()
