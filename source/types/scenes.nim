import types/[entities, hud]
import utils/audio

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

    playerShipInstance*: PlayerShip
    evilHexInstance*: EvilHex

    centerNumberInstance*: CenterNumber
    timerInstance*: Timer
    targetInstance*: Target
    modifierSlotsInstance*: ModifierSlots

proc `=destroy`*(self: var Game) =
  if self.state != None:
    self.state = None

proc `=copy`*(dest: var Game; source: Game) {.error: "Not implemented".}

proc playGameMusic*(self: Game) =
  if self.level mod 2 == 0:
    audio.playMusic(modCommutative)
  else:
    audio.playMusic(modAssociative)