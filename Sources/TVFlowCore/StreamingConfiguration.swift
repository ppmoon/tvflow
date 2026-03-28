import Foundation

public enum TVFlowShared {
  public static let appGroupIdentifier = "group.ppmoon.tvflow"
  public static let rtmpURLDefaultsKey = "tvflow.streaming.rtmpURL"
  public static let defaultRTMPURL = "rtmp://127.0.0.1:1935/live/ios"
  public static let broadcastExtensionBundleIdentifier = "ppmoon.tvflow.broadcast"
}

public enum StreamingConfigurationError: LocalizedError, Equatable {
  case emptyURL
  case invalidURL
  case unsupportedScheme(String)
  case missingHost
  case missingStreamPath

  public var errorDescription: String? {
    switch self {
    case .emptyURL:
      return "请输入完整的 RTMP 推流地址。"
    case .invalidURL:
      return "无法解析 RTMP 推流地址。"
    case .unsupportedScheme(let scheme):
      return "仅支持 rtmp 或 rtmps，当前为 \(scheme)。"
    case .missingHost:
      return "RTMP 地址缺少主机名。"
    case .missingStreamPath:
      return "RTMP 地址需要包含应用名和流名称，例如 /live/ios。"
    }
  }
}

public struct StreamingConfiguration: Equatable, Sendable {
  public let url: URL

  public init(rawURL: String) throws {
    let trimmed = rawURL.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      throw StreamingConfigurationError.emptyURL
    }
    guard let parsedURL = URL(string: trimmed) else {
      throw StreamingConfigurationError.invalidURL
    }
    try self.init(url: parsedURL)
  }

  public init(url: URL) throws {
    guard let scheme = url.scheme?.lowercased(), ["rtmp", "rtmps"].contains(scheme) else {
      throw StreamingConfigurationError.unsupportedScheme(url.scheme?.lowercased() ?? "missing")
    }
    guard let host = url.host, !host.isEmpty else {
      throw StreamingConfigurationError.missingHost
    }
    let components = url.pathComponents.filter { $0 != "/" }
    guard components.count >= 2 else {
      throw StreamingConfigurationError.missingStreamPath
    }

    var normalized = URLComponents(url: url, resolvingAgainstBaseURL: false)
    normalized?.scheme = scheme
    normalized?.host = host

    guard let rebuilt = normalized?.url else {
      throw StreamingConfigurationError.invalidURL
    }
    self.url = rebuilt
  }

  public var sanitizedURLString: String {
    url.absoluteString
  }

  public var applicationName: String {
    let components = url.pathComponents.filter { $0 != "/" }
    return components.dropLast().joined(separator: "/")
  }

  public var streamName: String {
    url.lastPathComponent
  }
}
