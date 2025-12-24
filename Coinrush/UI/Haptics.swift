//
//  Haptics.swift
//  Coinrush
//
//  CoreHaptics feedback
//

import CoreHaptics
import UIKit

/// Manages haptic feedback
class HapticsManager {

  /// Shared instance
  static let shared = HapticsManager()

  /// Haptic engine
  private var engine: CHHapticEngine?

  /// Whether haptics are supported
  private var supportsHaptics: Bool = false

  private init() {
    setupHaptics()
  }

  private func setupHaptics() {
    guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
      supportsHaptics = false
      return
    }

    do {
      engine = try CHHapticEngine()
      try engine?.start()
      supportsHaptics = true

      // Handle engine reset
      engine?.resetHandler = { [weak self] in
        do {
          try self?.engine?.start()
        } catch {
          print("Failed to restart haptic engine: \(error)")
        }
      }
    } catch {
      print("Failed to create haptic engine: \(error)")
      supportsHaptics = false
    }
  }

  /// Light haptic for shake
  func playShake() {
    guard supportsHaptics else {
      // Fallback to UIKit haptics
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()
      return
    }

    playPattern(intensity: 0.6, sharpness: 0.4, duration: 0.15)
  }

  /// Strong haptic for scene reset
  func playReset() {
    guard supportsHaptics else {
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.success)
      return
    }

    // Double pulse for reset
    playPattern(intensity: 0.8, sharpness: 0.5, duration: 0.1)
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
      self.playPattern(intensity: 1.0, sharpness: 0.7, duration: 0.2)
    }
  }

  /// Light haptic for flick
  func playFlick() {
    guard supportsHaptics else {
      let generator = UIImpactFeedbackGenerator(style: .light)
      generator.impactOccurred()
      return
    }

    playPattern(intensity: 0.4, sharpness: 0.6, duration: 0.1)
  }

  /// Soft haptic for special coin tap
  func playSpecialCoinTap() {
    guard supportsHaptics else {
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.success)
      return
    }

    playPattern(intensity: 0.8, sharpness: 0.3, duration: 0.2)
  }

  /// Subtle haptic for coin collision (not currently used)
  func playCoinCollision() {
    guard supportsHaptics else { return }
    playPattern(intensity: 0.2, sharpness: 0.8, duration: 0.05)
  }

  private func playPattern(intensity: Float, sharpness: Float, duration: TimeInterval) {
    guard let engine = engine else { return }

    let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
    let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

    let event = CHHapticEvent(
      eventType: .hapticTransient,
      parameters: [intensityParam, sharpnessParam],
      relativeTime: 0,
      duration: duration
    )

    do {
      let pattern = try CHHapticPattern(events: [event], parameters: [])
      let player = try engine.makePlayer(with: pattern)
      try player.start(atTime: CHHapticTimeImmediate)
    } catch {
      print("Failed to play haptic: \(error)")
    }
  }
}
