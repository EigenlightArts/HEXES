import natu/[math, utils]

var
  cameraOffset*: Vec2i
  
  shakeAmount: Fixed
  shakeDecay: Fixed

proc cameraShake*(amount, delay: Fixed) =
  shakeAmount = abs(amount)
  shakeDecay = abs(delay)

proc updateCamera*() =
  let shake = vec2f(
    rand(-shakeAmount, shakeAmount),
    rand(-shakeAmount, shakeAmount)
  )
  shakeAmount.approach(fp(0), shakeDecay)
  
  cameraOffset = vec2i(shake)