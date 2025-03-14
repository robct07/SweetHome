import SwiftUI
import UIKit

// 定义分享类型
enum ShareType: String, CaseIterable {
    case mood = "Mood"
    case write = "Write"
    case media = "Media"
}

// 主分享视图
struct ShareView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @State private var currentShareType: ShareType = .mood
    @State private var showConfirmExit = false
    @State private var currentThemeColor: Color = Color(hex: "#FF9D1D")
    @State private var showTemplateSelection = false
    @State private var showShareSuccess = false
    
    var body: some View {
        VStack {
            // 关闭按钮
            HStack {
                Button(action: {
                    showConfirmExit = true
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .font(.title2)
                }
                .padding()
                Spacer()
            }
            
            // 分享内容区域
            switch currentShareType {
            case .mood:
                MoodShareView(themeColor: $currentThemeColor)  // 传递主题色绑定
            case .write:
                WriteVoiceShareView(themeColor: $currentThemeColor)
            case .media:
                MediaShareView(themeColor: $currentThemeColor)
            }
            
                // 底部导航和按钮
                VStack(spacing: 40) {
                    // 更新分享类型选择器
                    ScrollViewReader { scrollProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 30) {
                                ForEach(ShareType.allCases, id: \.self) { type in
                                    Text(type.rawValue)
                                        .font(.system(size: type == currentShareType ? 17 : 15))
                                        .fontWeight(type == currentShareType ? .semibold : .regular)
                                        .foregroundColor(type == currentShareType ? .black : .gray)
                                        .id(type)
                                        .onTapGesture {
                                            withAnimation {
                                                currentShareType = type
                                                scrollProxy.scrollTo(type, anchor: .center)
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, UIScreen.main.bounds.width / 2.2) // 添加足够的边距使内容可以居中
                        }
                        .onChange(of: currentShareType) { oldValue, newValue in
                            withAnimation {
                                scrollProxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                    
                // 底部按钮
                    HStack(spacing: 20) {
                        Button(action: {
                            showConfirmExit = true
                        }) {
                            Text("Done")
                                .font(.headline)
                                .foregroundColor(currentThemeColor)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(currentThemeColor, lineWidth: 2)
                                )
                        }
                        
                        Button(action: {
                            if currentShareType == .media {
                                showTemplateSelection = true
                            } else {
                                if let currentIndex = ShareType.allCases.firstIndex(of: currentShareType) {
                                    let nextIndex = (currentIndex + 1) % ShareType.allCases.count
                                    currentShareType = ShareType.allCases[nextIndex]
                                }
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(currentThemeColor)
                                .cornerRadius(25)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .sheet(isPresented: $showTemplateSelection) {
                    TemplateSelectionView(themeColor: $currentThemeColor)
                        .environmentObject(navigationManager)  // 添加这行
                }
        }
        .animation(.easeInOut(duration: 0.3), value: currentThemeColor)  // 颜色切换动画
        .alert("Save and Exit?", isPresented: $showConfirmExit) {
            Button("Cancel", role: .cancel) { }
            Button("Save & Exit") {
                dismiss()
            }
        }
        .onAppear {
             // 添加通知观察者
             NotificationCenter.default.addObserver(
                 forName: .dismissAllShareViews,
                 object: nil,
                 queue: .main) { _ in
                     dismiss()
                 }
         }
    }
}

// 修改心情类型枚举
enum MoodType: String, CaseIterable {
    case happy = "Happy"
    case content = "Content"
    case uncertain = "Uncertain"
    case sad = "Sad"
    case depressed = "Depressed"
    
    var imageName: String {
        // 返回对应的图片名称
        switch self {
        case .happy: return "mood_happy"
        case .content: return "mood_content"
        case .uncertain: return "mood_uncertain"
        case .sad: return "mood_sad"
        case .depressed: return "mood_depressed"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .happy: return Color(hex: "#FF5277")
        case .content: return Color(hex: "#FF9D1D")
        case .uncertain: return Color(hex: "#AACA1D")
        case .sad: return Color(hex: "#1470EE")
        case .depressed: return Color(hex: "#1C47B2")
        }
    }
}

struct MoodShareView: View {
    @Binding var themeColor: Color  // 主题色绑定
    @State private var selectedMood: MoodType = .content
    @State private var dragOffset: CGFloat = 0
    @GestureState private var isDragging: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("How was your day?")
                .font(.system(size: 32))
                .fontWeight(.medium)
            
            Text("Swipe up and down to change emotions")
                .font(.system(size: 17))
                .foregroundColor(.gray)
            
            // 心情图片区域
            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height) * 0.80 // 图片大小
                
                VStack {
                    // 当前心情
                    Image(selectedMood.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .offset(y: dragOffset)
                        .gesture(
                            DragGesture()
                                .updating($isDragging) { value, state, _ in
                                    state = true
                                }
                                .onChanged { value in
                                    dragOffset = value.translation.height
                                }
                                .onEnded { value in
                                    let threshold: CGFloat = 50
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        if value.translation.height > threshold {
                                            selectedMood = previousMood()
                                        } else if value.translation.height < -threshold {
                                            selectedMood = nextMood()
                                        }
                                        dragOffset = 0
                                    }
                                }
                        )
                    
                    
                    // 向下箭头
                    Image(systemName: "chevron.down")
                        .font(.system(size: 24))
                        .foregroundColor(selectedMood.themeColor)
                        .opacity(0.8)
                        .padding(.top, 20)
                        .modifier(FloatingAnimation())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 400)
            
            Spacer()
        }
        .onChange(of: selectedMood) { oldValue, newValue in
            themeColor = newValue.themeColor  // 更新主题色
        }
        .onAppear {
            // 确保初始状态也设置正确的颜色
            themeColor = selectedMood.themeColor
        }
        .animation(.easeInOut(duration: 0.3), value: selectedMood)  // 颜色切换动画
    }
    
    // 获取下一个心情
    private func nextMood() -> MoodType {
        let allMoods = MoodType.allCases
        guard let currentIndex = allMoods.firstIndex(of: selectedMood) else { return selectedMood }
        let nextIndex = (currentIndex + 1) % allMoods.count
        return allMoods[nextIndex]
    }
    
    // 获取上一个心情
    private func previousMood() -> MoodType {
        let allMoods = MoodType.allCases
        guard let currentIndex = allMoods.firstIndex(of: selectedMood) else { return selectedMood }
        let previousIndex = (currentIndex - 1 + allMoods.count) % allMoods.count
        return allMoods[previousIndex]
    }
}

// 浮动动画修饰器
struct FloatingAnimation: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? 5 : -5)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}



// WriteVoiceShareView
struct WriteVoiceShareView: View {
    @Binding var themeColor: Color
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    @State private var isRecording = false
    @State private var hasRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    @State private var isTextBoxExpanded = true
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Share anything you'd like to express~")
                .font(.system(size: 34))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text("or share today's little blessing!")
                .font(.system(size: 17))
                .foregroundColor(.gray)
            
            // 文本输入区域
            TextEditor(text: $text)
                .frame(height: isTextBoxExpanded ? 150 : 80)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(themeColor.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(themeColor.opacity(0.3), lineWidth: 1)
                )
                .focused($isFocused)
                .onTapGesture {
                    isTextBoxExpanded = true
                }
                .animation(.spring(response: 0.3), value: isTextBoxExpanded)
            
            // 录音显示区域
            if hasRecording {
                HStack {
                    Button(action: {
                        // 播放录音
                    }) {
                        Image(systemName: "play.fill")
                            .foregroundColor(themeColor)
                    }
                    Image(systemName: "waveform")
                        .foregroundColor(themeColor)
                    Text(String(format: "%.1f\"", recordingDuration))
                        .foregroundColor(.gray)
                    Spacer()
                    Button(action: {
                        // 删除录音
                        hasRecording = false
                        recordingDuration = 0
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(themeColor.opacity(0.1))
                )
            }
            
            Spacer()
            
            // 录音按钮
            Button(action: {}) {
                Circle()
                    .fill(isRecording ? themeColor : themeColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "mic.fill")
                            .foregroundColor(isRecording ? .white : themeColor)
                            .font(.system(size: 30))
                    )
                    .scaleEffect(isRecording ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isRecording)
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isRecording {
                            startRecording()
                        }
                    }
                    .onEnded { _ in
                        stopRecording()
                    }
            )
            .padding(.bottom, 30)
        }
        .padding(.horizontal)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
    
    private func startRecording() {
        isRecording = true
        hasRecording = true
        // 开始计时
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingDuration += 0.1
        }
        // 这里添加实际的录音逻辑
    }
    
    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        // 这里添加停止录音的逻辑
    }
}

