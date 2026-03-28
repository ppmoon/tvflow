import Testing

@testable import TVFlowCore

@Test func parsesValidRTMPURL() throws {
  let configuration = try StreamingConfiguration(
    rawURL: "  rtmp://media.example.com:1935/live/ios-demo  ")

  #expect(configuration.sanitizedURLString == "rtmp://media.example.com:1935/live/ios-demo")
  #expect(configuration.applicationName == "live")
  #expect(configuration.streamName == "ios-demo")
}

@Test func supportsRTMPSAndNestedApplications() throws {
  let configuration = try StreamingConfiguration(
    rawURL: "rtmps://secure.example.com/publish/mobile/stream-key")

  #expect(configuration.applicationName == "publish/mobile")
  #expect(configuration.streamName == "stream-key")
}

@Test func rejectsUnsupportedScheme() {
  #expect(throws: StreamingConfigurationError.unsupportedScheme("https")) {
    try StreamingConfiguration(rawURL: "https://media.example.com/live/ios-demo")
  }
}

@Test func rejectsMissingStreamName() {
  #expect(throws: StreamingConfigurationError.missingStreamPath) {
    try StreamingConfiguration(rawURL: "rtmp://media.example.com/live")
  }
}

@Test func rejectsMissingScheme() {
  #expect(throws: StreamingConfigurationError.unsupportedScheme("missing")) {
    try StreamingConfiguration(rawURL: "media.example.com/live/ios-demo")
  }
}
