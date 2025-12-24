//
//  PhysicsConfig.swift
//  Coinrush
//
//  Physics configuration constants for coin behavior
//

import Foundation
import RealityKit

/// Central configuration for all physics values.
/// Tweak these to adjust the feel of the toy.
struct PhysicsConfig {

  // MARK: - Coin Dimensions
  static let coinRadius: Float = 0.075  // Made 2.5x bigger
  static let coinHeightMin: Float = 0.015  // Much thicker
  static let coinHeightMax: Float = 0.02  // Much thicker

  // MARK: - Coin Spawning
  static let coinCount: Int = 45  // Optimal number for performance and fun
  static let spawnAreaWidth: Float = 0.4  // Matches container
  static let spawnAreaHeight: Float = 0.6  // Matches container
  static let spawnDepthVariance: Float = 0.05  // Less depth cluster

  // MARK: - Physics Body
  static let mass: Float = 0.3  // Slightly weightier
  static let friction: Float = 0.5  // Lower friction for more slide
  static let restitution: Float = 0.2  // Slightly more bounce
  static let linearDamping: Float = 0.5  // Much lower for "fluid" motion
  static let angularDamping: Float = 0.6  // Much lower for faster rotation

  // MARK: - Gravity
  static let baseGravity: Float = -9.8
  static let tiltMultiplier: Float = 0.5  // More aggressive tilt response
  static let shakeGravityMin: Float = -18.0
  static let shakeGravityMax: Float = -22.0
  static let shakeDuration: TimeInterval = 0.5

  // MARK: - Container (Invisible Walls)
  static let containerWidth: Float = 0.45  // Wider container
  static let containerHeight: Float = 0.7  // Taller container
  static let containerDepth: Float = 0.25  // Deeper container
  static let wallThickness: Float = 0.01
  static let wallFriction: Float = 0.9
  static let wallRestitution: Float = 0.0

  // MARK: - Interaction Forces
  static let shakeImpulse: Float = 0.15
  static let flickImpulseUp: Float = 0.15
  static let flickAngularVelocity: Float = 8.0
  static let dragForceMultiplier: Float = 0.1  // Much faster drag
  static let dragRadius: Float = 0.18  // Bigger interaction area

  // MARK: - Animation
  static let specialCoinZoomDistance: Float = 0.1
  static let specialCoinAnimationDuration: TimeInterval = 0.6
  static let messageFadeDuration: TimeInterval = 0.4
  static let messageDisplayDuration: TimeInterval = 2.0

  // MARK: - Random Variance
  static var randomCoinHeight: Float {
    Float.random(in: coinHeightMin...coinHeightMax)
  }

  static var randomShakeGravity: Float {
    Float.random(in: shakeGravityMax...shakeGravityMin)
  }
}
