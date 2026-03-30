import SwiftUI

@main
struct TVFlowApp: App {
  @StateObject private var settingsStore = StreamingSettingsStore()

  var body: some Scene {
    WindowGroup {
      NavigationStack {
        ContentView()
          .environmentObject(settingsStore)
      }
    }
  }
}
