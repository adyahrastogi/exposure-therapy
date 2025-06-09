////
////  SceneUnderstandingView.swift
////  exposure-dark-test3
////
////
//
//import RealityKit
//import SwiftUI
//import ARKit
//
//struct SceneUnderstandingView: View {
//    @State private var orbPosition: SIMD3<Float>? = nil
//    
//    var body: some View {
//        RealityView { content in
//            // Create a scene for anchoring content
//            let rootEntity = Entity()
//            content.add(rootEntity)
//            
//            // Add a glowing orb (initially not visible)
//            let orbEntity = createGlowingOrb()
//            orbEntity.isEnabled = false
//            rootEntity.addChild(orbEntity)
//            
//            // IMPORTANT: Create a local reference to content
//            let contentReference = content
//            
//            // Store references for later updates
//            Task { @MainActor in
//                updateScene(content: contentReference, rootEntity: rootEntity, orbEntity: orbEntity)
//            }
//        }
//        .gesture(
//            SpatialTapGesture()
//                .targetedToAnyEntity()
//                .onEnded { value in
//                    // Convert Point3D to SIMD3<Float>
//                    let location = SIMD3<Float>(
//                        Float(value.location3D.x),
//                        Float(value.location3D.y),
//                        Float(value.location3D.z)
//                    )
//                    // Place orb at tap location
//                    placeOrb(at: location)
//                }
//        )
//    }
//    
//    private func createGlowingOrb() -> ModelEntity {
//        // Create a glowing sphere mesh
//        let sphereMesh = MeshResource.generateSphere(radius: 0.05)
//        
//        // Create emissive material for glow effect
//        var material = PhysicallyBasedMaterial()
//        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .blue)
//        material.emissiveColor = .init(color: .blue)  // Keeping your version
//        
//        // Create the orb entity
//        let orbEntity = ModelEntity(mesh: sphereMesh, materials: [material])
//        
//        // Add a light to the orb
//        let lightEntity = Entity()
//        let lightComponent = PointLightComponent(color: .blue,
//                                              intensity: 5000,
//                                              attenuationRadius: 0.5)
//        lightEntity.components[PointLightComponent.self] = lightComponent
//        orbEntity.addChild(lightEntity)
//        
//        return orbEntity
//    }
//    
//    @MainActor
//    private func updateScene(content: RealityViewContent, rootEntity: Entity, orbEntity: Entity) {
//        // This task will update as new mesh data becomes available
//        Task {
//            for await _ in AsyncTimerSequence(timeInterval: 0.5, tolerance: 0.1) {
//                // Update scene with latest mesh data
//                if let orbPosition = orbPosition {
//                    orbEntity.isEnabled = true
//                    orbEntity.position = orbPosition
//                }
//            }
//        }
//    }
//    
//    private func placeOrb(at hitLocation: SIMD3<Float>) {
//        // Update the orb position
//        orbPosition = hitLocation
//    }
//}
//
//// Helper for timer-based updates
//struct AsyncTimerSequence: AsyncSequence, AsyncIteratorProtocol {
//    typealias Element = Void
//    
//    let timeInterval: TimeInterval
//    let tolerance: TimeInterval
//    
//    init(timeInterval: TimeInterval, tolerance: TimeInterval) {
//        self.timeInterval = timeInterval
//        self.tolerance = tolerance
//    }
//    
//    func makeAsyncIterator() -> Self {
//        self
//    }
//    
//    mutating func next() async -> Void? {
//        try? await Task.sleep(for: .seconds(timeInterval))
//        return ()
//    }
//}
//
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
                
                // Create the orb but keep it disabled initially
                let orb = createGlowingOrb()
                orb.isEnabled = false
                rootEntity.addChild(orb)
                
                Task { @MainActor in
                    orbEntity = orb
                    print("SceneUnderstandingView: RealityView setup complete")
                }
            }
        }
        .onAppear {
            print("SceneUnderstandingView appeared")
        }
        .onTapGesture {
            tapCount += 1
            print("Regular tap gesture detected! Count: \(tapCount)")
            
            // Place orb 1 meter in front of user
            let frontLocation = SIMD3<Float>(0, 0, -1.0)
            placeOrb(at: frontLocation)
        }
        .gesture(
            SpatialTapGesture()
                .onEnded { value in
                    print("SpatialTapGesture detected!")
                    print("Location3D: \(value.location3D)")
                    
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
        print("Creating glowing orb...")
        
        // Create a larger, more visible sphere
        let sphereMesh = MeshResource.generateSphere(radius: 0.15)
        
        // Create emissive material for glow effect
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .blue)
        material.emissiveColor = .init(color: .blue)
        material.emissiveIntensity = 3.0
        
        let orbEntity = ModelEntity(mesh: sphereMesh, materials: [material])
        
        // Add a bright light
        let lightEntity = Entity()
        let lightComponent = PointLightComponent(
            color: .blue,
            intensity: 15000,
            attenuationRadius: 3.0
        )
        lightEntity.components[PointLightComponent.self] = lightComponent
        orbEntity.addChild(lightEntity)
        
        print("Glowing orb created successfully")
        return orbEntity
    }
    
    private func placeOrb(at location: SIMD3<Float>) {
        print("🔵 PLACE ORB CALLED! Location: \(location)")
        
        Task { @MainActor in
            guard let orb = orbEntity else {
                print("❌ ERROR: Orb entity is nil")
                return
            }
            
            print("✅ Setting orb position to: \(location)")
            orb.position = location
            orb.isEnabled = true
            
            print("✅ Orb placed successfully!")
            print("   - Position: \(orb.position)")
            print("   - isEnabled: \(orb.isEnabled)")
            print("   - Transform: \(orb.transform)")
        }
    }
}
