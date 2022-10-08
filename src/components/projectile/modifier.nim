import natu/[math, graphics, video, oam, utils, mgba]
import utils/[objs, body]
import components/shared

type
  ModifierKind* = enum
    mkNumber
    mkOperator
  OperatorKind* = enum
    okNone
    okAdd
    okSub
    okMul
    okDiv
  Modifier* = object
    status*: ProjectileStatus
    graphic*: Graphic
    angle*: Angle
    body*: Body

    index: int
    modifierObj: ObjAttr

    case kind*: ModifierKind
    of mkNumber:
      valueNumber*: int
    of mkOperator:
      valueOperator*: OperatorKind


# NOTE(Kal): Exe says that we don't need to free anything,
# but I think he's under the impression that we have a shared state,
# if push comes to shove try clearing the modifierObj stuff
proc `=destroy`*(modifier: var Modifier) =
  if modifier.status != Uninitialised:
    modifier.status = Uninitialised

proc `=copy`*(a: var Modifier; b: Modifier) {.error: "Not supported".}

var modifierEntitiesInstances*: List[3, Modifier]

proc initProjectileModifier*(gfx: Graphic; obj: ObjAttr;
    fontIndex: int, pos: Vec2f): Modifier =
  result = Modifier(
    graphic: gfx,
    index: fontIndex,
    modifierObj: obj,
    body: initBody(pos, 16, 16),
    kind: if fontIndex >= 0 and fontIndex <= 15: mkNumber else: mkOperator,
  )
  result.modifierObj.tileId = obj.tileId * result.graphic.frameTiles

proc toRect*(modifier: Modifier): Rect {.deprecated.} =
  result.left = modifier.body.pos.x.toInt() - modifier.body.pos.x.toInt() div 2
  result.top = modifier.body.pos.y.toInt() - modifier.body.pos.x.toInt() div 2
  result.right = modifier.body.pos.x.toInt() + modifier.body.pos.x.toInt() div 2
  result.bottom = modifier.body.pos.y.toInt() + modifier.body.pos.x.toInt() div 2

proc update*(modifier: var Modifier; speed: int = 1) =
  if modifier.status == Active:
    # make sure the modifiers go where they are supposed to go
    modifier.body.pos.x = modifier.body.pos.x - fp(luCos(
        modifier.angle)) * speed
    modifier.body.pos.y = modifier.body.pos.y - fp(luSin(
         modifier.angle)) * speed

    if (not onscreen(modifier.toRect())):
      modifier.status = Finished

# TODO(Kal): Add the `$` sprite to the left of the number modifier projectile
proc draw*(modifier: var Modifier) =
  if modifier.status == Active:
    withObj:
      obj.init(
        mode = omReg,
        pos = vec2i(modifier.body.pos) - vec2i(
            modifier.graphic.width div 2, modifier.graphic.height div 2),
        tid = modifier.modifierObj.tid + (modifier.index *
            4),
        pal = modifier.modifierObj.palId,
        size = modifier.graphic.size
      )

proc fireModifier*(modifier: sink Modifier; angle: Angle = 0) =

  modifier.angle = angle
  modifier.status = Active
  
  if modifier.kind == mkNumber:
    modifier.valueNumber = modifier.index
  if modifier.kind == mkOperator:
    modifier.valueOperator = OperatorKind(modifier.index - 15)

  if not modifierEntitiesInstances.isFull:
    modifierEntitiesInstances.add(modifier)