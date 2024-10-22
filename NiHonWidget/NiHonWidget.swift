import WidgetKit
import SwiftUI
import Foundation

struct WordEntry: TimelineEntry {
    let date: Date
    let kanji: String
    let hiraKata: String
    let romaji: String
    let mean: String
}

struct NiHonWidgetEntryView: View {
    var entry: WordProvider.Entry

    var body: some View {
        VStack {
            if(entry.kanji != "") {
                Text(entry.kanji)
                    .font(.system(size: 25))
                    .multilineTextAlignment(.center)
                Text(entry.hiraKata)
                    .font(.system(size: 18))
                    .multilineTextAlignment(.center)
            } else {
                Text(entry.hiraKata)
                    .font(.system(size: 25))
            }
            
            Text(entry.romaji)
                .font(.subheadline)
            Text(entry.mean)
                .font(.subheadline)
        
        }
        .padding()
        .containerBackground(.brown.gradient.opacity(0.7), for: .widget)
    }
}

struct WordProvider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), kanji: "", hiraKata: "こんにちは", romaji: "Konnichiwa", mean: "Ciao")
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        let entry = WordEntry(date: Date(), kanji: "", hiraKata: "こんにちは", romaji: "Konnichiwa", mean: "Ciao")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        // Load words from CSV (first try from remote, then fallback to local)
        loadWordsFromCSV { words in
            let filteredWords = words.dropFirst()

            // Select casual word
            if let randomEntry = filteredWords.randomElement() {
                let entry = WordEntry(date: Date(), kanji: randomEntry.0, hiraKata: randomEntry.1, romaji: randomEntry.2, mean: randomEntry.3)
                
                // Set widget update every 1 minute
                let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
                completion(timeline)
            } else {
                // error loading file
                let fallbackEntry = WordEntry(date: Date(), kanji: "Error", hiraKata: "Error", romaji: "Error", mean: "Error")
                let timeline = Timeline(entries: [fallbackEntry], policy: .atEnd)
                completion(timeline)
            }
        }
    }

    // CSV loader with remote fallback
    func loadWordsFromCSV(completion: @escaping ([(String, String, String, String)]) -> Void) {
        // Attempt to load from remote URL
        let urlString = "https://raw.githubusercontent.com/andreaponza/NiHon/refs/heads/main/NiHon/Words.csv"
        guard let url = URL(string: urlString) else {
            // Fallback to local if URL is invalid
            completion(loadWordsFromLocalCSV())
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, error == nil {
                if let content = String(data: data, encoding: .utf8) {
                    let words = self.parseCSV(content: content)
                    completion(words)
                    return
                }
            }
            
            // If download fails, fallback to local
            completion(self.loadWordsFromLocalCSV())
        }
        task.resume()
    }

    // Parse CSV content
    func parseCSV(content: String) -> [(String, String, String, String)] {
        let rows = content.components(separatedBy: "\n").map { $0.components(separatedBy: ";") }
        let words = rows.compactMap { row in
            if row.count == 4 {
                return (row[0], row[1], row[2], row[3])
            } else {
                return nil
            }
        }
        return words
    }

    // Load words from local CSV file
    func loadWordsFromLocalCSV() -> [(String, String, String, String)] {
        guard let filePath = Bundle.main.path(forResource: "Words", ofType: "csv") else {
            return []
        }

        do {
            let content = try String(contentsOfFile: filePath)
            return parseCSV(content: content)
        } catch {
            return []
        }
    }
}
