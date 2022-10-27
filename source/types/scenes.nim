import types/[entities, hud]

type
  GameStatus* = enum
    None
    Intro
    Play
    Paused
    LevelUp
    GameOver
  Game* = object
    status*: GameStatus
    
    ecnValue*: int
    ecnTarget*: int
    level*: int

    playerShipInstance*: PlayerShip
    evilHexInstance*: EvilHex

    centerNumberInstance*: CenterNumber
    timerInstance*: Timer
    targetInstance*: Target
    modifierSlotsInstance*: ModifierSlots

proc `=destroy`*(self: var Game) =
  if self.status != None:
    self.status = None

proc `=copy`*(dest: var Game; source: Game) {.error: "Not implemented".}
