//
//  File.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/23/26.
//
/*
 https://burgerkinghero.tistory.com/13
 https://ios-development.tistory.com/986
 https://ontheswift.tistory.com/20
 */

import SwiftUI

struct SwiftUICellView: View {
    var number: Int
    
    var body: some View {
        Text("\(number)")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .border(.red)
    }
}

final class UIHostingCell<Content: View>: UICollectionViewCell {
    
    private let hostingController = UIHostingController<Content?>(rootView: nil)
    
    // 재사용 과정에서 셀끼리 꼬이는 이슈 발생 가능성 대비
    override func prepareForReuse() {
        super.prepareForReuse()
        self.hostingController.rootView = nil
        self.hostingController.removeFromParent()
    }
    
    func configure(view: Content, parent: UIViewController?) {
        self.hostingController.rootView = view
        self.hostingController.view.invalidateIntrinsicContentSize()
        self.hostingController.view.backgroundColor = .clear
        
        if !self.contentView.subviews.contains(self.hostingController.view) {
            self.hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            self.contentView.addSubview(self.hostingController.view)
            
            NSLayoutConstraint.activate([
                self.hostingController.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
                self.hostingController.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
                self.hostingController.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
                self.hostingController.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            ])
            self.layoutIfNeeded() // 즉시 갱신
        }
    }
}

final class HostingSampleVC: UIViewController {
    
    private var items: [Int] = Array(1...100)
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }
    
    private func setupUI() {
         view.backgroundColor = .white
         view.addSubview(collectionView)
         collectionView.translatesAutoresizingMaskIntoConstraints = false
         
         NSLayoutConstraint.activate([
             collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             collectionView.topAnchor.constraint(equalTo: view.topAnchor),
             collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
         ])
     }
    
    // 셀 등록
    private func setupCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(
            UIHostingCell<SwiftUICellView>.self,
            forCellWithReuseIdentifier: "UIHostingCell"
        )
    }
}

extension HostingSampleVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
               withReuseIdentifier: "UIHostingCell",
               for: indexPath
           ) as? UIHostingCell<SwiftUICellView> else {
               return UICollectionViewCell()
           }
        let number = self.items[indexPath.item]
        let cellView = SwiftUICellView(number: number)
        
        // parent를 self로 지정해주고, SwiftUI 뷰도 전달
        cell.configure(view: cellView, parent: self)
        return cell
    }
    
}

extension HostingSampleVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 셀 사이즈 정의
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
}

import UIKit
struct HostingSampleWrapper: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> HostingSampleVC {
        HostingSampleVC()
    }
    
    func updateUIViewController(_ uiViewController: HostingSampleVC, context: Context) {}
}

#Preview {
    HostingSampleWrapper()
}
