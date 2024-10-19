import SwiftUI

struct Word {
    var kanji: String //Word in kanji
    var hiraKata: String   // Word  in hiragana o katakana
    var romaji: String     // Word in romaji
    var mean: String   // Mean
}

class CSVParser {
    // Read CSV from bundle
    static func loadCSV(from filename: String) -> [Word] {
        var words: [Word] = []
        
        // Find CSV path in bundle
        guard let filePath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            print("File CSV not found")
            return []
        }
        
        do {
            // Read CVS
            let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
            
            // Split line
            let rows = csvData.components(separatedBy: "\n")
            
            // Skip firs row
            for row in rows.dropFirst() {
                let columns = row.components(separatedBy: ",")
                if columns.count == 4 {
                    // Create Word instance
                    let word = Word(kanji: columns[0], hiraKata: columns[1] , romaji: columns[2], mean: columns[3])
                    words.append(word)
                }
            }
        } catch {
            print("Errore nella lettura del file CSV: \(error)")
        }
        
        return words
    }
}

struct ContentView: View {
    // Readed words in CSV
    @State private var words: [Word] = []
    @State private var randomWord: Word? = nil // Store random word
    @State private var userInput: String = "" // User input
    @State private var comparisonResult: String = "" // Compared result
    @State private var mean: String = "" //Mean
    @State private var exercise = ["Hiragana", "Katakana", "Words"]
    @State private var file: String = ""
    
    var body: some View {
        VStack {
            //Choose file
            Menu("Choose ") {
                Button("Hiragana", action: {
                    words = CSVParser.loadCSV(from: "Hiragana")
                    randomWord = words.randomElement()
                    file = "Hiragana"
                })
                Button("Katakana", action: {
                    words = CSVParser.loadCSV(from: "Katakana")
                    randomWord = words.randomElement()
                    file = "Katakana"
                })
                Button("Words", action: {
                    words = CSVParser.loadCSV(from: "Words")
                    randomWord = words.randomElement()
                    file = "Words"
                })
            }
            .padding()
            
            if let randomWord = randomWord {
                Text(file)
                    .font(.headline)
                    .padding()
                
                // Show word
                Text("\(randomWord.kanji)\n\(randomWord.hiraKata)")
                    .font(.system(size: 50))
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Show result between user input and romaji
                Text(comparisonResult)
                    .foregroundColor(comparisonResult == "Correct!" ? .green : .red)
                    .padding()
                Text("Mean:")
                Text(mean)
                
                // TextField for romaji user input
                TextField("Insert romaji", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: userInput) {
                        // Compare input when user digit
                        if userInput.uppercased() == randomWord.romaji.uppercased() {
                            comparisonResult = "Correct!"
                            mean = randomWord.mean.uppercased()
                        } else {
                            comparisonResult = ""
                        }
                    }
                    
                //Reveal solution
                Button("Show solution!") {
                    mean = randomWord.mean.uppercased()
                }
                .padding()
                

            } else {
                Text("Loading...")
            }
            
            // Next word
            Button("Next word") {
                randomWord = words.randomElement() // Change word
                userInput = "" // Reset user input
                comparisonResult = "" // Reset compared result
                mean = "" //Reset mean text
            }
            .padding()
        }
        .onAppear {
            // Load CSV and select casual word
            file = exercise.randomElement()!
            words = CSVParser.loadCSV(from: file)
            randomWord = words.randomElement() // Choose casual word
        }
        .containerBackground(.brown.gradient, for: .window)
        .textSelection(.enabled)
    }
}
