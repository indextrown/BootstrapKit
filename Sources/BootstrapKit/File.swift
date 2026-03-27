//
//  File.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/21/26.
//

import SwiftUI
import UIKit

// MARK: - Hosting Cell

final class HostingCollectionViewCell<Content: View>: UICollectionViewCell {
    
    private var hostingController: UIHostingController<Content>?
    
    func set(rootView: Content, parent: UIViewController) {
        if let hostingController = hostingController {
            hostingController.rootView = rootView
            return
        }
        
        let controller = UIHostingController(rootView: rootView)
        hostingController = controller
        
        parent.addChild(controller)
        contentView.addSubview(controller.view)
        
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        
        // ⭐️ Self-Sizing 핵심
        controller.view.setContentHuggingPriority(.required, for: .vertical)
        controller.view.setContentCompressionResistancePriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        controller.didMove(toParent: parent)
    }
}

// MARK: - Representable

struct RefreshableCollectionView<Item, Content: View>: UIViewControllerRepresentable {
    
    var items: [Item]
    var onRefresh: (UIRefreshControl) -> Void
    var content: (Item) -> Content
    
    init(
        items: [Item],
        @ViewBuilder content: @escaping (Item) -> Content,
        onRefresh: @escaping (UIRefreshControl) -> Void
    ) {
        self.items = items
        self.content = content
        self.onRefresh = onRefresh
    }
    
    func makeUIViewController(context: Context) -> ViewController<Item, Content> {
        ViewController(parent: self)
    }
    
    func updateUIViewController(_ vc: ViewController<Item, Content>, context: Context) {
        vc.update(items: items)
    }
}

// MARK: - ViewController

final class ViewController<Item, Content: View>: UIViewController,
                                               UICollectionViewDataSource {
    
    private let parentRef: RefreshableCollectionView<Item, Content>
    private var items: [Item]
    
    private let collectionView: UICollectionView
    
    init(parent: RefreshableCollectionView<Item, Content>) {
        self.parentRef = parent
        self.items = parent.items
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        // ⭐️ 핵심: 자동 높이
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        collectionView.backgroundColor = .clear
        
        collectionView.dataSource = self
        
        collectionView.register(
            HostingCollectionViewCell<Content>.self,
            forCellWithReuseIdentifier: "cell"
        )
        
        // MARK: - Refresh
        let refresh = UIRefreshControl()
        refresh.addTarget(self,
                          action: #selector(handleRefresh),
                          for: .valueChanged)
        collectionView.refreshControl = refresh
    }
    
    func update(items: [Item]) {
        self.items = items
    }
    
    @objc
    private func handleRefresh(_ control: UIRefreshControl) {
        parentRef.onRefresh(control)
    }
    
    // MARK: - DataSource
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        ) as! HostingCollectionViewCell<Content>
        
        let item = items[indexPath.item]
        
        cell.set(
            rootView: parentRef.content(item),
            parent: self
        )
        
        return cell
    }
}

// MARK: - Sample

struct Sample2: View {
    
    @State private var items = Array(1..<50)
    
    var body: some View {
        RefreshableCollectionView(items: items) { item in
            
            // ⭐️ 높이 자동 테스트
            VStack(alignment: .leading, spacing: 0) {
                Text("Item \(item)")
                    .font(.headline)
                
                Text("이건 길어질 수 있는 설명 텍스트입니다. 자동으로 높이가 늘어나야 합니다.")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } onRefresh: { control in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                items.append(items.count)
                control.endRefreshing()
            }
        }
    }
}

#Preview {
    Sample2()
}
