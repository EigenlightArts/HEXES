import natu/mgba

template log*(args: varargs[untyped]) =
  when defined(nolog):
    discard
  when defined(release):
    discard
  when not defined(release):
    printf(args)