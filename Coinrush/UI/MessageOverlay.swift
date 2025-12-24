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
      .font(.system(size: 24, weight: .medium, design: .rounded))
      .foregroundColor(.white)
      .padding(.horizontal, 24)
      .padding(.vertical, 12)
      .background(
        Capsule()
          .fill(.ultraThinMaterial)
          .overlay(
            Capsule()
              .strokeBorder(.white.opacity(0.2), lineWidth: 1)
          )
      )
      .opacity(isVisible ? 1.0 : 0.0)
      .scaleEffect(isVisible ? 1.0 : 0.8)
      .animation(.easeInOut(duration: PhysicsConfig.messageFadeDuration), value: isVisible)
  }
}

#Preview {
  ZStack {
    Color.black
    MessageOverlay(message: "you found me", isVisible: true)
  }
}
