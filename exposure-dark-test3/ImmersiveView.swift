import RealityKit
import SwiftUI
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        Group {
            // Add debug logging to see which path we're taking
            let _ = print("ImmersiveView: body evaluated, currentMode = \(appModel.currentMode)")
            
            // Switch between experiences based on mode
            if appModel.currentMode == .orbPlacement {
                SceneUnderstandingView()
                    .onAppear {
                        print("✅ ImmersiveView: Orb Placement mode activated")
                        print("   - Current mode: \(appModel.currentMode)")
                        print("   - Immersive space state: \(appModel.immersiveSpaceState)")
                    }
                    .onDisappear {
                        print("❌ ImmersiveView: Orb Placement mode deactivated")
                        appModel.stopAllImmersiveSounds()
                    }
            } else {
                // Original darkness experience
                RealityView { content in
                    let alpha = appModel.currentDarkness.rawValue
                    let clampedAlpha = min(max(alpha, 0.0), 1.0)
                    
                    var immersiveMaterial = SimpleMaterial(color: .black.withAlphaComponent(clampedAlpha), roughness: 1.0, isMetallic: false)
                    immersiveMaterial.faceCulling = .none

                    let sphereMesh = MeshResource.generateSphere(radius: 0.5)
                    let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [immersiveMaterial])
                    sphereEntity.scale = SIMD3<Float>(x: -100, y: -100, z: -100)

                    let headAnchor = AnchorEntity(.head)
                    headAnchor.addChild(sphereEntity)
                    content.add(headAnchor)
                }
                .id(appModel.currentDarkness.rawValue)
                .onAppear {
                    print("🌑 ImmersiveView: Darkness mode activated")
                    print("   - Current mode: \(appModel.currentMode)")
                    print("   - Current darkness: \(appModel.currentDarkness)")
                    appModel.playWindSound()
                }
                .onDisappear {
                    print("❌ ImmersiveView: Darkness mode deactivated")
                    appModel.stopAllImmersiveSounds()
                }
                .onChange(of: appModel.currentDarkness) { _, newDarkness in
                    if newDarkness == .dark && appModel.immersiveSpaceState == .open {
                        appModel.playCreakingSound()
                    }
                }
            }
        }
        .onAppear {
            print("🚀 ImmersiveView: Overall view appeared")
            print("   - Mode at appearance: \(appModel.currentMode)")
        }
        .onChange(of: appModel.currentMode) { oldMode, newMode in
            print("🔄 ImmersiveView: Mode changed from \(oldMode) to \(newMode)")
        }
    }
}
