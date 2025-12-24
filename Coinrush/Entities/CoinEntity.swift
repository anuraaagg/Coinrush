//
//  CoinEntity.swift
//  Coinrush
//
//  Procedural coin entity creation with textured faces
//

import RealityKit
import UIKit

/// Available smiley face textures
enum SmileyFace: String, CaseIterable {
  case smiley1
  case smiley2
  case smiley3
  case smiley4

  static var random: SmileyFace {
    allCases.randomElement() ?? .smiley1
  }
}

/// Represents a single coin entity with procedural geometry and textured face
class CoinEntity: Entity, HasModel, HasPhysics, HasCollision {

  /// Whether this is the special tappable coin
  var isSpecial: Bool = false

  /// Unique identifier for this coin
  let coinId: UUID = UUID()

  /// The smiley face assigned to this coin
  private(set) var smileyFace: SmileyFace = .smiley1

  required init() {
    super.init()
  }

  /// Creates a procedural coin with physics and texture
  /// - Parameters:
  ///   - smileyFace: The smiley face texture to use
  ///   - isSpecial: Whether this is the special coin
  convenience init(smileyFace: SmileyFace, isSpecial: Bool = false) {
    self.init()
    self.isSpecial = isSpecial
    self.smileyFace = smileyFace
    setupCoin()
  }

  private func setupCoin() {
    let height = PhysicsConfig.randomCoinHeight
    let radius = PhysicsConfig.coinRadius

    // Create cylinder mesh for coin
    let mesh = MeshResource.generateCylinder(height: height, radius: radius)

    // Create textured material from smiley face
    let textureName = isSpecial ? "smileySpecial" : smileyFace.rawValue
    let material = createTexturedMaterial(named: textureName)

    // Apply model with textured material
    self.model = ModelComponent(mesh: mesh, materials: [material])

    // Setup physics
    setupPhysics(height: height, radius: radius)

    // Setup collision for tap detection
    let shape = ShapeResource.generateCapsule(height: height, radius: radius)
    self.collision = CollisionComponent(shapes: [shape])

    // Lay coin flat (face-up)
    self.transform.rotation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
  }

  private func createTexturedMaterial(named textureName: String) -> Material {
    // Try to load texture from assets
    if let uiImage = UIImage(named: textureName),
      let cgImage = uiImage.cgImage,
      let texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
    {
      var material = PhysicallyBasedMaterial()
      material.baseColor = .init(tint: .white, texture: .init(texture))
      material.metallic = .init(floatLiteral: 0.1) // Subtle metallic
      material.roughness = .init(floatLiteral: 0.2) // Sleek but not mirror-like
      return material
    }

    // Fallback to solid color if texture loading fails
    var fallbackMaterial = PhysicallyBasedMaterial()
    fallbackMaterial.baseColor = .init(tint: isSpecial ? .green : .systemPink)
    fallbackMaterial.metallic = .init(floatLiteral: 0.8)
    fallbackMaterial.roughness = .init(floatLiteral: 0.3)
    return fallbackMaterial
  }

  private func setupPhysics(height: Float, radius: Float) {
    let shape = ShapeResource.generateCapsule(height: height, radius: radius)

    var physicsBody = PhysicsBodyComponent(
      shapes: [shape],
      mass: PhysicsConfig.mass,
      material: PhysicsMaterialResource.generate(
        friction: PhysicsConfig.friction,
        restitution: PhysicsConfig.restitution
      ),
      mode: .dynamic
    )

    physicsBody.linearDamping = PhysicsConfig.linearDamping
    physicsBody.angularDamping = PhysicsConfig.angularDamping

    self.physicsBody = physicsBody

    // Initialize physics motion for velocity control
    self.physicsMotion = PhysicsMotionComponent()
  }

  /// Apply an impulse to the coin
  func applyImpulse(_ impulse: SIMD3<Float>) {
    guard self.physicsBody != nil else { return }
    // Use applyLinearImpulse for instant velocity change
    self.applyLinearImpulse(impulse, relativeTo: nil)
  }

  /// Apply angular velocity
  func applyAngularVelocity(_ velocity: SIMD3<Float>) {
    guard var motion = self.physicsMotion else { return }
    motion.angularVelocity += velocity
    self.physicsMotion = motion
  }

  /// Update texture for special coin selection
  func setSpecial(_ special: Bool) {
    self.isSpecial = special

    // Update material
    let textureName = special ? "smileySpecial" : smileyFace.rawValue
    let material = createTexturedMaterial(named: textureName)

    if let mesh = self.model?.mesh {
      self.model = ModelComponent(mesh: mesh, materials: [material])
    }
  }

  /// Freeze physics temporarily
  func freezePhysics() {
    guard var physics = self.physicsBody else { return }
    physics.mode = .kinematic
    self.physicsBody = physics
  }

  /// Resume physics
  func resumePhysics() {
    guard var physics = self.physicsBody else { return }
    physics.mode = .dynamic
    self.physicsBody = physics
  }
}
