type
  GameStatus* = enum
    None
    Intro
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