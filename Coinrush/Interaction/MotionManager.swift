//
//  MotionManager.swift
//  Coinrush
//
//  CoreMotion handling for shake and tilt
//

import Combine
import CoreMotion

/// Manages device motion for shake and tilt detection
class MotionManager: ObservableObject {

  private let motionManager = CMMotionManager()

  /// Published motion data
  @Published var pitch: Float = 0
  @Published var roll: Float = 0
  @Published var isShaking: Bool = false

  /// Shake detection
  private var lastAcceleration: CMAcceleration?
  private let shakeThreshold: Double = 2.5
  private var shakeDebounce: Date = .distantPast
  private let shakeDebounceInterval: TimeInterval = 0.5

  /// Callbacks
  var onShake: (() -> Void)?
  var onTilt: ((Float, Float) -> Void)?

  /// Start monitoring motion
  func start() {
    guard motionManager.isDeviceMotionAvailable else {
      print("Device motion not available")
      return
    }

    motionManager.deviceMotionUpdateInterval = 1.0 / 60.0

    motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
      guard let self = self, let motion = motion else { return }

      // Update tilt
      self.pitch = Float(motion.attitude.pitch)
      self.roll = Float(motion.attitude.roll)
      self.onTilt?(self.pitch, self.roll)

      // Check for shake
      self.detectShake(acceleration: motion.userAcceleration)
    }
  }

  /// Stop monitoring motion
  func stop() {
    motionManager.stopDeviceMotionUpdates()
  }

  private func detectShake(acceleration: CMAcceleration) {
    let magnitude = sqrt(
      acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z
        * acceleration.z
    )

    if magnitude > shakeThreshold {
      let now = Date()
      if now.timeIntervalSince(shakeDebounce) > shakeDebounceInterval {
        shakeDebounce = now
        isShaking = true
        onShake?()

        // Reset shake state after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + PhysicsConfig.shakeDuration) {
          self.isShaking = false
        }
      }
    }
  }
}
