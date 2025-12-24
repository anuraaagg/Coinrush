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
        // Dimmed background
        Color.black.opacity(0.4)
          .ignoresSafeArea()
          .onTapGesture { onDismiss() }
          .transition(.opacity)

        // The Modal
        VStack(spacing: 16) {
          // Anime Icon/Visual element
          Text("🏮")
            .font(.system(size: 40))

          Text("\"\(quote.quote)\"")
            .font(.system(size: 18, weight: .bold, design: .serif))
            .italic()
            .multilineTextAlignment(.center)
            .foregroundColor(.white)

          VStack(spacing: 4) {
            Text(quote.character)
              .font(.system(size: 14, weight: .heavy, design: .rounded))
              .foregroundColor(.systemPurple)

            Text(quote.series)
              .font(.system(size: 12, weight: .medium, design: .rounded))
              .foregroundColor(.white.opacity(0.6))
          }

          Button(action: onDismiss) {
            Text("GANBARE! 🚀")
              .font(.system(size: 14, weight: .black))
              .foregroundColor(.white)
              .padding(.horizontal, 24)
              .padding(.vertical, 12)
              .background(
                Capsule()
                  .fill(
                    LinearGradient(
                      colors: [.systemPurple, .systemPink], startPoint: .leading,
                      endPoint: .trailing))
              )
          }
          .padding(.top, 8)
        }
        .padding(32)
        .background(
          ZStack {
            RoundedRectangle(cornerRadius: 32)
              .fill(.ultraThinMaterial)
              .environment(\.colorScheme, .dark)

            RoundedRectangle(cornerRadius: 32)
              .strokeBorder(
                LinearGradient(
                  colors: [.white.opacity(0.5), .clear, .white.opacity(0.2)],
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                ),
                lineWidth: 1
              )
          }
        )
        .padding(.horizontal, 40)
        .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 20)
        .transition(
          .asymmetric(
            insertion: .scale(scale: 0.8).combined(with: .opacity),
            removal: .scale(scale: 0.9).combined(with: .opacity)))
      }
    }
    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isPresented)
  }
}
