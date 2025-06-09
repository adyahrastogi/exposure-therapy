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

            Button("Change Darkness Level") {
                withAnimation {
                    // Exclude `.off`
                    let levels = DarknessLevel.allCases.filter { $0 != .off }
                    if let currentIndex = levels.firstIndex(of: appModel.currentDarkness) {
                        let nextIndex = (currentIndex + 1) % levels.count
                        appModel.currentDarkness = levels[nextIndex]
                    } else {
                        // Fallback: if current is .off or invalid, start at light
                        appModel.currentDarkness = .light
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
