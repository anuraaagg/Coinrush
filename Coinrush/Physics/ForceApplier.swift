//
//  ForceApplier.swift
//  Coinrush
//
//  Centralized force application utilities
//

import RealityKit
import simd

/// Utility for applying forces to coins
struct ForceApplier {

  /// Calculate impulse for shake event
  static func shakeImpulse() -> SIMD3<Float> {
    let magnitude = PhysicsConfig.shakeImpulse
    return [
      Float.random(in: -0.5...0.5) * magnitude,
      Float.random(in: -1.0 ... -0.5) * magnitude,
      Float.random(in: -0.3...0.3) * magnitude,
    ]
  }

  /// Calculate force from tilt
  static func tiltForce(pitch: Float, roll: Float) -> SIMD3<Float> {
    let multiplier = PhysicsConfig.tiltMultiplier * 0.1
    return [roll * multiplier, 0, pitch * multiplier]
  }

  /// Calculate scatter impulse from drag
  static func dragImpulse(
    coinPosition: SIMD3<Float>,
    dragPosition: SIMD3<Float>,
    dragVelocity: SIMD3<Float>
  ) -> SIMD3<Float>? {
    let distance = simd_distance(coinPosition, dragPosition)
    let radius = PhysicsConfig.dragRadius

    guard distance < radius else { return nil }

    let falloff = 1.0 - (distance / radius)
    let multiplier = PhysicsConfig.dragForceMultiplier

    return dragVelocity * multiplier * falloff
  }

  /// Calculate flick impulse
  static func flickImpulse(
    coinPosition: SIMD3<Float>,
    flickPosition: SIMD3<Float>,
    flickSpeed: Float
  ) -> (impulse: SIMD3<Float>, angular: SIMD3<Float>)? {
    let distance = simd_distance(coinPosition, flickPosition)
    let radius = PhysicsConfig.dragRadius * 1.5

    guard distance < radius else { return nil }

    let falloff = 1.0 - (distance / radius)
    let impulseUp = PhysicsConfig.flickImpulseUp * flickSpeed * falloff
    let angularMag = PhysicsConfig.flickAngularVelocity

    let impulse: SIMD3<Float> = [
      Float.random(in: -0.02...0.02),
      impulseUp,
      Float.random(in: -0.01...0.01),
    ]

    let angular: SIMD3<Float> = [
      Float.random(in: -angularMag...angularMag),
      Float.random(in: -angularMag...angularMag),
      Float.random(in: -angularMag...angularMag),
    ]

    return (impulse, angular)
  }

  /// Calculate radial explosion impulse
  static func explosionImpulse(
    coinPosition: SIMD3<Float>,
    center: SIMD3<Float>,
    magnitude: Float,
    radius: Float
  ) -> SIMD3<Float>? {
    let distance = simd_distance(coinPosition, center)

    guard distance < radius, distance > 0.001 else { return nil }

    let direction = simd_normalize(coinPosition - center)
    let falloff = 1.0 - (distance / radius)

    return direction * magnitude * falloff
  }
}
