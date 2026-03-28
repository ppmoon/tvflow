import Combine
import Foundation
import TVFlowCore

@MainActor
final class StreamingSettingsStore: ObservableObject {
  @Published var rtmpURL: String
  @Published var statusMessage: String?
  @Published private(set) var savedConfiguration: StreamingConfiguration?

  private let defaults: UserDefaults?

  init(defaults: UserDefaults? = UserDefaults(suiteName: TVFlowShared.appGroupIdentifier)) {
    self.defaults = defaults
    let persistedURL =
      defaults?.string(forKey: TVFlowShared.rtmpURLDefaultsKey) ?? TVFlowShared.defaultRTMPURL
    self.rtmpURL = persistedURL
    self.savedConfiguration = try? StreamingConfiguration(rawURL: persistedURL)
  }

    @discardableResult
    func save() -> Bool {
        do {
            let configuration = try StreamingConfiguration(rawURL: rtmpURL)
            defaults?.set(configuration.sanitizedURLString, forKey: TVFlowShared.rtmpURLDefaultsKey)
            rtmpURL = configuration.sanitizedURLString
            savedConfiguration = configuration
            statusMessage = "已保存：\(configuration.sanitizedURLString)"
            return true
        } catch {
            statusMessage = error.localizedDescription
            return false
        }
    }
}
