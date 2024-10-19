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
                   .frame(minWidth: 600, minHeight: 600) // Set min view size
           }
           .windowStyle(HiddenTitleBarWindowStyle()) // Window style
       }

       init() {
           //
           DispatchQueue.main.async {
               if let window = NSApplication.shared.windows.first {
                   window.setContentSize(NSSize(width: 600, height: 500)) // set window initial size
                   window.minSize = NSSize(width: 600, height: 500) // set window min size
                   window.maxSize = NSSize(width: 600, height: 500) // set window max size
               }
           }
       }
}
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
