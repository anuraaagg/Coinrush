//
//  SceneContainer.swift
//  Coinrush
//
//  Invisible walls and floor for coin containment
//

import RealityKit

/// Creates invisible bounding walls for the coin container
class SceneContainer {

  private var walls: [Entity] = []

  /// Creates the container with floor and walls (open top)
  /// - Returns: Entity containing all wall entities
  static func create() -> Entity {
    let container = Entity()

    let width = PhysicsConfig.containerWidth
    let height = PhysicsConfig.containerHeight
    let depth = PhysicsConfig.containerDepth
    let thickness = PhysicsConfig.wallThickness

    // Floor
    let floor = createWall(
      width: width,
      height: thickness,
      depth: depth,
      position: [0, -height / 2, 0]
    )
    container.addChild(floor)

    // Left wall
    let leftWall = createWall(
      width: thickness,
      height: height,
      depth: depth,
      position: [-width / 2, 0, 0]
    )
    container.addChild(leftWall)

    // Right wall
    let rightWall = createWall(
      width: thickness,
      height: height,
      depth: depth,
      position: [width / 2, 0, 0]
    )
    container.addChild(rightWall)

    // Back wall
    let backWall = createWall(
      width: width,
      height: height,
      depth: thickness,
      position: [0, 0, -depth / 2]
    )
    container.addChild(backWall)

    // Front wall (invisible, keeps coins on screen)
    let frontWall = createWall(
      width: width,
      height: height,
      depth: thickness,
      position: [0, 0, depth / 2]
    )
    container.addChild(frontWall)

    return container
  }

  /// Creates a single invisible wall with physics
  private static func createWall(
    width: Float,
    height: Float,
    depth: Float,
    position: SIMD3<Float>
  ) -> Entity {
    let wall = Entity()

    // Create collision shape
    let shape = ShapeResource.generateBox(size: [width, height, depth])

    // Static physics body
    let physicsBody = PhysicsBodyComponent(
      shapes: [shape],
      mass: 0,  // Static
      material: PhysicsMaterialResource.generate(
        friction: PhysicsConfig.wallFriction,
        restitution: PhysicsConfig.wallRestitution
      ),
      mode: .static
    )

    wall.components[PhysicsBodyComponent.self] = physicsBody
    wall.components[CollisionComponent.self] = CollisionComponent(shapes: [shape])
    wall.position = position

    return wall
  }
}
