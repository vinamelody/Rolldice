//
//  ImmersiveView.swift
//  Rolldice
//
//  Created by Vina Melody on 26/1/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    var body: some View {
        RealityView { content in
            if let diceModel = try? await Entity(named: "dice"),
               let dice = diceModel.children.first?.children.first {

                dice.scale = [0.1, 0.1, 0.1]
                dice.position.y = 0.5
                dice.position.z = -1
                content.add(dice)
            }
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
