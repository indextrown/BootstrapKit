// The Swift Programming Language
// https://docs.swift.org/swift-book
// https://lafortune.tistory.com/20#google_vignette

import UIKit
import SwiftUI


/// 외부에서 받은 View타입 content를 수정하지 않고 레이아우만 감싸서 적용하는 View
struct WrapperView<Content: View>: View {
    let content: Content
    
    var body: some View {
        content
//            .frame(
//                maxHeight: .infinity,
//                alignment: .top
//            )
    }
}

struct RefreshableScrollView<Content: View>: UIViewRepresentable {
    var content: Content
    var refreshControl = UIRefreshControl()
    var onRefresh: (UIRefreshControl) -> ()
    
    // setting
    var refreshText: String = ""
    var refreshTextColor: UIColor = .label // 텍스트
    var refreshTintColor: UIColor = .blue  // 인디케이터
    
    init(@ViewBuilder content: @escaping () -> Content,
         onRefresh: @escaping (UIRefreshControl) -> ()) {
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        refreshControl.attributedTitle = NSAttributedString(
            string: refreshText,
            attributes: [
                .foregroundColor: refreshTextColor
            ]
        )
        refreshControl.tintColor = refreshTintColor
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.onRefresh),
            for: .valueChanged
        )
        scrollView.refreshControl = refreshControl
        
        let hostingController = UIHostingController(
            rootView: WrapperView(content: content)
        )
        
        context.coordinator.hostingController = hostingController
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostingController.view)
        
        /*
         frameLayoutGuide: 스크롤뷰 자체 크기(화면에 보이는 영역)
         contentLayoutGuide: 스크롤되는 실제 콘텐츠 영역
         */
//        NSLayoutConstraint.activate([
//            // 1. content 영역 정의 (실제 콘텐츠 영역)
//            hostingController.view.topAnchor.constraint(equalTo: uiScrollView.contentLayoutGuide.topAnchor),
//            hostingController.view.leadingAnchor.constraint(equalTo: uiScrollView.contentLayoutGuide.leadingAnchor),
//            hostingController.view.trailingAnchor.constraint(equalTo: uiScrollView.contentLayoutGuide.trailingAnchor),
//            hostingController.view.bottomAnchor.constraint(equalTo: uiScrollView.contentLayoutGuide.bottomAnchor),
//            
//            // 2. frame 기준으로 크기 고정(화면에 보이는 영역)
//            hostingController.view.widthAnchor.constraint(equalTo: uiScrollView.frameLayoutGuide.widthAnchor),
//            hostingController.view.heightAnchor.constraint(equalTo: uiScrollView.frameLayoutGuide.heightAnchor)
//        ])

        NSLayoutConstraint.activate([
            hostingController.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.hostingController?.rootView = WrapperView(content: content)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator {
        var parent: RefreshableScrollView
        var hostingController: UIHostingController<WrapperView<Content>>?
        
        init(parent: RefreshableScrollView) {
            self.parent = parent
        }
        
        @objc
        func onRefresh() {
            parent.onRefresh(parent.refreshControl)
        }
    }
}

// MARK: - Custom Modifier
extension RefreshableScrollView {
    func refreshText(_ text: String) -> Self {
        var copy = self
        copy.refreshText = text
        return copy
    }
    
    func refreshTextColor(_ color: UIColor) -> Self {
        var copy = self
        copy.refreshTextColor = color
        return copy
    }
    
    func refreshTintColor(_ color: UIColor) -> Self {
        var copy = self
        copy.refreshTintColor = color
        return copy
    }
}

struct Sample: View {
    
    @State private var items: [Int] = Array(1..<100)
    var body: some View {
        RefreshableScrollView {
            VStack {
                ForEach(items, id: \.self) { item in
                    Text("\(item)")
                }
            }
            
        } onRefresh: { control in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                items.append(items.count)
                control.endRefreshing()
            }
        }
        .refreshText("테스트 수정")
        .refreshTextColor(.red)
        .refreshTintColor(.green)
    }
}

#Preview {
    Sample()
}


/*
 struct Sample: View {
     
     @State private var items: [Int] = Array(0..<20)
     @State private var isRed: Bool = false
     @State private var refreshCount: Int = 0
     
     var body: some View {
         VStack {
             
             // 상태 변경 버튼 (핵심 테스트)
             Button("색상 변경") {
                 isRed.toggle()
             }
             .padding()
             
             Text("refresh count: \(refreshCount)")
             
             RefreshableScrollView {
                 VStack(spacing: 20) {
                     ForEach(items, id: \.self) { item in
                         Text("Item \(item)")
                             .frame(maxWidth: .infinity)
                             .padding()
                             .background(Color.gray.opacity(0.2))
                             .cornerRadius(10)
                     }
                 }
                 .padding()
             } onRefresh: { control in
                 print("🔥 refresh triggered")
                 
                 DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                     refreshCount += 1
                     
                     // 데이터 추가 (스크롤 유지 테스트)
                     items.append(contentsOf: items.count..<(items.count + 5))
                     
                     control.endRefreshing()
                 }
             }
             .refreshText("당겨서 새로고침")
             .refreshTextColor(isRed ? .red : .blue)   // ⭐️ 상태 변화 테스트
             .refreshTintColor(.green)
         }
     }
 }
 */


/*
 
 (UIRefreshControl) -> ()
 입력: UIRefreshControl
 반환 x
 
 @escaping () -> Content
 입력: x
 반환: Content
 이 클로저를 나중에 쓸거야
 
 @escaping (UIRefreshControl) -> ()
 입력: UIRefreshControl
 반환: x
 이 클로저를 나중에 쓸거야
 
 
 [클로저]
 - 쓰는 이유: 행동을 외부에서 전달하기 위함
 - doSomething {
 print("Hello")
}
 
 1.
 함수를 변수처럼 쓰는 것
 let sayHello = {
     print("Hello")
 }
 sayHello() // 실행
 
 2. 파라미터 있는 클로저
 let add = { (a: Int, b: Int) -> Int in
     return a + b
 }
 print(add(2, 3)) // 5
 
 3. 클로저를 함수에 전달
 func doSomething(action: () -> Void) {
     action()
 }
 doSomething {
     print("실행됨")
 }
 
 4. escaping클로저
 var storedClosure: (() -> Void)?
 func saveClosure(action: @escaping () -> Void) {
     storedClosure = action // 클로저를 저장했기 때문에 escaping 필요
 }
 saveClosure {
     print("나중에 실행됨")
 }
 storedClosure?() // 여기서 실행됨
 
 */


/*
 1. SwiftUI에서 RefreshableScrollView 사용
         ↓
 2. UIViewRepresentable이 UIScrollView 만들어줌
         ↓
 3. 그런데 ScrollView 안에 넣을 건 SwiftUI View
         ↓
 4. UIHostingController로 SwiftUI → UIView 변환
         ↓
 5. ScrollView에 addSubview
 
 
 SwiftUI (Sample)
         ↓
 UIViewRepresentable
         ↓
 UIScrollView (UIKit)
         ↓
 UIHostingController
         ↓
 SwiftUI Content (VStack)
 */
