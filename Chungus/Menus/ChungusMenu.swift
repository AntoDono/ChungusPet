//
//  ChungusMenu.swift
//  Chungus
//
//  Created by Anto Z on 2/24/26.
//

import SwiftUI

struct ChungusMenuView: View {
    // 1. Keep track of which button is currently active
    @State private var selectedAction: String = "None"
    var onSelect: (String) -> Void = { _ in }
    @ObservedObject var stats: SpriteStats
    
    init(selectHandler: @escaping (String) -> Void, stats: SpriteStats){
        self.onSelect = selectHandler
        self.stats = stats
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Hey Chungus! Go...")
                .font(.headline)
            
            HStack{
                Text("Rest: \(self.stats.rest, specifier: "%.1f")")
                Text("Abs: \(self.stats.abs, specifier: "%.1f")")
            }
            HStack{
                Text("Smarts: \(self.stats.intellect, specifier: "%.1f")")
                Text("Weight: \(self.stats.weight, specifier: "%.1f")")
            }
            
            Divider()
            
            // 2. Your first row of buttons
            HStack(spacing: 10) {
                actionButton(title: "Sleep")
                actionButton(title: "Study")
            }
            
            // 3. Your second row
            HStack(spacing: 10) {
                actionButton(title: "Exercise")
                actionButton(title: "Eat")
            }
            
            HStack(spacing: 10){
                actionButton(title: "Auto")
            }
            
            Divider().padding(.vertical, 5)
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit App")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .frame(width: 200, height: 250)
    }
    
    // 4. Helper function to create the buttons with selection logic
    @ViewBuilder
    func actionButton(title: String) -> some View {
        let isSelected = selectedAction == title
        
        Button(action: {
            selectedAction = title
            // You can add your SpriteKit trigger here later
            self.onSelect(title)
        }) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain) // Removes the default macOS button border
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.blue, lineWidth: isSelected ? 1 : 0)
        )
        
    }
    
}
