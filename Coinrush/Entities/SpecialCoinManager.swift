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
  private static let messages: [String] = [
    "you found me",
    "nice catch",
    "look again",
    "feeling lucky?",
    "one more time",
    "almost there",
    "keep going",
    "found it",
    "hidden gem",
    "good eye",
    "not so fast",
    "try again",
    "bingo",
    "gotcha",
  ]

  /// Current special coin
  private(set) var currentSpecialCoin: CoinEntity?

  /// All available coins
  private var coins: [CoinEntity] = []

  /// Registers coins for management
  func registerCoins(_ coins: [CoinEntity]) {
    self.coins = coins
  }

  /// Selects a new random special coin
  /// - Returns: The newly selected special coin
  @discardableResult
  func selectNewSpecialCoin() -> CoinEntity? {
    // Reset previous special coin
    if let previous = currentSpecialCoin {
      previous.setSpecial(false)
    }

    // Select new special coin
    guard !coins.isEmpty else { return nil }

    let availableCoins = coins.filter { $0 != currentSpecialCoin }
    guard let newSpecial = availableCoins.randomElement() else { return nil }

    newSpecial.setSpecial(true)
    currentSpecialCoin = newSpecial

    return newSpecial
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
