//
//  ContentView.swift
//  Chungus
//
//  Created by Anto Z on 2/23/26.
//

import SwiftUI
import SpriteKit // You need this to use SpriteView

struct ContentView: View {
    @StateObject private var stats = SpriteStats()
    
    @State private var scene: ChungusScene?
    
    var body: some View {
        Group {
            // render if the scene exists, cause redrawing will screw up the Chungus instance
            if let scene = scene {
                SpriteView(scene: scene, options: [.allowsTransparency])
                    .frame(
                        width: max(1.5 * SpriteConstant.width, SpriteConstant.width * (stats.weight / SpriteConstant.baseWeight)),
                        height: max(1.5 * SpriteConstant.height, SpriteConstant.height * (stats.weight / SpriteConstant.baseWeight))
                    )
            }
        }
        .onAppear {
            // Initialize it when app starts
            let newScene = ChungusScene(
                size: CGSize(width: ScreenConstant.width * 1.5, height: ScreenConstant.height * 1.5),
                stats: stats
            )
            print("Initialized an instance")
            newScene.scaleMode = .resizeFill
            self.scene = newScene
        }
    }
}
