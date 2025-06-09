import RealityKit
import SwiftUI
import ARKit

struct SceneUnderstandingView: View {
    @State private var orbEntity: ModelEntity? = nil
    @State private var tapCount = 0
    
    var body: some View {
        ZStack {
            // Add a visible background to ensure the view is receiving taps
            Color.clear
                .contentShape(Rectangle())
            
            RealityView { content in
                let rootEntity = Entity()
                content.add(rootEntity)
                
                // Create the orb and ENABLE IT IMMEDIATELY
                let orb = createGlowingOrb()
                
                // Position the orb 1 meter in front of the user at eye level
                orb.position = SIMD3<Float>(0, 0, -1.0) // 1 meter in front
                orb.isEnabled = true // Enable it immediately!
                
                rootEntity.addChild(orb)
                
                Task { @MainActor in
                    orbEntity = orb
                    print("✅ SceneUnderstandingView: RealityView setup complete")
                    print("   - Orb position: \(orb.position)")
                    print("   - Orb isEnabled: \(orb.isEnabled)")
                }
            }
        }
        .onAppear {
            print("🔵 SceneUnderstandingView appeared")
        }
        .onTapGesture {
            tapCount += 1
            print("🖱️ Regular tap gesture detected! Count: \(tapCount)")
            
            // Move orb to a new position to show taps are working
            moveOrbToRandomPosition()
        }
        .gesture(
            SpatialTapGesture()
                .onEnded { value in
                    print("🎯 SpatialTapGesture detected!")
                    print("   - Location3D: \(value.location3D)")
                    
                    let location = SIMD3<Float>(
                        Float(value.location3D.x),
                        Float(value.location3D.y),
                        Float(value.location3D.z)
                    )
                    
                    placeOrb(at: location)
                }
        )
    }
    
    private func createGlowingOrb() -> ModelEntity {
        print("🔨 Creating glowing orb...")
        
        // Create a VERY visible sphere
        let sphereMesh = MeshResource.generateSphere(radius: 0.2) // Even bigger
        
        // Create VERY bright emissive material
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .blue)
        material.emissiveColor = .init(color: .blue)
        material.emissiveIntensity = 5.0 // Very high intensity
        
        let orbEntity = ModelEntity(mesh: sphereMesh, materials: [material])
        
        // Add a VERY bright light
        let lightEntity = Entity()
        let lightComponent = PointLightComponent(
            color: .blue,
            intensity: 50000, // Extremely bright
            attenuationRadius: 5.0 // Large radius
        )
        lightEntity.components[PointLightComponent.self] = lightComponent
        orbEntity.addChild(lightEntity)
        
        print("✅ Glowing orb created successfully")
        print("   - Radius: 0.2")
        print("   - Emissive intensity: 5.0")
        print("   - Light intensity: 50000")
        
        return orbEntity
    }
    
    private func moveOrbToRandomPosition() {
        let randomX = Float.random(in: -1.0...1.0)
        let randomY = Float.random(in: -0.5...0.5)
        let randomZ = Float.random(in: -2.0...(-0.5))
        
        let newPosition = SIMD3<Float>(randomX, randomY, randomZ)
        placeOrb(at: newPosition)
    }
    
    private func placeOrb(at location: SIMD3<Float>) {
        print("🔵 PLACE ORB CALLED! Location: \(location)")
        
        Task { @MainActor in
            guard let orb = orbEntity else {
                print("❌ ERROR: Orb entity is nil")
                return
            }
            
            print("✅ Moving orb to: \(location)")
            orb.position = location
            orb.isEnabled = true
            
            print("✅ Orb moved successfully!")
            print("   - New position: \(orb.position)")
            print("   - isEnabled: \(orb.isEnabled)")
        }
    }
}
