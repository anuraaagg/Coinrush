//
//  GestureHandler.swift
//  Coinrush
//
//  Touch gesture handling for drag, flick, and tap
//

import Combine
import RealityKit
import UIKit

/// Handles touch gestures for coin interaction
class GestureHandler: NSObject {

  /// Reference to ARView
  weak var arView: ARView?

  /// Reference to scene
  weak var scene: CoinScene?

  /// Gesture state tracking
  private var touchStartPosition: CGPoint = .zero
  private var touchStartTime: Date = Date()
  private var lastTouchPosition: CGPoint = .zero
  private var lastTouchTime: Date = Date()

  /// Gesture thresholds
  private let tapDistanceThreshold: CGFloat = 10.0
  private let tapTimeThreshold: TimeInterval = 0.3

  /// Drag tracking
  private var isDragging = false

  /// Callbacks
  var onDrag: ((CGPoint, CGPoint) -> Void)?
  var onTap: ((CGPoint) -> Void)?

  /// Setup gestures on the view
  func setupGestures(on arView: ARView) {
    self.arView = arView

    // Pan gesture for drag/flick
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    arView.addGestureRecognizer(panGesture)

    // Tap gesture
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    arView.addGestureRecognizer(tapGesture)
  }

  @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    guard let arView = arView else { return }

    let position = gesture.location(in: arView)
    let velocity = gesture.velocity(in: arView)

    switch gesture.state {
    case .began:
      touchStartPosition = position
      touchStartTime = Date()
      lastTouchPosition = position
      lastTouchTime = Date()
      isDragging = true

    case .changed:
      if isDragging {
        onDrag?(lastTouchPosition, position)
        lastTouchPosition = position
        lastTouchTime = Date()
      }

    case .ended, .cancelled:
      isDragging = false

    default:
      break
    }
  }

  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    guard gesture.state == .ended else { return }

    let position = gesture.location(in: arView)
    onTap?(position)
  }
}

// MARK: - ARView Gesture Extension
extension ARView {

  /// Setup coin interaction gestures
  func setupCoinGestures(scene: CoinScene, handler: GestureHandler) {
    handler.arView = self
    handler.scene = scene
    handler.setupGestures(on: self)

    // Configure callbacks
    handler.onTap = { [weak self, weak scene] position in
      guard let self = self, let scene = scene else { return }

      if let coin = scene.findCoin(at: position, in: self) {
        if coin.isSpecial {
          HapticsManager.shared.playSpecialCoinTap()
          scene.handleSpecialCoinTap(coin)
        }
      }
    }

    // Configure callbacks
    handler.onDrag = { [weak self, weak scene] from, to in
      guard let self = self, let scene = scene else { return }

      let worldFrom = scene.screenToWorld(screenPosition: from, in: self)
      let worldTo = scene.screenToWorld(screenPosition: to, in: self)
      let velocity = worldTo - worldFrom

      scene.applyDrag(at: worldTo, velocity: velocity * 50)
    }
  }
}

// MARK: - Float Clamping
extension Float {
  func clamped(to range: ClosedRange<Float>) -> Float {
    return min(max(self, range.lowerBound), range.upperBound)
  }
}
