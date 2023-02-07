import natu/[math, utils]

var
  cameraOffset*: Vec2i
  
  shakeAmount: Fixed
  shakeDelay: Fixed

proc cameraShake*(amount, delay: Fixed) =
  shakeAmount = abs(amount)
  shakeDelay = abs(delay)

proc updateCamera*() =
  let shake = vec2f(
    rand(-shakeAmount, shakeAmount),
    rand(-shakeAmount, shakeAmount)
  )
  shakeAmount.approach(fp(0), shakeDelay)
  
  cameraOffset = vec2i(shake)