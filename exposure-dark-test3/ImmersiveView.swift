import RealityKit
import SwiftUI
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
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
            appModel.playWindSound()
        }
        .onDisappear {
            // --- UPDATED TO CALL THE NEW METHOD ---
            appModel.stopAllImmersiveSounds()
            
            // You might still want to update the state here if it's not handled elsewhere
            // when the view disappears (e.g., if dismissal isn't always via the toggle button)
            // appModel.immersiveSpaceState = .closed
        }
        .onChange(of: appModel.currentDarkness) { _, newDarkness in
            if newDarkness == .dark && appModel.immersiveSpaceState == .open {
                appModel.playCreakingSound()
            }
        }
    }
}
