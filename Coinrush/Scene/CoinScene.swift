//
//  CoinScene.swift
//  Coinrush
//
//  Main RealityKit scene setup
//

import Combine
import RealityKit
import UIKit

/// Main scene controller for the coin physics playground
class CoinScene: ObservableObject {

  /// The RealityKit anchor
  let anchor: AnchorEntity

  /// All coin entities
  private(set) var coins: [CoinEntity] = []

  /// Special coin manager
  let specialCoinManager = SpecialCoinManager()

  /// Container entity
  private var container: Entity?

  /// Lighting entity
  private var lighting: Entity?

  /// Published state for UI
  @Published var showMessage: Bool = false
  @Published var currentMessage: String = ""

  /// Cancellables
  private var cancellables = Set<AnyCancellable>()

  init() {
    // Create anchor positioned in front of camera
    anchor = AnchorEntity(world: [0, 0, -0.5])

    setupScene()
  }

  private func setupScene() {
    // Create container (invisible walls)
    let containerEntity = SceneContainer.create()
    anchor.addChild(containerEntity)
    self.container = containerEntity

    // Create lighting
    let lightingEntity = SceneLighting.createRandomized()
    anchor.addChild(lightingEntity)
    self.lighting = lightingEntity

    // Spawn coins
    spawnCoins()

    // Select special coin
    specialCoinManager.registerCoins(coins)
    specialCoinManager.selectNewSpecialCoin()

    // Start lighting animation
    setupAnimations()
  }

  private func setupAnimations() {
    // Subscribe to scene updates to rotate lighting for "dancing" reflections
    anchor.scene?.subscribe(to: SceneEvents.Update.self) { [weak self] event in
      guard let self = self, let lighting = self.lighting else { return }

      // Subtle rotation around the Y axis
      let rotation = simd_quatf(angle: Float(event.deltaTime) * 0.2, axis: [0, 1, 0])
      lighting.orientation *= rotation
    }.store(in: &cancellables)
  }

  private func spawnCoins() {
    let count = PhysicsConfig.coinCount
    let width = PhysicsConfig.spawnAreaWidth
    let height = PhysicsConfig.spawnAreaHeight
    let depthVariance = PhysicsConfig.spawnDepthVariance

    for _ in 0..<count {
      let face = SmileyFace.random
      let coin = CoinEntity(smileyFace: face)

      // Random position within spawn area
      let x = Float.random(in: -width / 2...width / 2)
      let y = Float.random(in: -height / 2...height / 2)  // Fill more vertically
      let z = Float.random(in: -depthVariance...depthVariance)
      coin.position = [x, y, z]

      // Random initial rotation
      let rotX = Float.random(in: 0...Float.pi * 2)
      let rotY = Float.random(in: 0...Float.pi * 2)
      let rotZ = Float.random(in: 0...Float.pi * 2)
      coin.transform.rotation =
        simd_quatf(angle: rotX, axis: [1, 0, 0]) * simd_quatf(angle: rotY, axis: [0, 1, 0])
        * simd_quatf(angle: rotZ, axis: [0, 0, 1])

      anchor.addChild(coin)
      coins.append(coin)
    }
  }

