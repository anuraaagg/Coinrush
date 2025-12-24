//
//  MessageOverlay.swift
//  Coinrush
//
//  Minimal message display for special coin
//

import SwiftUI

/// Overlay view for special coin messages
struct MessageOverlay: View {

  let message: String
  let isVisible: Bool

  var body: some View {
    Text(message)
      .font(.system(size: 12, weight: .bold, design: .rounded))
      .foregroundColor(.white.opacity(0.8))
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(
        ZStack {
          // Liquid glass base
          Capsule()
            .fill(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)

          // Subtle inner glow
          Capsule()
            .fill(
              LinearGradient(
                colors: [.white.opacity(0.1), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
        }
      )
      .clipShape(Capsule())
      .overlay(
        // Sharp glass edge
        Capsule()
          .strokeBorder(
            LinearGradient(
              colors: [.white.opacity(0.4), .white.opacity(0.1), .clear],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 0.5
          )
      )
      .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
      .opacity(isVisible ? 1.0 : 0.0)
      .scaleEffect(isVisible ? 1.0 : 0.9)
      .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isVisible)
  }
}

#Preview {
  ZStack {
    Color.black
    MessageOverlay(message: "you found me", isVisible: true)
  }
}
