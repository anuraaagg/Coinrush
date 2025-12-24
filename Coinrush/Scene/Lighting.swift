//
//  Lighting.swift
//  Coinrush
//
//  Scene lighting configuration
//

import RealityKit
import UIKit

/// Configures lighting for the coin scene
struct SceneLighting {

  /// Creates lighting entities for the scene
  /// - Returns: Entity containing all lights
  static func create() -> Entity {
    let lightContainer = Entity()

    // Directional light (main light)
    let directionalLight = DirectionalLight()
    directionalLight.light.color = .white
    directionalLight.light.intensity = 2000
    directionalLight.light.isRealWorldProxy = false

    // Slight angle for depth
    directionalLight.look(
      at: [0, 0, 0],
      from: [0.5, 1.0, 0.8],
      relativeTo: nil
    )
    lightContainer.addChild(directionalLight)

    // Point light for ambient fill
    let pointLight = PointLight()
    pointLight.light.color = .white
    pointLight.light.intensity = 800
    pointLight.light.attenuationRadius = 2.0
    pointLight.position = [0, 0.3, 0.2]
    lightContainer.addChild(pointLight)

    return lightContainer
  }

  /// Creates randomized lighting for session variety
  static func createRandomized() -> Entity {
    let lightContainer = Entity()

    // Random directional light angle
    let xOffset = Float.random(in: -0.5...0.5)
    let yOffset = Float.random(in: 0.8...1.2)
    let zOffset = Float.random(in: 0.5...1.0)

    let directionalLight = DirectionalLight()
    directionalLight.light.color = .white
    directionalLight.light.intensity = Float.random(in: 1800...2200)
    directionalLight.light.isRealWorldProxy = false
    directionalLight.look(
      at: [0, 0, 0],
      from: [xOffset, yOffset, zOffset],
      relativeTo: nil
    )
    lightContainer.addChild(directionalLight)

    // Ambient fill
    let pointLight = PointLight()
    pointLight.light.color = .white
    pointLight.light.intensity = Float.random(in: 600...1000)
    pointLight.light.attenuationRadius = 2.0
    pointLight.position = [0, 0.3, 0.2]
    lightContainer.addChild(pointLight)

    // FUN: Add "Rim/Disco Lights" for metallic highlights
    // Cyan light from the left
    let cyanLight = PointLight()
    cyanLight.light.color = .cyan
    cyanLight.light.intensity = 1500
    cyanLight.position = [-0.4, 0.2, 0.3]
    lightContainer.addChild(cyanLight)

    // Magenta light from the right
    let magentaLight = PointLight()
    magentaLight.light.color = .magenta
    magentaLight.light.intensity = 1500
    magentaLight.position = [0.4, 0.1, 0.3]
    lightContainer.addChild(magentaLight)

    return lightContainer
  }
}
