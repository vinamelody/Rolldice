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

    let diceMap = [
        [1,6], // x-,x+
        [4,3], // y-,y+
        [2,5]  // z-,z+
    ]
    var diceData: DiceData

    @State var droppedDice = false
    @State var initialDragOffset: SIMD3<Float> = .zero

    var body: some View {
        RealityView { content in
            let floor = ModelEntity(mesh: .generatePlane(width: 50, depth: 50), materials: [OcclusionMaterial()])
            floor.generateCollisionShapes(recursive: false)
            floor.components[PhysicsBodyComponent.self] = .init(massProperties: .default, mode: .static)

            content.add(floor)

            if let diceModel = try? await Entity(named: "dice"),
               let dice = diceModel.children.first?.children.first,
               let environment = try? await EnvironmentResource(named: "studio") {

                dice.scale = [0.1, 0.1, 0.1]
                dice.position.y = 0.5
                dice.position.z = -1

                dice.generateCollisionShapes(recursive: false)
                dice.components.set(InputTargetComponent())

                dice.components.set(ImageBasedLightComponent(source: .single(environment)))
                dice.components.set(ImageBasedLightReceiverComponent(imageBasedLight: dice))
                dice.components.set(GroundingShadowComponent(castsShadow: true))

                dice.components[PhysicsBodyComponent.self] = .init(
                    PhysicsBodyComponent(
                        massProperties: .default,
                        material: .generate(staticFriction: 0.8, dynamicFriction: 0.5, restitution: 0.1),
                        mode: .dynamic))

                dice.components[PhysicsMotionComponent.self] = .init()
                content.add(dice)

                let _ = content.subscribe(to: SceneEvents.Update.self) { event in
                    guard droppedDice else { return }
                    guard let diceMotion = dice.components[PhysicsMotionComponent.self] else { return }

                    if simd_length(diceMotion.linearVelocity) < 0.1 && simd_length(diceMotion.angularVelocity) < 0.1 {

                        let xDirection = dice.convert(direction: SIMD3(x: 1, y: 0, z: 0), to: nil)
                        let yDirection = dice.convert(direction: SIMD3(x: 0, y: 1, z: 0), to: nil)
                        let zDirection = dice.convert(direction: SIMD3(x: 0, y: 0, z: 1), to: nil)

                        let greatestDirection = [
                            0: xDirection.y,
                            1: yDirection.y,
                            2: zDirection.y
                        ]
                            .sorted(by: { abs($0.1) > abs($1.1)})[0]

                        diceData.rolledNumber = diceMap[greatestDirection.key][greatestDirection.value > 0 ? 0: 1]
                    }
                }
            }
        }
        .gesture(dragGesture)
    }

    var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in

                if initialDragOffset == .zero {
                    let startLocation = value.convert(value.startLocation3D, from: .local, to: value.entity.parent!)
                    initialDragOffset = value.entity.position - SIMD3(startLocation.x, startLocation.y, startLocation.z)
                }

                let translation = value.translation3D
                let adjustedY = translation.y <= 0 ? translation.y : 0 // vertical drag must be >= 0 to be above the floor

                var newLocation = value.startLocation3D
                newLocation.x += Double(translation.x)
                newLocation.y += Double(adjustedY)
                newLocation.z += Double(translation.z)
                let dragLocation = value.convert(newLocation, from: .local, to: value.entity.parent!)

                let newPosition = SIMD3(dragLocation.x, dragLocation.y, dragLocation.z) + initialDragOffset

                value.entity.position = newPosition
                value.entity.components[PhysicsBodyComponent.self]?.mode = .kinematic
            }
            .onEnded { value in
                initialDragOffset = .zero
                value.entity.components[PhysicsBodyComponent.self]?.mode = .dynamic

                if !droppedDice {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        droppedDice = true
                    }
                }
            }
    }
}

#Preview {
    ImmersiveView(diceData: DiceData())
        .previewLayout(.sizeThatFits)
}
