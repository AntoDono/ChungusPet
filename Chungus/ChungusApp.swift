//
//  ChungusApp.swift
//  Chungus
//
//  Created by Anto Z on 2/23/26.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Find the main window and turn it into a ghost
        if let window = NSApplication.shared.windows.first {
            window.styleMask = [.borderless] // Remove borders and title bar
            window.isOpaque = false          // Allow transparency
            window.backgroundColor = .clear  // Make background invisible
            window.hasShadow = false         // Remove the drop shadow
            window.level = .floating         // Float above other apps
        }
    }
}

@main
struct ChungusApp: App {
    // 2. Connect the AppDelegate to your SwiftUI App
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 3. Make sure the SwiftUI view itself is also transparent
                .background(Color.clear)
        }
        // 4. Tell SwiftUI to hide the standard title bar
        .windowStyle(.hiddenTitleBar)
    }
}
