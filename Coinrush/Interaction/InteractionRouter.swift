//
//  InteractionRouter.swift
//  Coinrush
//
//  Coordinates all interaction inputs
//

import Combine
import Foundation
import RealityKit

/// Routes interaction events to the scene
class InteractionRouter: ObservableObject {

  /// Managers
  let motionManager = MotionManager()
  let gestureHandler = GestureHandler()

  /// Scene reference
  weak var scene: CoinScene?

  /// ARView reference
  weak var arView: ARView?

  /// Tilt update throttle
  private var lastTiltUpdate: Date = .distantPast
  private let tiltUpdateInterval: TimeInterval = 1.0 / 30.0

  /// Setup interaction routing
  func setup(scene: CoinScene, arView: ARView) {
    self.scene = scene
    self.arView = arView

    // Setup motion callbacks
    motionManager.onShake = { [weak self] in
      self?.handleShake()
    }

    motionManager.onTilt = { [weak self] pitch, roll in
      self?.handleTilt(pitch: pitch, roll: roll)
    }

    // Setup gesture handling
    arView.setupCoinGestures(scene: scene, handler: gestureHandler)

    // Start motion monitoring
    motionManager.start()
  }

  /// Stop all interaction monitoring
  func stop() {
    motionManager.stop()
  }

  private func handleShake() {
    scene?.resetScene()
    HapticsManager.shared.playReset()
  }

  private func handleTilt(pitch: Float, roll: Float) {
    // Throttle tilt updates
    let now = Date()
    guard now.timeIntervalSince(lastTiltUpdate) > tiltUpdateInterval else { return }
    lastTiltUpdate = now

    scene?.applyTilt(pitch: pitch, roll: roll)
  }
}
