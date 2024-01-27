//
//  RolldiceApp.swift
//  Rolldice
//
//  Created by Vina Melody on 26/1/24.
//

import SwiftUI

@main
struct RolldiceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 100, height: 100)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
