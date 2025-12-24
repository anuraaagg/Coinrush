import SwiftUI

/// A beautiful anime quote service
struct AnimeQuote {
  let quote: String
  let character: String
  let series: String
}

class AnimeQuoteManager {
  static let quotes: [AnimeQuote] = [
    AnimeQuote(
      quote:
        "It's not the face that makes someone a monster, it's the choices they make with their lives.",
      character: "Naruto Uzumaki", series: "Naruto"),
    AnimeQuote(
      quote:
        "Whatever you lose, you'll find it again. But what you throw away you'll never get back.",
      character: "Himura Kenshin", series: "Rurouni Kenshin"),
    AnimeQuote(
      quote: "Power comes in response to a need, not a desire. You have to create that need.",
      character: "Goku", series: "Dragon Ball Z"),
    AnimeQuote(
      quote:
        "If you don’t like your destiny, don’t accept it. Instead, have the courage to change it.",
      character: "Naruto Uzumaki", series: "Naruto"),
    AnimeQuote(
      quote: "A person can change, at the moment when the person wishes to change.",
      character: "Haruhi Fujioka", series: "Ouran High School Host Club"),
    AnimeQuote(
      quote: "Hard work is worthless for those that don’t believe in themselves.",
      character: "Naruto Uzumaki", series: "Naruto"),
    AnimeQuote(
      quote:
        "To know sorrow is not terrifying. What is terrifying is to know you can't go back to happiness you could have.",
      character: "Matsumoto Rangiku", series: "Bleach"),
    AnimeQuote(quote: "Giving up is what kills people.", character: "Alucard", series: "Hellsing"),
    AnimeQuote(
      quote:
        "The world isn’t perfect. But it’s there for us, doing the best it can….that’s what makes it so damn beautiful.",
      character: "Roy Mustang", series: "Fullmetal Alchemist"),
    AnimeQuote(
      quote: "If you don't take risks, you can't create a future.", character: "Monkey D. Luffy",
      series: "One Piece"),
  ]

  static func random() -> AnimeQuote {
    quotes.randomElement()!
  }
}

/// A premium liquid glass modal for anime motivation
struct QuoteModal: View {
  let quote: AnimeQuote
  let isPresented: Bool
  let onDismiss: () -> Void

  var body: some View {
    ZStack {
      if isPresented {
        // Full screen background gradient matching the reference image aesthetics
        LinearGradient(
          colors: [
            Color(red: 1.0, green: 0.95, blue: 0.9),
            Color(red: 1.0, green: 0.85, blue: 0.85),
            Color(red: 0.9, green: 0.8, blue: 0.9),
          ],
          startPoint: .topLeading,
          endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        .transition(.opacity)

        VStack(spacing: 32) {
          // Navigation / Dismiss button top left (optional, but in image)
          HStack {
            Button(action: onDismiss) {
              Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black.opacity(0.6))
            }
            Spacer()
          }
          .padding(.horizontal, 24)
          .padding(.top, 20)

          // Header and Subheader
          VStack(spacing: 12) {
            Text("You found the coin")
              .font(.system(size: 32, weight: .semibold, design: .default))
              .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
              .multilineTextAlignment(.center)

            Text("here is something for you")
              .font(.system(size: 18, weight: .regular, design: .default))
              .foregroundColor(.black.opacity(0.5))
              .multilineTextAlignment(.center)
          }
          .padding(.top, 20)

          // Tilted Card with Quote
          VStack(alignment: .leading, spacing: 16) {
            Text(quote.quote)
              .font(.system(size: 20, weight: .medium, design: .default))
              .lineSpacing(6)
              .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))

            HStack {
              Spacer()
              VStack(alignment: .trailing, spacing: 2) {
                Text("— \(quote.character)")
                  .font(.system(size: 14, weight: .bold))
                  .foregroundColor(.purple)
                Text(quote.series)
                  .font(.system(size: 12, weight: .regular))
                  .foregroundColor(.black.opacity(0.4))
              }
            }
          }
          .padding(32)
          .frame(maxWidth: .infinity)
          .background(
            RoundedRectangle(cornerRadius: 32)
              .fill(Color.white)
              .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
          )
          .padding(.horizontal, 32)
          .rotationEffect(.degrees(-3))  // Tilted card effect
          .padding(.top, 20)

          Spacer()

          // Bottom Action
          Button(action: onDismiss) {
            Text("Continue")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 18)
              .background(
                Capsule()
                  .fill(Color.black.opacity(0.8))
              )
              .padding(.horizontal, 40)
          }
          .padding(.bottom, 40)
        }
      }
    }
    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
  }
}
