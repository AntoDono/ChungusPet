//
//  Constants.swift
//  Chungus
//
//  Created by Anto Z on 2/23/26.
//

import Foundation
import SwiftUI

struct SpriteConstant {
    static let width: Double = 80
    static let height: Double = 140
}

struct ScreenConstant {
    static var width: Double {
        return Double(NSScreen.main?.visibleFrame.width ?? 800)
    }
    static var height: Double {
        return Double(NSScreen.main?.visibleFrame.height ?? 600)
    }
}


struct RuneTimeConstant {
    static let spriteDebug: Bool = true 
}
