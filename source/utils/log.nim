import natu/mgba

template log*(args: varargs[untyped]) =
  when not defined(release):
    printf(args)
