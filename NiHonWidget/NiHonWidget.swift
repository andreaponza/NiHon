//
//  NiHonWidget.swift
//  NiHonWidget
//
//  Created by Andrea De Martino on 17/10/24.
//

import WidgetKit
import SwiftUI
import Foundation

struct WordEntry: TimelineEntry {
    let date: Date
    let originale: String
    let romaji: String
    let italiano: String
}

struct NiHonWidgetEntryView: View {
    var entry: WordProvider.Entry

    var body: some View {
        VStack {
            Text(entry.originale.replacingOccurrences(of: "<", with: "\n"))
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
            Text(entry.romaji)
                .font(.subheadline)
            Text(entry.italiano)
                .font(.footnote)
        }
        .padding()
        .containerBackground(.brown.gradient.opacity(0.7), for: .widget)
    }
}

struct WordProvider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), originale: "こんにちは", romaji: "Konnichiwa", italiano: "Ciao")
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        let entry = WordEntry(date: Date(), originale: "こんにちは", romaji: "Konnichiwa", italiano: "Ciao")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        // Carica le parole dal file CSV locale
        let words = loadWordsFromCSV()

        // Seleziona una parola casuale
        if let randomEntry = words.randomElement() {
            let entry = WordEntry(date: Date(), originale: randomEntry.0, romaji: randomEntry.1, italiano: randomEntry.2)
            
            // Imposta il widget per aggiornarsi ogni ora
            let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            completion(timeline)
        } else {
            // In caso di errore, mostra un fallback
            let fallbackEntry = WordEntry(date: Date(), originale: "Errore", romaji: "Errore", italiano: "Errore")
            let timeline = Timeline(entries: [fallbackEntry], policy: .atEnd)
            completion(timeline)
        }
    }

    // Funzione per caricare il CSV locale
    func loadWordsFromCSV() -> [(String, String, String)] {
        guard let filePath = Bundle.main.path(forResource: "Words", ofType: "csv") else {
            return []
        }

        do {
            let content = try String(contentsOfFile: filePath)
            let rows = content.components(separatedBy: "\n").map { $0.components(separatedBy: ",") }
            let words = rows.compactMap { row in
                if row.count == 3 {
                    return (row[0], row[1], row[2])
                } else {
                    return nil
                }
            }
            return words
        } catch {
            return []
        }
    }
}
