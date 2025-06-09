//
//  ContentView.swift
//  exposure-dark-test3
//
//  Created by Adyah Rastogi on 5/5/25.
//
// ContentView.swift
import SwiftUI
struct ContentView: View {
    @State private var showImmersiveView = false
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton(showImmersiveView: $showImmersiveView)
                .padding()

            Picker("Experience Mode", selection: Binding(
                get: { self.appModel.currentMode },
                set: { self.appModel.currentMode = $0 }
            )) {
                Text("Darkness").tag(AppModel.ExperienceMode.darkness)
                Text("Orb Placement").tag(AppModel.ExperienceMode.orbPlacement)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if appModel.currentMode == .darkness {
                Button("Change Darkness Level") {
                    withAnimation {
                        let levels = DarknessLevel.allCases.filter { $0 != .off }
                        if let currentIndex = levels.firstIndex(of: appModel.currentDarkness) {
                            let nextIndex = (currentIndex + 1) % levels.count
                            appModel.currentDarkness = levels[nextIndex]
                        } else {
                            appModel.currentDarkness = .light
                        }
                    }
                }
            }

            // Show immersive view when the state is true
            if showImmersiveView {
                ImmersiveView()
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppModel()) // Required for preview
}