  /// Reset the scene by clearing and respawning coins
  func resetScene() {
    // Remove all coins from anchor
    for coin in coins {
      coin.removeFromParent()
    }
    coins.removeAll()

    // Respawn them
    spawnCoins()

    // Register with special coin manager
    specialCoinManager.registerCoins(coins)
    specialCoinManager.selectNewSpecialCoin()

    // Show a quick message
    currentMessage = "RELOADED! 🪙"
    showMessage = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
      self?.showMessage = false
    }
  }

  // MARK: - Interactions

  /// Apply shake force to all coins
  func applyShake() {
    let impulse = PhysicsConfig.shakeImpulse

    for coin in coins {
      // Random downward + outward impulse
      let dx = Float.random(in: -0.5...0.5) * impulse
      let dy = Float.random(in: -1.0 ... -0.5) * impulse
      let dz = Float.random(in: -0.3...0.3) * impulse
      coin.applyImpulse([dx, dy, dz])
    }
  }

  /// Apply tilt gravity adjustment
  func applyTilt(pitch: Float, roll: Float) {
    // Gravity is handled by RealityKit's physics system
    // We apply continuous forces based on tilt
    let multiplier = PhysicsConfig.tiltMultiplier

    for coin in coins {
      let forceX = roll * multiplier * 0.1
      let forceZ = pitch * multiplier * 0.1
      coin.addForce([forceX, 0, forceZ], relativeTo: nil)
    }
  }

  /// Apply drag scatter force
  func applyDrag(at position: SIMD3<Float>, velocity: SIMD3<Float>) {
    let radius = PhysicsConfig.dragRadius
    let multiplier = PhysicsConfig.dragForceMultiplier

    for coin in coins {
      let distance = simd_distance(coin.position, position)
      if distance < radius {
        // Force decreases with distance
        let falloff = 1.0 - (distance / radius)
        let force = velocity * multiplier * falloff
        coin.applyImpulse(force)
      }
    }
  }

  /// Apply flick upward force
  func applyFlick(at position: SIMD3<Float>, velocity: Float) {
    let radius = PhysicsConfig.dragRadius * 1.5
    let impulseUp = PhysicsConfig.flickImpulseUp * velocity
    let angularMag = PhysicsConfig.flickAngularVelocity

    for coin in coins {
      let distance = simd_distance(coin.position, position)
      if distance < radius {
        let falloff = 1.0 - (distance / radius)

        // Upward impulse
        let impulse: SIMD3<Float> = [
          Float.random(in: -0.02...0.02),
          impulseUp * falloff,
          Float.random(in: -0.01...0.01),
        ]
        coin.applyImpulse(impulse)

        // Angular velocity for tumbling
        let angular: SIMD3<Float> = [
          Float.random(in: -angularMag...angularMag),
          Float.random(in: -angularMag...angularMag),
          Float.random(in: -angularMag...angularMag),
        ]
        coin.applyAngularVelocity(angular)
      }
    }
  }

  /// Handle tap on special coin
  func handleSpecialCoinTap(_ coin: CoinEntity) {
    guard coin.isSpecial else { return }

    // Freeze physics
    coin.freezePhysics()

    // Store original position
    let originalPosition = coin.position

    // Animate forward
    var targetPosition = originalPosition
    targetPosition.z += PhysicsConfig.specialCoinZoomDistance

    // Show message
    currentMessage = specialCoinManager.randomMessage()
    showMessage = true

    // Animation sequence
    DispatchQueue.main.asyncAfter(deadline: .now() + PhysicsConfig.specialCoinAnimationDuration) {
      [weak self] in
      // Return to original position
      coin.position = originalPosition
      coin.resumePhysics()

      // Hide message after delay
      DispatchQueue.main.asyncAfter(deadline: .now() + PhysicsConfig.messageDisplayDuration) {
        self?.showMessage = false

        // Select new special coin
        self?.specialCoinManager.selectNewSpecialCoin()
      }
    }

    // Animate position (simple linear for now)
    coin.position = targetPosition
  }

  /// Find coin at screen position
  func findCoin(at screenPosition: CGPoint, in arView: ARView) -> CoinEntity? {
    let results = arView.hitTest(screenPosition, query: .nearest, mask: .default)

    for result in results {
      if let coin = result.entity as? CoinEntity {
        return coin
      }
      // Check parent entities
      var current = result.entity.parent
      while let parent = current {
        if let coin = parent as? CoinEntity {
          return coin
        }
        current = parent.parent
      }
    }
    return nil
  }

  /// Convert screen position to world position
  func screenToWorld(screenPosition: CGPoint, in arView: ARView) -> SIMD3<Float> {
    // Simple projection - assumes coins are near z = 0 relative to anchor
    let viewSize = arView.bounds.size

    let normalizedX = Float((screenPosition.x / viewSize.width) - 0.5)
    let normalizedY = Float(0.5 - (screenPosition.y / viewSize.height))

    let worldX = normalizedX * PhysicsConfig.containerWidth
    let worldY = normalizedY * PhysicsConfig.containerHeight

    return [worldX, worldY, 0]
  }
}
