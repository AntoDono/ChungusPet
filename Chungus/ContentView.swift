//
//  ContentView.swift
//  Chungus
//
//  Created by Anto Z on 2/23/26.
//

import SwiftUI
import SpriteKit // You need this to use SpriteView

struct ContentView: View {
    
    var scene: SKScene {
        let scene = ChungusScene(size: CGSize(width: ScreenConstant.width * 1.2, height: ScreenConstant.height * 1.2))
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        // 2. Use SpriteView to display it
        // The [.allowsTransparency] option is the secret sauce to making
        // sure the SpriteKit background doesn't default to black!
        SpriteView(scene: scene, options: [.allowsTransparency])
            .frame(width: SpriteConstant.width, height: SpriteConstant.height) // Keep the window small and tidy
    }
}
