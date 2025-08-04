////
////  GestureType.swift
////  gestureRec
////
////  Created by 杨东举 on 2025/8/3.
////
//
//
//import SwiftUI
//import CoreMotion
//
//// 手势类型枚举
//enum GestureType {
//    case liftUp    // 向上抬
//    case pushDown  // 向下压
//    case none
//}
//
//// 手势检测器
//class MotionDetector: ObservableObject {
//    private let motionManager = CMMotionManager()
//    private let queue = OperationQueue()
//    
//    @Published var currentGesture: GestureType = .none
//    @Published var liftUpCount = 0
//    @Published var pushDownCount = 0
//    @Published var lastGestureTime: Date?
//    @Published var isDetecting = false
//    
//    // 阈值设置
//    private let accelerationThreshold: Double = 0.5  // 加速度阈值
//    private let timeInterval: TimeInterval = 0.1    // 采样间隔
//    private var lastAcceleration: Double = 0
//    private var gestureStartTime: Date?
//    private let minGestureDuration: TimeInterval = 0.2  // 最小手势持续时间
//    
//    init() {
//        queue.maxConcurrentOperationCount = 1
//        queue.name = "MotionQueue"
//    }
//    
//    func startDetection() {
//        guard motionManager.isAccelerometerAvailable else {
//            print("加速度计不可用")
//            return
//        }
//        
//        isDetecting = true
//        motionManager.accelerometerUpdateInterval = timeInterval
//        
//        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
//            guard let self = self, let data = data else { return }
//            
//            // 获取Y轴加速度（垂直方向）
//            let currentAcceleration = data.acceleration.y
//            
//            // 计算加速度变化
//            let accelerationChange = currentAcceleration - self.lastAcceleration
//            
//            DispatchQueue.main.async {
//                // 检测向上抬起（正向加速度变化）
//                if accelerationChange > self.accelerationThreshold {
//                    if self.currentGesture != .liftUp {
//                        self.currentGesture = .liftUp
//                        self.gestureStartTime = Date()
//                    }
//                }
//                // 检测向下压（负向加速度变化）
//                else if accelerationChange < -self.accelerationThreshold {
//                    if self.currentGesture != .pushDown {
//                        self.currentGesture = .pushDown
//                        self.gestureStartTime = Date()
//                    }
//                }
//                // 手势结束
//                else if abs(accelerationChange) < 0.1 && self.currentGesture != .none {
//                    // 检查手势持续时间
//                    if let startTime = self.gestureStartTime,
//                       Date().timeIntervalSince(startTime) >= self.minGestureDuration {
//                        // 记录有效手势
//                        self.recordGesture()
//                    }
//                    self.currentGesture = .none
//                    self.gestureStartTime = nil
//                }
//            }
//            
//            self.lastAcceleration = currentAcceleration
//        }
//    }
//    
//    func stopDetection() {
//        motionManager.stopAccelerometerUpdates()
//        isDetecting = false
//        currentGesture = .none
//    }
//    
//    private func recordGesture() {
//        lastGestureTime = Date()
//        
//        switch currentGesture {
//        case .liftUp:
//            liftUpCount += 1
//            generateHapticFeedback()
//        case .pushDown:
//            pushDownCount += 1
//            generateHapticFeedback()
//        case .none:
//            break
//        }
//    }
//    
//    private func generateHapticFeedback() {
//        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
//        impactFeedback.impactOccurred()
//    }
//    
//    func reset() {
//        liftUpCount = 0
//        pushDownCount = 0
//        lastGestureTime = nil
//        currentGesture = .none
//    }
//}
//
//// 主视图
//struct ContentView: View {
//    @StateObject private var motionDetector = MotionDetector()
//    @State private var showingResetAlert = false
//    
//    var body: some View {
//        VStack(spacing: 30) {
//            // 标题
//            Text("手机手势检测器")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//            
//            // 当前手势指示器
//            GestureIndicator(currentGesture: motionDetector.currentGesture)
//            
//            // 统计信息
//            VStack(spacing: 20) {
//                StatCard(
//                    title: "向上抬起",
//                    count: motionDetector.liftUpCount,
//                    color: .blue,
//                    icon: "arrow.up.circle.fill"
//                )
//                
//                StatCard(
//                    title: "向下压",
//                    count: motionDetector.pushDownCount,
//                    color: .green,
//                    icon: "arrow.down.circle.fill"
//                )
//            }
//            
//            // 最后手势时间
//            if let lastTime = motionDetector.lastGestureTime {
//                Text("最后检测时间: \(timeFormatter.string(from: lastTime))")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//            
//            Spacer()
//            
//            // 控制按钮
//            HStack(spacing: 20) {
//                Button(action: {
//                    if motionDetector.isDetecting {
//                        motionDetector.stopDetection()
//                    } else {
//                        motionDetector.startDetection()
//                    }
//                }) {
//                    Label(
//                        motionDetector.isDetecting ? "停止检测" : "开始检测",
//                        systemImage: motionDetector.isDetecting ? "stop.circle.fill" : "play.circle.fill"
//                    )
//                    .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(.borderedProminent)
//                .controlSize(.large)
//                
//                Button(action: {
//                    showingResetAlert = true
//                }) {
//                    Label("重置", systemImage: "arrow.clockwise")
//                        .frame(maxWidth: .infinity)
//                }
//                .buttonStyle(.bordered)
//                .controlSize(.large)
//            }
//        }
//        .padding()
//        .alert("重置统计", isPresented: $showingResetAlert) {
//            Button("取消", role: .cancel) { }
//            Button("重置", role: .destructive) {
//                motionDetector.reset()
//            }
//        } message: {
//            Text("确定要重置所有统计数据吗？")
//        }
//    }
//    
//    private var timeFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .none
//        return formatter
//    }
//}
//
//// 手势指示器组件
//struct GestureIndicator: View {
//    let currentGesture: GestureType
//    
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .fill(backgroundColor)
//                .frame(height: 120)
//            
//            VStack(spacing: 10) {
//                Image(systemName: iconName)
//                    .font(.system(size: 50))
//                    .foregroundColor(iconColor)
//                    .animation(.easeInOut(duration: 0.3), value: currentGesture)
//                
//                Text(gestureName)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//            }
//        }
//        .animation(.easeInOut(duration: 0.3), value: currentGesture)
//    }
//    
//    private var backgroundColor: Color {
//        switch currentGesture {
//        case .liftUp:
//            return Color.blue.opacity(0.1)
//        case .pushDown:
//            return Color.green.opacity(0.1)
//        case .none:
//            return Color.gray.opacity(0.1)
//        }
//    }
//    
//    private var iconName: String {
//        switch currentGesture {
//        case .liftUp:
//            return "arrow.up"
//        case .pushDown:
//            return "arrow.down"
//        case .none:
//            return "minus"
//        }
//    }
//    
//    private var iconColor: Color {
//        switch currentGesture {
//        case .liftUp:
//            return .blue
//        case .pushDown:
//            return .green
//        case .none:
//            return .gray
//        }
//    }
//    
//    private var gestureName: String {
//        switch currentGesture {
//        case .liftUp:
//            return "向上抬起"
//        case .pushDown:
//            return "向下压"
//        case .none:
//            return "等待手势"
//        }
//    }
//}
//
//// 统计卡片组件
//struct StatCard: View {
//    let title: String
//    let count: Int
//    let color: Color
//    let icon: String
//    
//    var body: some View {
//        HStack {
//            Image(systemName: icon)
//                .font(.system(size: 40))
//                .foregroundColor(color)
//            
//            VStack(alignment: .leading, spacing: 5) {
//                Text(title)
//                    .font(.headline)
//                
//                HStack( spacing: 5) {
//                    Text("\(count)")
//                        .font(.system(size: 30, weight: .bold))
//                        .foregroundColor(color)
//                    
//                    Text(count == 1 ? "次" : "次")
//                        .font(.body)
//                        .foregroundColor(.secondary)
//                }
//            }
//            
//            Spacer()
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 15)
//                .fill(color.opacity(0.1))
//        )
//    }
//}
