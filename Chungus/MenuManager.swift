//
//  Menu.swift
//  Chungus
//
//  Created by Anto Z on 2/24/26.
//

import SwiftUI

import AppKit
import SpriteKit

class MenuManager {
    private var activeMenu: NSPanel?
    
    static let shared = MenuManager()
    
    func openMenu(for sprite: SKSpriteNode, selectTaskHandler: @escaping (String) -> Void, stats: SpriteStats) {
        if let existingMenu = activeMenu {
            existingMenu.makeKeyAndOrderFront(nil)
            return
        }

        let contentView = ChungusMenuView(selectHandler: selectTaskHandler, stats: stats)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 200, height: 180)

        // 3. Setup the Panel
        let menuWindow = NSPanel(
            contentRect: hostingView.frame,
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel, .hudWindow],
            backing: .buffered,
            defer: false
        )

        menuWindow.title = "Settings"
        menuWindow.level = .floating
        menuWindow.contentView = hostingView // Set the SwiftUI view as the window's content
        
        // Position relative to sprite
        if let sceneWindow = sprite.scene?.view?.window {
            let origin = sceneWindow.frame.origin
            menuWindow.setFrameOrigin(CGPoint(x: origin.x + 130, y: origin.y + 40))
        }

        // Cleanup on close
        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: menuWindow, queue: .main) { _ in
            self.activeMenu = nil
        }

        self.activeMenu = menuWindow
        menuWindow.makeKeyAndOrderFront(nil)
    }
    
}