//MediaShareView
struct MediaShareView: View {
    @Binding var themeColor: Color
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage?
    @State private var isDrawing = false
    @State private var drawings: [Drawing] = []
    @State private var currentLine: Drawing?
    
    var body: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                // 显示选择的图片/视频
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .overlay(
                        Canvas { context, size in
                            // 显示绘画
                            for drawing in drawings {
                                context.stroke(
                                    drawing.path,
                                    with: .color(drawing.color),
                                    lineWidth: drawing.lineWidth
                                )
                            }
                        }
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if isDrawing {
                                        let point = value.location
                                        if currentLine == nil {
                                            currentLine = Drawing(
                                                path: Path(),
                                                color: themeColor,
                                                lineWidth: 3
                                            )
                                            currentLine?.path.move(to: point)
                                        } else {
                                            currentLine?.path.addLine(to: point)
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    if let line = currentLine {
                                        drawings.append(line)
                                        currentLine = nil
                                    }
                                }
                        )
                    )
            } else {
                Text("Share your photos or videos")
                    .font(.system(size: 34))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                
                Text("Choose from library or take a new one")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                
                Spacer()
                
                // 媒体选择按钮
                HStack(spacing: 30) {
                    MediaButton(
                        icon: "photo",
                        title: "Choose Photo",
                        color: themeColor
                    ) {
                        showImagePicker = true
                    }
                    
                    MediaButton(
                        icon: "camera",
                        title: "Take Photo",
                        color: themeColor
                    ) {
                        showCamera = true
                    }
                }
                .padding(.bottom, 200)  // 添加底部间距
            }
            
            if selectedImage != nil {
                // 绘画工具栏
                HStack {
                    Button(action: {
                        isDrawing.toggle()
                    }) {
                        Image(systemName: isDrawing ? "pencil.slash" : "pencil")
                            .foregroundColor(themeColor)
                    }
                    
                    if !drawings.isEmpty {
                        Button(action: {
                            drawings.removeLast()
                        }) {
                            Image(systemName: "arrow.uturn.backward")
                                .foregroundColor(themeColor)
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
    }
}

struct Drawing {
    var path: Path
    var color: Color
    var lineWidth: CGFloat
}

struct MediaButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(color)
            .frame(width: 120, height: 120)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(color, lineWidth: 2)
            )
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

struct TemplateSelectionView: View {
    @EnvironmentObject private var navigationManager: NavigationManager  // 添加这行
    @Environment(\.dismiss) private var dismiss
    @Binding var themeColor: Color
    @State private var selectedTemplate: TemplateType?
    @State private var showShareSuccess = false
    
    enum TemplateType {
        case original
        case freestyle
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose a template for sharing")
                .font(.system(size: 34))
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.top)
            
            // Larger template buttons with less spacing
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                TemplateButton(
                    icon: "square.grid.2x2",
                    title: "Original",
                    isSelected: selectedTemplate == .original,
                    color: themeColor
                ) {
                    selectedTemplate = .original
                }
                
                TemplateButton(
                    icon: "square.on.square",
                    title: "Freestyle",
                    isSelected: selectedTemplate == .freestyle,
                    color: themeColor
                ) {
                    selectedTemplate = .freestyle
                }
            }
            .padding()
            
            Text("More templates coming soon!")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.top)
            
            Spacer()
            
            
            // Bottom buttons
            HStack(spacing: 20) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Back")
                        .font(.headline)
                        .foregroundColor(themeColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(themeColor, lineWidth: 2)
                        )
                }
                
                Button(action: {
                    showShareSuccess = true
                }) {
                    Text("Share")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeColor)
                        .cornerRadius(25)
                }
                .disabled(selectedTemplate == nil)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .alert("Share Success!", isPresented: $showShareSuccess) {
            Button("Just Share") {
                // 使用导航管理器
                navigationManager.navigateToHome()
                dismiss()
            }
            Button("Print") {
                // 使用导航管理器
                navigationManager.navigateToHome()
                dismiss()
            }
        } message: {
            Text("Would you like to print your memory?")
        }
    }
}

// 添加通知名称扩展
extension Notification.Name {
    static let dismissAllShareViews = Notification.Name("dismissAllShareViews")
}

struct TemplateButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 40))
                Text(title)
                    .font(.title3)
            }
            .foregroundColor(isSelected ? .white : color)
            .frame(width: 160, height: 160)  // Increased size
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? color : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(color, lineWidth: 2)
            )
        }
    }
}

// 预览
#Preview {
    ShareView()
        .environmentObject(NavigationManager.shared) 
}
//
//  ShareViews.swift
//  Sweet Memories
//
//  Created by Yunuo Jin on 2/24/25.
//

