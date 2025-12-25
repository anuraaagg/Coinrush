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

  // Anime Quote Modal state
  @Published var showQuoteModal: Bool = false
  @Published var currentQuote: AnimeQuote = AnimeQuoteManager.random()

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
    // Subscribe to scene updates
    anchor.scene?.subscribe(to: SceneEvents.Update.self) { [weak self] event in
      guard let self = self, let lighting = self.lighting else { return }

      // 1. Subtle lighting rotation
      let rotation = simd_quatf(angle: Float(event.deltaTime) * 0.2, axis: [0, 1, 0])
      lighting.orientation *= rotation

      // 2. Animate special coin if active
      if let special = self.specialCoinManager.currentSpecialCoin {
        special.updateAnimation(deltaTime: Double(event.deltaTime))
      }
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

  /// Apply tilt force to all coins
  func applyTilt(pitch: Float, roll: Float) {
    // We apply small impulses based on tilt for a "flowing" effect
    let strength = PhysicsConfig.tiltMultiplier * 0.2
    for coin in coins {
      let forceX = roll * strength
      let forceY = -pitch * strength
      coin.applyImpulse([forceX, forceY, 0])
    }
  }

  /// Apply drag scatter force
  func applyDrag(at position: SIMD3<Float>, velocity: SIMD3<Float>) {
    let radius = PhysicsConfig.dragRadius
    let multiplier = PhysicsConfig.dragForceMultiplier

    for coin in coins {
      let distance = simd_distance(coin.position, position)
      if distance < radius {
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

        let impulse: SIMD3<Float> = [
          Float.random(in: -0.05...0.05),
          impulseUp * falloff,
          Float.random(in: -0.02...0.02),
        ]
        coin.applyImpulse(impulse)

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

    // Prepare random quote for modal
    currentQuote = AnimeQuoteManager.random()

    // Show local mini message first
    currentMessage = specialCoinManager.randomMessage()
    showMessage = true

    // Animation sequence
    DispatchQueue.main.asyncAfter(deadline: .now() + PhysicsConfig.specialCoinAnimationDuration) {
      [weak self] in

      // Return to original position
      coin.position = originalPosition
      coin.resumePhysics()

      // Show the anime quote modal
      // We don't mark as found yet, so it stays purple in the background
      self?.showQuoteModal = true

      // Hide the mini "BINGO!" message
      self?.showMessage = false
    }

    // Animate position
    coin.position = targetPosition
  }

  /// Handle dismissal of the quote modal
  func dismissQuoteModal() {
    showQuoteModal = false

    // Mark current as found (clears its special status)
    specialCoinManager.markAsFound()

    // Immediately select a NEW one so there is always one to find
    // This satisfies "visible once everytime until clicked"
    specialCoinManager.selectNewSpecialCoin()
  }

  /// Find coin at screen position
  func findCoin(at screenPosition: CGPoint, in arView: ARView) -> CoinEntity? {
    // Using hitTest without mask for broader detection
    let results = arView.hitTest(screenPosition)

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
