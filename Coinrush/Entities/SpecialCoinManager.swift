//
//  SpecialCoinManager.swift
//  Coinrush
//
//  Manages the special tappable coin
//

import UIKit

/// Manages which coin is the special interactive coin
class SpecialCoinManager {

  /// Messages displayed when special coin is tapped
  /// Initial discovery catchphrases
  private static let messages: [String] = [
    "GOTCHA! 💥",
    "BINGO! 🎯",
    "YES! ✨",
    "POW! ⚡️",
    "FOUND! 🪙",
  ]

  /// Current special coin
  private(set) var currentSpecialCoin: CoinEntity?

  /// All available coins
  private var coins: [CoinEntity] = []

  /// Whether the special coin has already been found in this session
  private(set) var hasFoundSpecialThisSession: Bool = false

  /// Registers coins for management
  func registerCoins(_ coins: [CoinEntity]) {
    self.coins = coins
    self.hasFoundSpecialThisSession = false
  }

  /// Selects a new random special coin
  /// - Returns: The newly selected special coin
  @discardableResult
  func selectNewSpecialCoin() -> CoinEntity? {
    // Reset state
    hasFoundSpecialThisSession = false

    // Reset previous special coin
    if let previous = currentSpecialCoin {
      previous.setSpecial(false)
    }

    // Select new special coin
    guard !coins.isEmpty else { return nil }

    let availableCoins = coins
    guard let newSpecial = availableCoins.randomElement() else { return nil }

    newSpecial.setSpecial(true)
    currentSpecialCoin = newSpecial

    return newSpecial
  }

  /// Marks the current special coin as found
  func markAsFound() {
    hasFoundSpecialThisSession = true
    currentSpecialCoin?.setSpecial(false)
    currentSpecialCoin = nil
  }

  /// Gets a random message for display
  func randomMessage() -> String {
    Self.messages.randomElement() ?? "found it"
  }

  /// Checks if a coin is the special coin
  func isSpecialCoin(_ coin: CoinEntity) -> Bool {
    return coin.coinId == currentSpecialCoin?.coinId
  }
}
