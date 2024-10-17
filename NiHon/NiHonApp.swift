//
//  NiHonApp.swift
//  NiHon
//
//  Created by Andrea De Martino on 16/10/24.
//

import SwiftUI

@main
struct NiHonApp: App {
    var body: some Scene {
           WindowGroup {
               ContentView()
                   .frame(minWidth: 500, minHeight: 700) // Imposta la dimensione minima della vista
           }
           .windowStyle(HiddenTitleBarWindowStyle()) // Stile della finestra (opzionale)
       }

       init() {
           // Accedi alla finestra principale all'avvio dell'app
           DispatchQueue.main.async {
               if let window = NSApplication.shared.windows.first {
                   window.setContentSize(NSSize(width: 500, height: 700)) // Imposta dimensioni iniziali della finestra
                   window.minSize = NSSize(width: 500, height: 700) // Imposta dimensione minima
                   window.maxSize = NSSize(width: 500, height: 700) // Imposta dimensione massima per bloccare il ridimensionamento
               }
           }
       }
}
