////
////  ContentView 2.swift
////  gestureRec
////
////  Created by 杨东举 on 2025/8/3.
////
//
//
//import SwiftUI
//import CoreMotion
//
//struct ContentView: View {
//    @StateObject private var motionManager = MotionManager()
//    @State private var currentGesture = "等待交互..."
//    @State private var capsuleColor = Color.blue
//    @State private var isPressed = false
//    @State private var gestureOffset = CGSize.zero
//    @State private var pulseAnimation = false
//    @State private var swingAnimation = false
//    @State private var swingDirection: Double = 0
//    
//    var body: some View {
//        ZStack {
//            // 背景渐变
//            LinearGradient(
//                gradient: Gradient(colors: [Color.black, Color.gray.opacity(0.3)]),
//                startPoint: .top,
//                endPoint: .bottom
//            )
//            .ignoresSafeArea()
//            
//            VStack(spacing: 30) {
//                // 状态信息面板
//                VStack(alignment: .leading, spacing: 10) {
//                    HStack {
//                        Image(systemName: motionManager.isHorizontal ? "rectangle.landscape" : "rectangle.portrait")
//                        Text(motionManager.isHorizontal ? "横向模式" : "纵向模式")
//                            .fontWeight(.bold)
//                    }
//                    .font(.title2)
//                    .foregroundColor(.white)
//                    
//                    Text("当前手势: \(currentGesture)")
//                        .font(.headline)
//                        .foregroundColor(.white.opacity(0.8))
//                    
//                    // 只在纵向模式下显示挥动信息
//                    if !motionManager.isHorizontal && motionManager.shakeCount > 0 {
//                        VStack(alignment: .leading, spacing: 5) {
//                            HStack {
//                                Image(systemName: "hand.wave.fill")
//                                Text("挥动检测")
//                                    .fontWeight(.semibold)
//                            }
//                            .foregroundColor(.yellow)
//                            
//                            HStack(spacing: 20) {
//                                if motionManager.upSwingCount > 0 {
//                                    HStack(spacing: 5) {
//                                        Image(systemName: "arrow.up.circle.fill")
//                                        Text("向上 × \(motionManager.upSwingCount)")
//                                    }
//                                    .foregroundColor(.green)
//                                }
//                                
//                                if motionManager.downSwingCount > 0 {
//                                    HStack(spacing: 5) {
//                                        Image(systemName: "arrow.down.circle.fill")
//                                        Text("向下 × \(motionManager.downSwingCount)")
//                                    }
//                                    .foregroundColor(.orange)
//                                }
//                            }
//                            .font(.caption)
//                            
//                            if !motionManager.shakeDirection.isEmpty {
//                                Text("最后: \(motionManager.shakeDirection)")
//                                    .font(.caption2)
//                                    .foregroundColor(.white.opacity(0.7))
//                            }
//                        }
//                        .transition(.scale)
//                    }
//                }
//                .padding()
//                .background(Color.black.opacity(0.5))
//                .cornerRadius(15)
//                
//                Spacer()
//                
//                // 胶囊主体
//                ZStack {
//                    // 胶囊形状
//                    Capsule()
//                        .fill(
//                            LinearGradient(
//                                gradient: Gradient(colors: [capsuleColor, capsuleColor.opacity(0.6)]),
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//                        .frame(
//                            width: motionManager.isHorizontal ? 250 : 120,
//                            height: motionManager.isHorizontal ? 120 : 250
//                        )
//                        .shadow(color: capsuleColor.opacity(0.5), radius: isPressed ? 30 : 15)
//                        .scaleEffect(isPressed ? 0.95 : 1.0)
//                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
//                        .rotationEffect(.degrees(swingAnimation ? swingDirection : 0))
//                        .offset(gestureOffset)
//                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
//                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: gestureOffset)
//                        .animation(.easeInOut(duration: 0.5), value: pulseAnimation)
//                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: swingAnimation)
//                    
//                    // 触摸指示器
//                    if isPressed {
//                        Circle()
//                            .fill(Color.white.opacity(0.3))
//                            .frame(width: 80, height: 80)
//                            .blur(radius: 20)
//                    }
//                    
//                    // 方向指示箭头
//                    Image(systemName: motionManager.isHorizontal ? "arrow.left.arrow.right" : "arrow.up.arrow.down")
//                        .font(.system(size: 40))
//                        .foregroundColor(.white.opacity(0.7))
//                }
//                .gesture(createGestures())
//                
//                Spacer()
//                
//                // 操作提示
//                VStack(spacing: 8) {
//                    Text("操作提示")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                    
//                    Text(motionManager.isHorizontal ?
//                         "• 左右滑动 • 点击/双击/长按" :
//                         "• 上下滑动 • 点击/双击/长按")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.7))
//                    
//                    if !motionManager.isHorizontal {
//                        Text("• 快速向上抬起/向下压下设备")
//                            .font(.caption)
//                            .foregroundColor(.white.opacity(0.7))
//                    }
//                }
//                .padding()
//            }
//            .padding()
//        }
//        .onAppear {
//            motionManager.startMotionUpdates()
//        }
//        .onDisappear {
//            motionManager.stopMotionUpdates()
//        }
//        .onChange(of: motionManager.upSwingCount) { _ in
//            if motionManager.upSwingCount > 0 {
//                updateGesture("向上挥动")
//                animateCapsule(color: .green)
//                // 添加向上摆动动画
//                swingDirection = -15
//                swingAnimation = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    swingAnimation = false
//                    swingDirection = 0
//                }
//            }
//        }
//        .onChange(of: motionManager.downSwingCount) { _ in
//            if motionManager.downSwingCount > 0 {
//                updateGesture("向下挥动")
//                animateCapsule(color: .orange)
//                // 添加向下摆动动画
//                swingDirection = 15
//                swingAnimation = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    swingAnimation = false
//                    swingDirection = 0
//                }
//            }
//        }
//    }
//    
//    func createGestures() -> some Gesture {
//        let tap = TapGesture(count: 1)
//            .onEnded { _ in
//                updateGesture("点击")
//                animateCapsule(color: .green)
//            }
//        
//        let doubleTap = TapGesture(count: 2)
//            .onEnded { _ in
//                updateGesture("双击")
//                animateCapsule(color: .purple)
//                pulseAnimation = true
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    pulseAnimation = false
//                }
//            }
//        
//        let longPress = LongPressGesture(minimumDuration: 0.5)
//            .onChanged { _ in
//                isPressed = true
//            }
//            .onEnded { _ in
//                updateGesture("长按")
//                animateCapsule(color: .orange)
//                isPressed = false
//            }
//        
//        let drag = DragGesture()
//            .onChanged { value in
//                if motionManager.isHorizontal {
//                    // 横向模式：只允许左右滑动
//                    gestureOffset = CGSize(width: value.translation.width, height: 0)
//                } else {
//                    // 纵向模式：只允许上下滑动
//                    gestureOffset = CGSize(width: 0, height: value.translation.height)
//                }
//            }
//            .onEnded { value in
//                if motionManager.isHorizontal {
//                    if value.translation.width > 50 {
//                        updateGesture("右滑")
//                        animateCapsule(color: .cyan)
//                    } else if value.translation.width < -50 {
//                        updateGesture("左滑")
//                        animateCapsule(color: .pink)
//                    }
//                } else {
//                    if value.translation.height > 50 {
//                        updateGesture("下滑")
//                        animateCapsule(color: .yellow)
//                    } else if value.translation.height < -50 {
//                        updateGesture("上滑")
//                        animateCapsule(color: .mint)
//                    }
//                }
//                
//                withAnimation(.spring()) {
//                    gestureOffset = .zero
//                }
//            }
//        
//        return drag.simultaneously(with: longPress.exclusively(before: doubleTap.exclusively(before: tap)))
//    }
//    
//    func updateGesture(_ gesture: String) {
//        withAnimation {
//            currentGesture = gesture
//        }
//        
//        // 3秒后重置
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            withAnimation {
//                if currentGesture == gesture {
//                    currentGesture = "等待交互..."
//                }
//            }
//        }
//    }
//    
//    func animateCapsule(color: Color) {
//        withAnimation(.easeInOut(duration: 0.3)) {
//            capsuleColor = color
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            withAnimation(.easeInOut(duration: 0.3)) {
//                capsuleColor = .blue
//            }
//        }
//    }
//}
//
//// 运动管理器
//class MotionManager: ObservableObject {
//    private let motionManager = CMMotionManager()
//    @Published var isHorizontal = false
//    @Published var shakeCount = 0
//    @Published var shakeDirection = ""
//    @Published var upSwingCount = 0
//    @Published var downSwingCount = 0
//    
//    private var lastShakeTime = Date()
//    private var previousY: Double = 0
//    private var isSwinging = false
//    private var velocityBuffer: [Double] = []
//    private let bufferSize = 5
//    
//    func startMotionUpdates() {
//        // 设备方向检测
//        if motionManager.isDeviceMotionAvailable {
//            motionManager.deviceMotionUpdateInterval = 0.1
//            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
//                guard let motion = motion else { return }
//                
//                // 根据重力方向判断设备方向
//                let x = abs(motion.gravity.x)
//                let y = abs(motion.gravity.y)
//                let z = abs(motion.gravity.z)
//                
//                // 如果x轴重力最大，说明设备横向
//                self?.isHorizontal = x > y && x > z
//            }
//        }
//        
//        // 使用设备运动数据进行更精确的挥动检测
//        if motionManager.isDeviceMotionAvailable {
//            motionManager.deviceMotionUpdateInterval = 0.02 // 提高采样率
//            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
//                guard let motion = motion, let self = self else { return }
//                
//                // 只在纵向模式下检测上下挥动
//                if self.isHorizontal {
//                    return
//                }
//                
//                // 使用用户加速度（去除重力影响）
//                let userAccelY = motion.userAcceleration.y
//                
//                // 将Y轴加速度添加到缓冲区
//                self.velocityBuffer.append(userAccelY)
//                if self.velocityBuffer.count > self.bufferSize {
//                    self.velocityBuffer.removeFirst()
//                }
//                
//                // 计算平均加速度
//                let avgAccel = self.velocityBuffer.reduce(0, +) / Double(self.velocityBuffer.count)
//                
//                // 向上挥动检测（Y轴正向加速度）
//                if avgAccel > 0.8 && !self.isSwinging {
//                    let now = Date()
//                    if now.timeIntervalSince(self.lastShakeTime) > 0.3 {
//                        self.isSwinging = true
//                        self.upSwingCount += 1
//                        self.shakeDirection = "↑ 向上"
//                        self.shakeCount += 1
//                        self.lastShakeTime = now
//                        
//                        // 重置状态
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            self.isSwinging = false
//                        }
//                        
//                        // 清空缓冲区，避免重复检测
//                        self.velocityBuffer.removeAll()
//                    }
//                }
//                
//                // 向下挥动检测（Y轴负向加速度）
//                if avgAccel < -0.8 && !self.isSwinging {
//                    let now = Date()
//                    if now.timeIntervalSince(self.lastShakeTime) > 0.3 {
//                        self.isSwinging = true
//                        self.downSwingCount += 1
//                        self.shakeDirection = "↓ 向下"
//                        self.shakeCount += 1
//                        self.lastShakeTime = now
//                        
//                        // 重置状态
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                            self.isSwinging = false
//                        }
//                        
//                        // 清空缓冲区，避免重复检测
//                        self.velocityBuffer.removeAll()
//                    }
//                }
//                
//                // 5秒后重置计数
//                if self.shakeCount > 0 {
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                        if self.shakeCount > 0 {
//                            self.shakeCount = 0
//                            self.upSwingCount = 0
//                            self.downSwingCount = 0
//                            self.shakeDirection = ""
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    func stopMotionUpdates() {
//        motionManager.stopDeviceMotionUpdates()
//        motionManager.stopAccelerometerUpdates()
//    }
//}
//
//// 预览
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
