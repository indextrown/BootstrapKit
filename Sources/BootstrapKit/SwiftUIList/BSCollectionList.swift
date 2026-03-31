import SwiftUI
import UIKit

/// 각 행을 SwiftUI 뷰로 렌더링하는 `UICollectionView` 기반 리스트를 SwiftUI에서 사용할 수 있게 감싼 래퍼입니다.
///
/// `BSCollectionList`는 스크롤과 셀 재사용은 UIKit이 담당하고,
/// 외부에서는 SwiftUI 스타일의 API로 행을 구성할 수 있게 해줍니다.
/// `spacing` 값을 통해 행 사이 간격도 함께 조절할 수 있습니다.
public struct BSCollectionList<Data, RowContent>: UIViewRepresentable where Data: RandomAccessCollection, Data.Element: Identifiable, RowContent: View {
    public typealias Item = Data.Element

    private let items: [Item]
    private let rowContent: (Item) -> RowContent
    private var spacing: CGFloat
    private var contentInsets: UIEdgeInsets = .zero
    private var backgroundColor: UIColor = .clear
    private var showsVerticalScrollIndicator = true
    private var showsHorizontalScrollIndicator = false
    private var onSelect: ((Item) -> Void)?

    /// 식별 가능한 데이터 컬렉션과 SwiftUI 행 빌더로 리스트를 생성합니다.
    ///
    /// - Parameters:
    ///   - data: 리스트에 표시할 원본 데이터 컬렉션입니다.
    ///   - spacing: 각 행 사이의 세로 간격입니다.
    ///   - rowContent: 각 아이템에 대응하는 SwiftUI 행 뷰를 만드는 빌더입니다.
    public init(_ data: Data, spacing: CGFloat = 0, @ViewBuilder rowContent: @escaping (Item) -> RowContent) {
        self.items = Array(data)
        self.spacing = spacing
        self.rowContent = rowContent
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIView(context: Context) -> BSCollectionListContainerView {
        let view = BSCollectionListContainerView()
        context.coordinator.update(with: self, in: view)
        return view
    }

    public func updateUIView(_ uiView: BSCollectionListContainerView, context: Context) {
        context.coordinator.update(with: self, in: uiView)
    }
}

public extension BSCollectionList {
    /// 컨테이너와 컬렉션 뷰 뒤에 적용할 UIKit 배경색을 설정합니다.
    ///
    /// - Parameter color: 리스트 배경에 사용할 색상입니다.
    /// - Returns: 배경색이 적용된 리스트 인스턴스입니다.
    func backgroundColor(_ color: UIColor) -> Self {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    /// 세로 스크롤 인디케이터의 표시 여부를 설정합니다.
    ///
    /// - Parameter isVisible: `true`이면 인디케이터를 표시하고, `false`이면 숨깁니다.
    /// - Returns: 스크롤 인디케이터 설정이 적용된 리스트 인스턴스입니다.
    func showsVerticalScrollIndicator(_ isVisible: Bool) -> Self {
        var copy = self
        copy.showsVerticalScrollIndicator = isVisible
        return copy
    }

    /// 가로 스크롤 인디케이터의 표시 여부를 설정합니다.
    ///
    /// - Parameter isVisible: `true`이면 인디케이터를 표시하고, `false`이면 숨깁니다.
    /// - Returns: 스크롤 인디케이터 설정이 적용된 리스트 인스턴스입니다.
    func showsHorizontalScrollIndicator(_ isVisible: Bool) -> Self {
        var copy = self
        copy.showsHorizontalScrollIndicator = isVisible
        return copy
    }

    /// 스크롤 인디케이터의 표시 여부를 한 번에 설정합니다.
    ///
    /// - Parameter isVisible: `true`이면 인디케이터를 표시하고, `false`이면 숨깁니다.
    /// - Returns: 스크롤 인디케이터 설정이 적용된 리스트 인스턴스입니다.
    func scrollIndicators(_ isVisible: Bool) -> Self {
        var copy = self
        copy.showsVerticalScrollIndicator = isVisible
        copy.showsHorizontalScrollIndicator = isVisible
        return copy
    }

    /// 리스트 전체의 바깥 여백을 설정합니다.
    ///
    /// - Parameter insets: 컬렉션 뷰 콘텐츠에 적용할 여백입니다.
    /// - Returns: 바깥 여백이 적용된 리스트 인스턴스입니다.
    func contentInsets(_ insets: UIEdgeInsets) -> Self {
        var copy = self
        copy.contentInsets = insets
        return copy
    }

    /// 행이 선택되었을 때 실행할 콜백을 등록합니다.
    ///
    /// - Parameter action: 선택된 아이템을 전달받아 실행되는 클로저입니다.
    /// - Returns: 선택 이벤트 핸들러가 적용된 리스트 인스턴스입니다.
    func onSelect(_ action: @escaping (Item) -> Void) -> Self {
        var copy = self
        copy.onSelect = action
        return copy
    }
}

public extension BSCollectionList {
    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        private var parent: BSCollectionList

