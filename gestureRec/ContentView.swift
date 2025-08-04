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
//                    if motionManager.shakeCount > 0 {
//                        HStack {
//                            Image(systemName: "hand.wave.fill")
//                            Text("挥动 \(motionManager.shakeCount) 次")
//                        }
//                        .foregroundColor(.yellow)
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
//                        .offset(gestureOffset)
//                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
//                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: gestureOffset)
//                        .animation(.easeInOut(duration: 0.5), value: pulseAnimation)
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
//                    Text("• 快速挥动设备检测挥动次数")
//                        .font(.caption)
//                        .foregroundColor(.white.opacity(0.7))
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
//    
//    private var lastShakeTime = Date()
//    private var shakeThreshold: Double = 2.5
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
//        // 加速度检测（用于挥动）
//        if motionManager.isAccelerometerAvailable {
//            motionManager.accelerometerUpdateInterval = 0.1
//            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
//                guard let data = data, let self = self else { return }
//                
//                let acceleration = sqrt(
//                    pow(data.acceleration.x, 2) +
//                    pow(data.acceleration.y, 2) +
//                    pow(data.acceleration.z, 2)
//                )
//                
//                // 检测快速移动
//                if acceleration > self.shakeThreshold {
//                    let now = Date()
//                    if now.timeIntervalSince(self.lastShakeTime) > 0.5 {
//                        self.shakeCount += 1
//                        self.lastShakeTime = now
//                        
//                        // 2秒后重置计数
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                            self.shakeCount = 0
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
