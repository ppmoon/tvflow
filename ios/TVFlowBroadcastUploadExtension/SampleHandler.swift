import Foundation
@preconcurrency import HaishinKit
import ReplayKit
@preconcurrency import RTMPHaishinKit
import TVFlowCore
import VideoToolbox

final class SampleHandler: RPBroadcastSampleHandler {
  private enum BroadcastError: LocalizedError {
    case missingConfiguration

    var errorDescription: String? {
      switch self {
      case .missingConfiguration:
        return "请先在主应用中保存 MediaMTX 的 RTMP 推流地址。"
      }
    }
  }

  private let mixer = MediaMixer(captureSessionMode: .manual)
  private let stateLock = NSLock()
  private var session: Session?
  private var needsVideoConfiguration = true

  override init() {
    super.init()
    Task {
      await SessionBuilderFactory.shared.register(RTMPSessionFactory())
    }
  }

  override func broadcastStarted(withSetupInfo setupInfo: [String: NSObject]?) {
    Task {
      do {
        let configuration = try Self.loadConfiguration()
        let builtSession = try await SessionBuilderFactory.shared.make(configuration.url).build()
        withStateLock {
          session = builtSession
          needsVideoConfiguration = true
        }

        var videoSettings = await mixer.videoMixerSettings
        videoSettings.mode = .passthrough
        await mixer.setVideoMixerSettings(videoSettings)
        await builtSession.stream.setVideoInputBufferCounts(5)
        await mixer.startRunning()

        await mixer.addOutput(builtSession.stream)
        try await builtSession.connect {}
      } catch {
        finishBroadcastWithError(Self.asNSError(error))
      }
    }
  }

  override func broadcastFinished() {
    Task {
      await mixer.stopRunning()
      withStateLock {
        session = nil
        needsVideoConfiguration = true
      }
    }
  }

  override func processSampleBuffer(
    _ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType
  ) {
    switch sampleBufferType {
    case .video:
      Task {
        do {
          try await configureVideoIfNeeded(using: sampleBuffer)
          await mixer.append(sampleBuffer)
        } catch {
          finishBroadcastWithError(Self.asNSError(error))
        }
      }
    case .audioApp, .audioMic:
      guard sampleBuffer.dataReadiness == .ready else {
        return
      }
      Task {
        await mixer.append(sampleBuffer, track: 0)
      }
    @unknown default:
      break
    }
  }

  private func configureVideoIfNeeded(using sampleBuffer: CMSampleBuffer) async throws {
    guard let dimensions = sampleBuffer.formatDescription?.dimensions else {
      return
    }
    guard let session = withStateLock(body: { () -> Session? in
      guard needsVideoConfiguration else {
        return nil
      }
      needsVideoConfiguration = false
      return session
    }) else {
      return
    }

    var videoSettings = await session.stream.videoSettings
    videoSettings.videoSize = CGSize(
      width: CGFloat(dimensions.width), height: CGFloat(dimensions.height))
    videoSettings.profileLevel = kVTProfileLevel_H264_Baseline_AutoLevel as String
    try await session.stream.setVideoSettings(videoSettings)
  }

  private static func loadConfiguration() throws -> StreamingConfiguration {
    guard
      let defaults = UserDefaults(suiteName: TVFlowShared.appGroupIdentifier),
      let rawURL = defaults.string(forKey: TVFlowShared.rtmpURLDefaultsKey)
    else {
      throw BroadcastError.missingConfiguration
    }
    return try StreamingConfiguration(rawURL: rawURL)
  }

  private static func asNSError(_ error: Error) -> NSError {
    let nsError = error as NSError
    if nsError.domain != NSCocoaErrorDomain || nsError.code != 0 {
      return nsError
    }
    return NSError(
      domain: "ppmoon.tvflow.broadcast", code: 1,
      userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
  }

  private func withStateLock<T>(body: () -> T) -> T {
    stateLock.lock()
    defer { stateLock.unlock() }
    return body()
  }
}
