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

  static var random: SmileyFace {
    allCases.randomElement() ?? .smiley1
  }
}

/// Represents a single coin entity with procedural geometry and textured face
class CoinEntity: Entity, HasModel, HasPhysics, HasCollision {

  /// Whether this is the special tappable coin
  var isSpecial: Bool = false {
    didSet {
      updateSpecialVisuals()
    }
  }

  /// Point light for special coin glow
  private var specialLight: Entity?

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

    // 1. Setup the Rim (main model)
    let rimMesh = MeshResource.generateCylinder(height: height, radius: radius)
    let rimMaterial = createRimMaterial()
    self.model = ModelComponent(mesh: rimMesh, materials: [rimMaterial])

    // 2. Setup the Faces
    updateFaces(height: height, radius: radius)

    // 3. Setup Physics & Collision
    setupPhysics(height: height, radius: radius)

    // Collision for tap detection
    let shape = ShapeResource.generateCapsule(height: height, radius: radius)
    self.collision = CollisionComponent(shapes: [shape])

    // Lay coin flat (face-up)
    self.transform.rotation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
  }

  private func updateFaces(height: Float, radius: Float) {
    // Remove existing faces if any
    self.children.filter { $0.name.contains("face") }.forEach { $0.removeFromParent() }

    let faceTextureName = isSpecial ? "smileySpecial" : smileyFace.rawValue
    let faceMaterial = createTexturedMaterial(named: faceTextureName)

    // Very thin cylinder for the face disk
    // Slightly smaller radius to avoid z-fighting at the edges
    let faceMesh = MeshResource.generateCylinder(height: 0.0002, radius: radius * 0.99)

    // Top Face
    let topFace = ModelEntity(mesh: faceMesh, materials: [faceMaterial])
    topFace.name = "face_top"
    topFace.position = [0, height / 2 + 0.0001, 0]
    self.addChild(topFace)

    // Bottom Face
    let bottomFace = ModelEntity(mesh: faceMesh, materials: [faceMaterial])
    bottomFace.name = "face_bottom"
    bottomFace.position = [0, -height / 2 - 0.0001, 0]
    bottomFace.orientation = simd_quatf(angle: .pi, axis: [1, 0, 0])
    self.addChild(bottomFace)
  }

  private func createRimMaterial() -> Material {
    var material = PhysicallyBasedMaterial()

    // Fun: Randomize the rim color slightly for variety
    let hueShift = Float.random(in: -0.05...0.05)

    if isSpecial {
      // Special coin: Glowing Cosmic Purple
      material.baseColor = .init(tint: .systemPurple)
      material.emissiveColor = .init(color: .systemPurple)
      material.emissiveIntensity = 3.0

      // Ultra-premium metallic properties
      material.metallic = .init(floatLiteral: 1.0)
      material.roughness = .init(floatLiteral: 0.05)  // Very shiny
      material.clearcoat = .init(floatLiteral: 1.0)  // Extra lacquer layer
      material.clearcoatRoughness = .init(floatLiteral: 0.0)  // Perfect reflection
      material.specular = .init(floatLiteral: 1.0)
    } else {
      // Regular coins: Shiny Anodized Metal
      let finalColor = UIColor(
        hue: (0.95 + CGFloat(hueShift)),
        saturation: 0.8,
        brightness: 1.0,
        alpha: 1.0
      )

      material.baseColor = .init(tint: finalColor)
      material.metallic = .init(floatLiteral: 0.95)
      material.roughness = .init(floatLiteral: 0.15)
      material.clearcoat = .init(floatLiteral: 1.0)
      material.clearcoatRoughness = .init(floatLiteral: 0.0)
    }

    return material
  }

  private func createTexturedMaterial(named textureName: String) -> Material {
    // Try to load texture from assets
    if let uiImage = UIImage(named: textureName),
      let cgImage = uiImage.cgImage,
      let texture = try? TextureResource.generate(from: cgImage, options: .init(semantic: .color))
    {
      var material = PhysicallyBasedMaterial()
      let tint: UIColor = isSpecial ? .systemPurple : .white
      material.baseColor = .init(tint: tint, texture: .init(texture))

      if isSpecial {
        material.emissiveColor = .init(color: .systemPurple)
        material.emissiveIntensity = 2.0
      }

      material.metallic = .init(floatLiteral: 0.3)
      material.roughness = .init(floatLiteral: 0.2)
      material.clearcoat = .init(floatLiteral: 0.8)
      material.specular = .init(floatLiteral: 1.0)
      return material
    }

    // Fallback to solid color
    var fallbackMaterial = PhysicallyBasedMaterial()
    if isSpecial {
      // Gold coin with purple glow
      fallbackMaterial.baseColor = .init(tint: .systemYellow)
      fallbackMaterial.emissiveColor = .init(color: .systemPurple)
      fallbackMaterial.emissiveIntensity = 5.0
      fallbackMaterial.metallic = .init(floatLiteral: 1.0)
      fallbackMaterial.roughness = .init(floatLiteral: 0.1)
    } else {
      fallbackMaterial.baseColor = .init(tint: .systemPink)
      fallbackMaterial.metallic = .init(floatLiteral: 0.9)
      fallbackMaterial.roughness = .init(floatLiteral: 0.3)
    }
    fallbackMaterial.clearcoat = .init(floatLiteral: 1.0)
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

  /// Update visuals based on special status
  private func updateSpecialVisuals() {
    // 1. Point Light setup
    if isSpecial {
      if specialLight == nil {
        let light = PointLight()
        light.light.color = .systemPurple
        light.light.intensity = 5000  // Bright enough to illuminate nearby coins
        light.light.attenuationRadius = 0.2
        light.position = [0, 0, 0]
        light.name = "special_light"
        self.addChild(light)
        self.specialLight = light
      }
    } else {
      specialLight?.removeFromParent()
      specialLight = nil
    }

    // 2. Refresh materials
    if let mesh = self.model?.mesh {
      self.model = ModelComponent(mesh: mesh, materials: [createRimMaterial()])
    }
    let height = (self.model?.mesh.bounds.extents.y) ?? PhysicsConfig.coinRadius
    updateFaces(height: height, radius: PhysicsConfig.coinRadius)
  }

  /// Accumulated time for pulse animation
  private var pulsateTime: Double = 0

  /// Pulsate the scale for visual attention
  func updateAnimation(deltaTime: Double) {
    if isSpecial && !isFound {
      pulsateTime += deltaTime
      // Very slow, subtle pulse
      let speed: Double = 3.0
      let amplitude: Float = 0.05
      let scale = 1.0 + amplitude * sin(Float(pulsateTime * speed))
      self.scale = [scale, scale, scale]
    } else {
      self.scale = [1, 1, 1]
      pulsateTime = 0
    }
  }

  private var isFound: Bool {
    // Logic to stop pulse if we are in the middle of a found-animation
    // This will be set by the scene
    return false
  }
}
