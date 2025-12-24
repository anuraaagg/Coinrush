//
//  RealityKitView.swift
//  Coinrush
//
//  SwiftUI wrapper for ARView
//

import RealityKit
import SwiftUI

/// SwiftUI wrapper for RealityKit ARView
struct RealityKitView: UIViewRepresentable {

  @ObservedObject var scene: CoinScene
  @ObservedObject var interactionRouter: InteractionRouter
  let backgroundColor: UIColor

  func makeUIView(context: Context) -> ARView {
    // Create non-AR view for coin physics
    let arView = ARView(frame: .zero)

    // Configure for non-AR rendering
    arView.environment.background = .color(backgroundColor)
    arView.cameraMode = .nonAR

    // Position camera
    let cameraAnchor = AnchorEntity(world: .zero)
    let camera = PerspectiveCamera()
    camera.position = [0, 0, 0.5]
    cameraAnchor.addChild(camera)
    arView.scene.addAnchor(cameraAnchor)

    // Add scene anchor
    arView.scene.addAnchor(scene.anchor)

    // Setup interactions
    interactionRouter.setup(scene: scene, arView: arView)

    return arView
  }

  func updateUIView(_ uiView: ARView, context: Context) {
    // Update background if needed
    uiView.environment.background = .color(backgroundColor)
  }

  static func dismantleUIView(_ uiView: ARView, coordinator: ()) {
    // Cleanup
  }
}
