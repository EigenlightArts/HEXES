type
  GameStatus* = enum
    None
    Play
    Paused
    LevelUp
    GameOver
  Game* = ref object
    ecnValue*: int
    ecnTarget*: int
    timer*: int
    level*: int

    status*: GameStatus