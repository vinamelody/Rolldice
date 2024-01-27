//
//  RolldiceApp.swift
//  Rolldice
//
//  Created by Vina Melody on 26/1/24.
//

import SwiftUI

@Observable
class DiceData {
    var rolledNumber = 0
}

@main
struct RolldiceApp: App {
    @State var diceData = DiceData()
    
    var body: some Scene {
        WindowGroup {
            ContentView(diceData: diceData)
        }
        .defaultSize(width: 100, height: 100)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(diceData: diceData)
        }
    }
}
