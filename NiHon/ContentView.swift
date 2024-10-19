import SwiftUI

struct Word {
    var kanji: String // Word in kanji
    var hiraKata: String // Word in hiragana o katakana
    var romaji: String // Word in romaji
    var mean: String // Mean
}

class CSVParser {
    // Load CSV from URL
    static func loadCSV(from urlString: String, completion: @escaping ([Word]) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching CSV: \(error)")
                completion([])
                return
            }
            
            guard let data = data, let csvData = String(data: data, encoding: .utf8) else {
                print("Invalid CSV data")
                completion([])
                return
            }
            
            var words: [Word] = []
            let rows = csvData.components(separatedBy: "\n")
            
            for row in rows.dropFirst() {
                let columns = row.components(separatedBy: ",")
                if columns.count == 4 {
                    let word = Word(kanji: columns[0], hiraKata: columns[1], romaji: columns[2], mean: columns[3])
                    words.append(word)
                }
            }
            
            completion(words)
        }.resume()
    }

    // Load CSV from local file
    static func loadCSV(from filename: String) -> [Word] {
        var words: [Word] = []
        
        guard let filePath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            print("File CSV not found")
            return []
        }
        
        do {
            let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
            let rows = csvData.components(separatedBy: "\n")
            
            for row in rows.dropFirst() {
                let columns = row.components(separatedBy: ",")
                if columns.count == 4 {
                    let word = Word(kanji: columns[0], hiraKata: columns[1], romaji: columns[2], mean: columns[3])
                    words.append(word)
                }
            }
        } catch {
            print("Error reading local CSV: \(error)")
        }
        
        return words
    }
}

struct ContentView: View {
    @State private var words: [Word] = []
    @State private var randomWord: Word? = nil
    @State private var userInput: String = ""
    @State private var comparisonResult: String = ""
    @State private var mean: String = ""
    @State private var exercise = ["Hiragana", "Katakana", "Words"]
    @State private var file: String = ""
    
    let remoteCSVURL = "https://raw.githubusercontent.com/andreaponza/NiHon/refs/heads/main/NiHon/Words.csv"

    var body: some View {
        VStack {
            // Menu for choosing between local and remote files
            Menu("Choose Source") {
                Button("Load Local Hiragana", action: {
                    words = CSVParser.loadCSV(from: "Hiragana")
                    randomWord = words.randomElement()
                    file = "Hiragana"
                    userInput = ""
                    comparisonResult = ""
                    mean = ""
                })
                Button("Load Local Katakana", action: {
                    words = CSVParser.loadCSV(from: "Katakana")
                    randomWord = words.randomElement()
                    file = "Katakana"
                    userInput = ""
                    comparisonResult = ""
                    mean = ""
                })
                Button("Load Remote Words", action: {
                    CSVParser.loadCSV(from: remoteCSVURL) { fetchedWords in
                        DispatchQueue.main.async {
                            words = fetchedWords
                            randomWord = words.randomElement()
                            file = "Remote Words"
                            userInput = ""
                            comparisonResult = ""
                            mean = ""
                        }
                    }
                })
                Button("Load Local Words", action: {
                    words = CSVParser.loadCSV(from: "Words")
                    randomWord = words.randomElement()
                    file = "Words"
                    userInput = ""
                    comparisonResult = ""
                    mean = ""
                })
            }
            .padding()

            if let randomWord = randomWord {
                Text(file)
                    .font(.headline)
                    .padding()

                Text("\(randomWord.kanji)\n\(randomWord.hiraKata)")
                    .font(.system(size: 50))
                    .multilineTextAlignment(.center)
                    .padding()

                Text(comparisonResult)
                    .foregroundColor(comparisonResult == "Correct!" ? .green : .red)
                    .padding()

                Text("Mean:")
                Text(mean)

                TextField("Insert romaji", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: userInput) {
                        if userInput.uppercased() == randomWord.romaji.uppercased() {
                            comparisonResult = "Correct!"
                            mean = randomWord.mean.uppercased()
                        } else {
                            comparisonResult = ""
                        }
                    }

                Button("Show solution!") {
                    mean = randomWord.mean.uppercased()
                }
                .padding()

            } else {
                Text("Loading...")
            }

            Button("Next word") {
                randomWord = words.randomElement()
                userInput = ""
                comparisonResult = ""
                mean = ""
            }
            .padding()
        }
        .onAppear {
            // Load a random local file initially
            file = exercise.randomElement()!
            words = CSVParser.loadCSV(from: file)
            randomWord = words.randomElement()
        }
        .containerBackground(.brown.gradient, for: .window)
        .textSelection(.enabled)
    }
}
