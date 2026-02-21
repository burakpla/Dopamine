//
//  QuoteProvider.swift
//  Dopamine
//
//  Created by PortalGrup on 21.02.2026.
//


import Foundation

struct QuoteProvider {
    static let quotes = [
        "Bugün, dünden daha iyi olmak için harika bir gün.",
        "Küçük adımlar, büyük sonuçlar doğurur.",
        "Odaklanma, her şeyin anahtarıdır.",
        "Disiplin, özgürlüğün bedelidir.",
        "Sadece başla, gerisi dopaminle gelecek.",
        "Zorluklar, karakterini inşa eden tuğlalardır.",
        "Bugünkü emeğin, yarınki gururun olacak."
    ]
    
    static var dailyQuote: String {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return quotes[dayOfYear % quotes.count]
    }
}