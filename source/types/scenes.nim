import types/[entities, hud]

type
  GameState* = enum
    None
    Intro
    Play
    Paused
    LevelUp
    GameOver
  Game* = object
    state*: GameState
    
    level*: int
    isBoss*: bool

    playerShipInstance*: PlayerShip
    evilHexInstance*: EvilHex

    centerNumberInstance*: CenterNumber
    timerInstance*: Timer
    statusInstance*: Status
    targetInstance*: Target
    modifierSlotsInstance*: ModifierSlots

proc `=destroy`*(self: var Game) =
  if self.state != None:
    self.state = None

proc `=copy`*(dest: var Game; source: Game) {.error: "Not implemented".}
