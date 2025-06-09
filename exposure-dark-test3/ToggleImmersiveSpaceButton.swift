import SwiftUI

struct ToggleImmersiveSpaceButton: View {
    @Binding var showImmersiveView: Bool
    @Environment(AppModel.self) private var appModel

    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    var body: some View {
        Button {
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                case .open:
                    appModel.immersiveSpaceState = .inTransition
                    await dismissImmersiveSpace()
                    appModel.immersiveSpaceState = .closed
                    appModel.currentDarkness = .off
                    showImmersiveView = false

                case .closed:
                    appModel.immersiveSpaceState = .inTransition
                    appModel.currentDarkness = .light
                    switch await openImmersiveSpace(id: appModel.immersiveSpaceID) {
                    case .opened:
                        appModel.immersiveSpaceState = .open 
                        showImmersiveView = true
                    case .userCancelled, .error:
                        fallthrough
                    @unknown default:
                        appModel.immersiveSpaceState = .closed
                        appModel.currentDarkness = .off
                        showImmersiveView = false
                    }

                case .inTransition:
                    break
                }
            }
        } label: {
            Text(appModel.immersiveSpaceState == .open ? "Hide Immersive Space" : "Show Immersive Space")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .fontWeight(.semibold)
    }
}
