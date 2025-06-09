//
//  SceneUnderstandingView.swift
//  exposure-dark-test3
//
//

import RealityKit
import SwiftUI
import ARKit

struct SceneUnderstandingView: View {
    @State private var orbPosition: SIMD3<Float>? = nil
    
    var body: some View {
        RealityView { content in
            // Create a scene for anchoring content
            let rootEntity = Entity()
            content.add(rootEntity)
            
            // Add a glowing orb (initially not visible)
            let orbEntity = createGlowingOrb()
            orbEntity.isEnabled = false
            rootEntity.addChild(orbEntity)
            
            // IMPORTANT: Create a local reference to content
            let contentReference = content
            
            // Store references for later updates
            Task { @MainActor in
                updateScene(content: contentReference, rootEntity: rootEntity, orbEntity: orbEntity)
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Convert Point3D to SIMD3<Float>
                    let location = SIMD3<Float>(
                        Float(value.location3D.x),
                        Float(value.location3D.y),
                        Float(value.location3D.z)
                    )
                    // Place orb at tap location
                    placeOrb(at: location)
                }
        )
    }
    
    private func createGlowingOrb() -> ModelEntity {
        // Create a glowing sphere mesh
        let sphereMesh = MeshResource.generateSphere(radius: 0.05)
        
        // Create emissive material for glow effect
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .blue)
        material.emissiveColor = .init(color: .blue)  // Keeping your version
        
        // Create the orb entity
        let orbEntity = ModelEntity(mesh: sphereMesh, materials: [material])
        
        // Add a light to the orb
        let lightEntity = Entity()
        let lightComponent = PointLightComponent(color: .blue,
                                              intensity: 5000,
                                              attenuationRadius: 0.5)
        lightEntity.components[PointLightComponent.self] = lightComponent
        orbEntity.addChild(lightEntity)
        
        return orbEntity
    }
    
    @MainActor
    private func updateScene(content: RealityViewContent, rootEntity: Entity, orbEntity: Entity) {
        // This task will update as new mesh data becomes available
        Task {
            for await _ in AsyncTimerSequence(timeInterval: 0.5, tolerance: 0.1) {
                // Update scene with latest mesh data
                if let orbPosition = orbPosition {
                    orbEntity.isEnabled = true
                    orbEntity.position = orbPosition
                }
            }
        }
    }
    
    private func placeOrb(at hitLocation: SIMD3<Float>) {
        // Update the orb position
        orbPosition = hitLocation
    }
}

// Helper for timer-based updates
struct AsyncTimerSequence: AsyncSequence, AsyncIteratorProtocol {
    typealias Element = Void
    
    let timeInterval: TimeInterval
    let tolerance: TimeInterval
    
    init(timeInterval: TimeInterval, tolerance: TimeInterval) {
        self.timeInterval = timeInterval
        self.tolerance = tolerance
    }
    
    func makeAsyncIterator() -> Self {
        self
    }
    
    mutating func next() async -> Void? {
        try? await Task.sleep(for: .seconds(timeInterval))
        return ()
    }
}
