import SwiftUI

struct Word {
    var original: String   // Parola originale (es. giapponese)
    var romaji: String     // Traslitterazione in romaji
    var italiano: String   // Traduzione in italiano
}

class CSVParser {
    // Funzione che legge il CSV dal bundle
    static func loadCSV(from filename: String) -> [Word] {
        var words: [Word] = []
        
        // Trova il percorso del file CSV nel bundle
        guard let filePath = Bundle.main.path(forResource: filename, ofType: "csv") else {
            print("File CSV non trovato")
            return []
        }
        
        do {
            // Leggi il contenuto del file come stringa
            let csvData = try String(contentsOfFile: filePath, encoding: .utf8)
            
            // Dividi il file in righe
            let rows = csvData.components(separatedBy: "\n")
            
            // Salta la prima riga (intestazione) e itera sulle altre righe
            for row in rows.dropFirst() {
                let columns = row.components(separatedBy: ",")
                if columns.count == 3 {
                    // Crea un'istanza di Word
                    let word = Word(original: columns[0], romaji: columns[1], italiano: columns[2])
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
    // Stato che contiene le parole lette dal CSV
    @State private var words: [Word] = []
    @State private var randomWord: Word? = nil // Variabile di stato per memorizzare una parola casuale
    @State private var userInput: String = "" // Input dell'utente
    @State private var comparisonResult: String = "" // Risultato del confronto
    @State private var inItaliano: String = "" //Traduzione
    @State private var file: String = "Hiragana"
    
    var body: some View {
        VStack {
            //Scelta esercizio
            Menu("Scegli esercizio") {
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
                
                // Mostra la parola originale
                Text("\(randomWord.original)")
                    .font(.system(size: 50))
                    .padding()
                
                // TextField per inserire il romaji
                TextField("Inserisci la traslitterazione romaji", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: userInput) {
                        // Confronta l'input ogni volta che cambia
                        if userInput.uppercased() == randomWord.romaji.uppercased() {
                            comparisonResult = "Corretto!"
                            inItaliano = randomWord.italiano.uppercased()
                        } else {
                            comparisonResult = ""
                        }
                    }
                
                // Mostra il risultato del confronto
                Text(comparisonResult)
                    .foregroundColor(comparisonResult == "Corretto!" ? .green : .red)
                    .padding()
                Text("In Italiano corrisponde a:")
                Text(inItaliano)
            } else {
                Text("Caricamento...")
            }
            
            // Bottone per mostrare un'altra parola casuale
            Button("Prossima") {
                randomWord = words.randomElement() // Cambia la parola casuale
                userInput = "" // Resetta l'input dell'utente
                comparisonResult = "" // Resetta il risultato del confronto
                inItaliano = "" //resetta il campo traduzione
            }
            .padding()
        }
        .onAppear {
            // Carica il CSV e seleziona una parola casuale quando la vista appare
            words = CSVParser.loadCSV(from: "Hiragana")
            randomWord = words.randomElement() // Scegli una parola casuale
        }
    }
}