        init(parent: BSCollectionList) {
            self.parent = parent
        }

        func update(with parent: BSCollectionList, in containerView: BSCollectionListContainerView) {
            self.parent = parent
            containerView.updateSpacing(parent.spacing)
            containerView.updateContentInsets(parent.contentInsets)
            containerView.collectionView.delegate = self
            containerView.collectionView.dataSource = self
            containerView.collectionView.backgroundColor = parent.backgroundColor
            containerView.collectionView.showsVerticalScrollIndicator = parent.showsVerticalScrollIndicator
            containerView.collectionView.showsHorizontalScrollIndicator = parent.showsHorizontalScrollIndicator
            containerView.backgroundColor = parent.backgroundColor
            containerView.collectionView.reloadData()
        }

        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.items.count
        }

        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BSHostingCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? BSHostingCollectionViewCell else {
                return UICollectionViewCell()
            }

            let item = parent.items[indexPath.item]
            let isLast = indexPath.item == parent.items.index(before: parent.items.endIndex)
            cell.configure(
                rootView: AnyView(parent.rowContent(item)),
                parentViewController: collectionView.enclosingViewController,
                showsSeparator: parent.spacing == 0 && !isLast
            )
            return cell
        }

        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let onSelect = parent.onSelect else { return }
            onSelect(parent.items[indexPath.item])
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

/// `BSCollectionList` 내부에서 사용하는 `UICollectionView`를 소유하는 경량 컨테이너 뷰입니다.
public final class BSCollectionListContainerView: UIView {
    fileprivate let collectionView: UICollectionView
    private let estimatedRowHeight: CGFloat = 80
    private var spacing: CGFloat = 0
    private var contentInsets: UIEdgeInsets = .zero

    override init(frame: CGRect) {
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: BSCollectionListContainerView.makeLayout(
                estimatedRowHeight: estimatedRowHeight,
                spacing: 0,
                contentInsets: .zero
            )
        )
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func updateSpacing(_ spacing: CGFloat) {
        guard self.spacing != spacing else { return }
        self.spacing = spacing
        updateLayout()
    }

    fileprivate func updateContentInsets(_ insets: UIEdgeInsets) {
        guard contentInsets != insets else { return }
        contentInsets = insets
        collectionView.scrollIndicatorInsets = insets
        updateLayout()
    }

    private func setupView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.backgroundColor = .clear
        collectionView.register(
            BSHostingCollectionViewCell.self,
            forCellWithReuseIdentifier: BSHostingCollectionViewCell.reuseIdentifier
        )

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func updateLayout() {
        collectionView.setCollectionViewLayout(
            Self.makeLayout(
                estimatedRowHeight: estimatedRowHeight,
                spacing: spacing,
                contentInsets: contentInsets
            ),
            animated: false
        )
    }

    private static func makeLayout(
        estimatedRowHeight: CGFloat,
        spacing: CGFloat,
        contentInsets: UIEdgeInsets
    ) -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedRowHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedRowHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: contentInsets.top,
            leading: contentInsets.left,
            bottom: contentInsets.bottom,
            trailing: contentInsets.right
        )

        return UICollectionViewCompositionalLayout(section: section)
    }
}

private final class BSHostingCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "BSHostingCollectionViewCell"

    private let hostingController = UIHostingController(rootView: AnyView(EmptyView()))
    private let separatorView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController.rootView = AnyView(EmptyView())
        separatorView.isHidden = false
    }

    func configure(rootView: AnyView, parentViewController: UIViewController?, showsSeparator: Bool) {
        attachIfNeeded(to: parentViewController)
        hostingController.rootView = rootView
        hostingController.view.invalidateIntrinsicContentSize()
        separatorView.isHidden = !showsSeparator
    }

    private func setupCell() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .separator

        contentView.addSubview(hostingController.view)
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
    }

    private func attachIfNeeded(to parentViewController: UIViewController?) {
        guard hostingController.parent !== parentViewController else { return }

        hostingController.willMove(toParent: nil)
        hostingController.removeFromParent()

        if let parentViewController {
            parentViewController.addChild(hostingController)
            hostingController.didMove(toParent: parentViewController)
        }
    }
}

private extension UIView {
    var enclosingViewController: UIViewController? {
        sequence(first: self as UIResponder?, next: { $0?.next })
            .first { $0 is UIViewController } as? UIViewController
    }
}
