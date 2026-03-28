# TVFlow

TVFlow 提供一个使用 Swift 编写的 iOS 录屏推流示例：主应用负责保存 MediaMTX 的 RTMP 地址并唤起系统录屏面板，Broadcast Upload Extension 负责接收 ReplayKit 的屏幕采样并通过 RTMP 推送到 MediaMTX。

## 项目结构

- `Package.swift`：可在当前仓库直接运行的共享核心模块，负责校验 RTMP 推流地址。
- `ios/project.yml`：使用 XcodeGen 描述 iOS App 与 Broadcast Upload Extension。
- `ios/TVFlowApp`：SwiftUI 主应用，保存推流地址并展示系统录屏按钮。
- `ios/TVFlowBroadcastUploadExtension`：ReplayKit 扩展，使用 HaishinKit 将录屏样本推送到 MediaMTX。

## 本地验证

当前 Linux 环境下可直接运行共享模块测试：

```bash
swift test
```

在 macOS 上生成并运行 iOS 工程：

```bash
brew install xcodegen
cd ios
xcodegen generate
open TVFlow.xcodeproj
```

然后在 Xcode 中完成以下配置：

1. 为 App 和 Broadcast Upload Extension 配置同一个 Team。
2. 在 Signing & Capabilities 中保留 `App Groups`，组名使用 `group.ppmoon.tvflow`。
3. 将 MediaMTX 的 RTMP 地址填入 App，例如 `rtmp://192.168.1.10:1935/live/ios`。
4. 点击系统录屏按钮，选择 `TVFlow` 开始广播。

## MediaMTX 示例

确保 MediaMTX 已开启 RTMP 监听（默认 `1935` 端口即可）：

```yaml
rtmp: yes
paths:
  live:
    publishUser: ""
    publishPass: ""
```

启动推流后，可在 MediaMTX 所在机器上使用以下地址播放：

```text
rtmp://<mediamtx-host>:1935/live/ios
```
