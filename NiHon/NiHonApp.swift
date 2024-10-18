//
//  NiHonApp.swift
//  NiHon
//
//  Created by Andrea De Martino on 16/10/24.
//

import SwiftUI

@main
struct NiHonApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
           WindowGroup {
               ContentView()
                   .frame(minWidth: 600, minHeight: 600) // Imposta la dimensione minima della vista
           }
           .windowStyle(HiddenTitleBarWindowStyle()) // Stile della finestra (opzionale)
       }

       init() {
           // Accedi alla finestra principale all'avvio dell'app
           DispatchQueue.main.async {
               if let window = NSApplication.shared.windows.first {
                   window.setContentSize(NSSize(width: 600, height: 500)) // Imposta dimensioni iniziali della finestra
                   window.minSize = NSSize(width: 600, height: 500) // Imposta dimensione minima
                   window.maxSize = NSSize(width: 600, height: 500) // Imposta dimensione massima per bloccare il ridimensionamento
               }
           }
       }
}
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
