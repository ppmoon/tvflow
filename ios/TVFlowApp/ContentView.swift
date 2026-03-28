import SwiftUI
import TVFlowCore

struct ContentView: View {
  @EnvironmentObject private var settingsStore: StreamingSettingsStore

  var body: some View {
    Form {
      Section("MediaMTX 推流地址") {
        TextField(
          "rtmp://192.168.1.10:1935/live/ios", text: $settingsStore.rtmpURL, axis: .vertical
        )
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)

        Button("保存配置") {
          _ = settingsStore.save()
        }
        .buttonStyle(.borderedProminent)

        Text("请填写 MediaMTX 暴露的 RTMP 地址，格式为 rtmp://主机:1935/应用名/流名。")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }

      Section("开始录屏推流") {
        if let savedConfiguration = settingsStore.savedConfiguration {
          VStack(alignment: .leading, spacing: 6) {
            Label(
              "应用名：\(savedConfiguration.applicationName)",
              systemImage: "dot.radiowaves.left.and.right")
            Label("流名称：\(savedConfiguration.streamName)", systemImage: "key")
          }
          .font(.footnote)
        }

        Text("1. 先点击“保存配置”。\n2. 点击下方系统录屏按钮。\n3. 在系统面板中选择 TVFlow 并开始广播，扩展会将屏幕内容编码后推送到 MediaMTX。")
          .font(.footnote)

        BroadcastPickerView(preferredExtension: TVFlowShared.broadcastExtensionBundleIdentifier)
          .frame(height: 50)
      }

      if let statusMessage = settingsStore.statusMessage {
        Section {
          Text(statusMessage)
            .foregroundStyle(settingsStore.savedConfiguration == nil ? .red : .green)
        }
      }
    }
    .navigationTitle("TVFlow")
  }
}
