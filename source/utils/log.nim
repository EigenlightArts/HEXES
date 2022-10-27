import natu/mgba

template log*(args: varargs[untyped]) =
  # discard
  printf(args)
