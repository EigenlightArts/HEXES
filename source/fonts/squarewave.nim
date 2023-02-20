import natu/tte

{.compile:"../assets/fonts/squarewave.c".}
var SquarewaveFont {.importc, extern:"SquarewaveFont", codegenDecl:"extern const $# $#".}: FontObj
template fntSquarewave*: Font = addr SquarewaveFont