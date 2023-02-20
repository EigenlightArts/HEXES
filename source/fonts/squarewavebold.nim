import natu/tte

{.compile:"../assets/fonts/squarewave-bold.c".}
var SquarewaveBoldFont {.importc, extern:"SquarewaveBoldFont", codegenDecl:"extern const $# $#".}: FontObj
template fntSquarewaveBold*: Font = addr SquarewaveBoldFont