看代码逻辑，虽然检测到了向下压手势，但计数要在**手势结束时**才会增加。具体来说，计数增加需要满足以下条件：

1. **加速度变化降到 0.1 以下**（表示手势结束）
2. **手势持续时间超过 0.2 秒**

你遇到的问题可能是：
- 手势动作太快，持续时间不足 0.2 秒
- 或者手势结束时，加速度变化没有降到 0.1 以下

**解决方案：**

1. **降低最小手势持续时间**：
```swift
private let minGestureDuration: TimeInterval = 0.1  // 从 0.2 改为 0.1
```

2. **放宽手势结束的判定条件**：
```swift
// 将 0.1 改为 0.2 或 0.3
else if abs(accelerationChange) < 0.2 && self.currentGesture != .none {
```

3. **或者添加超时机制**，在检测到手势后的一定时间自动记录：
```swift
// 在检测到手势时启动一个延时
DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
    if self?.currentGesture != .none {
        self?.recordGesture()
        self?.currentGesture = .none
        self?.gestureStartTime = nil
    }
}
```

建议先试试调整前两个参数，让手势识别更灵敏一些。
