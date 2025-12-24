//
//  ContentView.swift
//  Coinrush
//
//  Main view for Coin Toy
//

import RealityKit
import SwiftUI

struct ContentView: View {

  /// Scene controller
  @StateObject private var scene = CoinScene()

  /// Interaction router
  @StateObject private var interactionRouter = InteractionRouter()

  /// Random background color for session
  @State private var backgroundColor: UIColor = BackgroundPalette.randomColor()

  var body: some View {
    ZStack {
      // RealityKit view
      RealityKitView(
        scene: scene,
        interactionRouter: interactionRouter,
        backgroundColor: backgroundColor
      )
      .ignoresSafeArea()

      // Message overlay
      VStack {
        Spacer()
        MessageOverlay(
          message: scene.currentMessage,
          isVisible: scene.showMessage
        )
        .padding(.bottom, 100)
      }

      // Anime Quote Modal
      QuoteModal(
        quote: scene.currentQuote,
        isPresented: scene.showQuoteModal,
        onDismiss: { scene.showQuoteModal = false }
      )
    }
    .statusBarHidden(true)
    .onDisappear {
      interactionRouter.stop()
    }
  }
}

/// Background color palette
struct BackgroundPalette {

  private static let colors: [UIColor] = [
    UIColor(red: 0.96, green: 0.96, blue: 0.94, alpha: 1.0),  // Warm white
    UIColor(red: 0.94, green: 0.94, blue: 0.96, alpha: 1.0),  // Cool white
    UIColor(red: 0.98, green: 0.95, blue: 0.92, alpha: 1.0),  // Cream
    UIColor(red: 0.92, green: 0.95, blue: 0.98, alpha: 1.0),  // Ice blue
    UIColor(red: 0.95, green: 0.92, blue: 0.95, alpha: 1.0),  // Lavender mist
    UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0),  // Dark mode
    UIColor(red: 0.08, green: 0.10, blue: 0.12, alpha: 1.0),  // Deep dark
  ]

  static func randomColor() -> UIColor {
    colors.randomElement() ?? .white
  }
}

#Preview {
  ContentView()
}
