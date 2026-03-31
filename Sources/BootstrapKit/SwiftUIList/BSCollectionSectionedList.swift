import SwiftUI
import UIKit

/// `BSCollectionSectionedList`에서 사용할 섹션 모델입니다.
///
/// - Note: 각 섹션은 고유한 `id`와 해당 섹션에 포함될 `items`를 가집니다.
public struct BSCollectionSection<SectionID, Item>: Identifiable where SectionID: Hashable, Item: Identifiable {
    public let id: SectionID
    public let items: [Item]

    public init(id: SectionID, items: [Item]) {
        self.id = id
        self.items = items
    }
}

/// 섹션별 헤더/푸터를 지원하는 `UICollectionView` 기반 SwiftUI 리스트입니다.
///
/// `BSCollectionSectionedList`는 단일 아이템 리스트가 아니라, 여러 섹션과 각 섹션의 아이템을
/// `UICollectionView` 위에서 렌더링합니다.
public struct BSCollectionSectionedList<Sections, RowContent, HeaderContent, FooterContent>: UIViewRepresentable
where Sections: RandomAccessCollection,
      Sections.Element: Identifiable,
      Sections.Element: BSCollectionSectionProtocol,
      RowContent: View,
      HeaderContent: View,
      FooterContent: View,
      Sections.Element.Item: Identifiable {

    public typealias Section = Sections.Element
    public typealias Item = Sections.Element.Item

    private let sections: [Section]
    private let rowContent: (Item) -> RowContent
    private let headerContent: (Section) -> HeaderContent
    private let footerContent: (Section) -> FooterContent
    private let showsHeader: Bool
    private let showsFooter: Bool
    private var spacing: CGFloat
    private var contentInsets: UIEdgeInsets = .zero
    private var backgroundColor: UIColor = .clear
    private var showsVerticalScrollIndicator = true
    private var showsHorizontalScrollIndicator = false
    private var onSelect: ((Item) -> Void)?

    /// 섹션 데이터를 기반으로 리스트를 생성합니다.
    ///
    /// - Parameters:
    ///   - sections: 렌더링할 섹션 컬렉션입니다.
    ///   - spacing: 같은 섹션 내 행 사이의 간격입니다.
    ///   - rowContent: 각 아이템에 대한 셀 뷰입니다.
    ///   - header: 섹션 헤더 뷰입니다.
    ///   - footer: 섹션 푸터 뷰입니다.
    public init(
        _ sections: Sections,
        spacing: CGFloat = 0,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder header: @escaping (Section) -> HeaderContent,
        @ViewBuilder footer: @escaping (Section) -> FooterContent
    ) {
        self.sections = Array(sections)
        self.spacing = spacing
        self.rowContent = rowContent
        self.headerContent = header
        self.footerContent = footer
        self.showsHeader = HeaderContent.self != EmptyView.self
        self.showsFooter = FooterContent.self != EmptyView.self
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    public func makeUIView(context: Context) -> BSCollectionSectionedListContainerView {
        let view = BSCollectionSectionedListContainerView()
        context.coordinator.update(with: self, in: view)
        return view
    }

    public func updateUIView(_ uiView: BSCollectionSectionedListContainerView, context: Context) {
        context.coordinator.update(with: self, in: uiView)
    }
}

public extension BSCollectionSectionedList where FooterContent == EmptyView {
    init(
        _ sections: Sections,
        spacing: CGFloat = 0,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent,
        @ViewBuilder header: @escaping (Section) -> HeaderContent
    ) {
        self.init(
            sections,
            spacing: spacing,
            rowContent: rowContent,
            header: header,
            footer: { _ in EmptyView() }
        )
    }
}

public extension BSCollectionSectionedList where HeaderContent == EmptyView, FooterContent == EmptyView {
    init(
        _ sections: Sections,
        spacing: CGFloat = 0,
        @ViewBuilder rowContent: @escaping (Item) -> RowContent
    ) {
        self.init(
            sections,
            spacing: spacing,
            rowContent: rowContent,
            header: { _ in EmptyView() },
            footer: { _ in EmptyView() }
        )
    }
}

public extension BSCollectionSectionedList {
    func backgroundColor(_ color: UIColor) -> Self {
        var copy = self
        copy.backgroundColor = color
        return copy
    }

    func showsVerticalScrollIndicator(_ isVisible: Bool) -> Self {
        var copy = self
        copy.showsVerticalScrollIndicator = isVisible
        return copy
    }

    func showsHorizontalScrollIndicator(_ isVisible: Bool) -> Self {
        var copy = self
        copy.showsHorizontalScrollIndicator = isVisible
        return copy
    }

    func scrollIndicators(_ isVisible: Bool) -> Self {
        var copy = self
        copy.showsVerticalScrollIndicator = isVisible
        copy.showsHorizontalScrollIndicator = isVisible
        return copy
    }

    func contentInsets(_ insets: UIEdgeInsets) -> Self {
        var copy = self
        copy.contentInsets = insets
        return copy
    }

    func onSelect(_ action: @escaping (Item) -> Void) -> Self {
        var copy = self
        copy.onSelect = action
        return copy
    }
}

public protocol BSCollectionSectionProtocol {
    associatedtype Item: Identifiable
    var items: [Item] { get }
}

extension BSCollectionSection: BSCollectionSectionProtocol {}

public extension BSCollectionSectionedList {
    final class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        private var parent: BSCollectionSectionedList

        init(parent: BSCollectionSectionedList) {
            self.parent = parent
        }

        func update(with parent: BSCollectionSectionedList, in containerView: BSCollectionSectionedListContainerView) {
            self.parent = parent
            containerView.updateSpacing(parent.spacing)
            containerView.updateContentInsets(parent.contentInsets)
            containerView.updateSupplementaryVisibility(
                showsHeader: parent.showsHeader,
                showsFooter: parent.showsFooter
            )
            containerView.collectionView.delegate = self
            containerView.collectionView.dataSource = self
            containerView.collectionView.backgroundColor = parent.backgroundColor
            containerView.collectionView.showsVerticalScrollIndicator = parent.showsVerticalScrollIndicator
            containerView.collectionView.showsHorizontalScrollIndicator = parent.showsHorizontalScrollIndicator
            containerView.backgroundColor = parent.backgroundColor
            containerView.collectionView.reloadData()
        }

        public func numberOfSections(in collectionView: UICollectionView) -> Int {
            parent.sections.count
        }

        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            parent.sections[section].items.count
        }

        public func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BSSectionedHostingCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? BSSectionedHostingCollectionViewCell else {
                return UICollectionViewCell()
            }

            let item = parent.sections[indexPath.section].items[indexPath.item]
            let isLast = indexPath.item == parent.sections[indexPath.section].items.indices.last
            cell.configure(
                rootView: AnyView(parent.rowContent(item)),
                parentViewController: collectionView.enclosingViewController,
                showsSeparator: parent.spacing == 0 && !isLast
            )
            return cell
        }

        public func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath
        ) -> UICollectionReusableView {
            guard let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: BSSectionedHostingSupplementaryView.reuseIdentifier,
                for: indexPath
            ) as? BSSectionedHostingSupplementaryView else {
                return UICollectionReusableView()
            }

            let section = parent.sections[indexPath.section]
            let rootView: AnyView
            if kind == UICollectionView.elementKindSectionHeader {
                rootView = AnyView(parent.headerContent(section))
            } else {
                rootView = AnyView(parent.footerContent(section))
            }

            view.configure(rootView: rootView, parentViewController: collectionView.enclosingViewController)
            return view
        }

        public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            guard let onSelect = parent.onSelect else { return }
            onSelect(parent.sections[indexPath.section].items[indexPath.item])
            collectionView.deselectItem(at: indexPath, animated: true)
        }
    }
}

public final class BSCollectionSectionedListContainerView: UIView {
    fileprivate let collectionView: UICollectionView
    private let estimatedRowHeight: CGFloat = 80
    private var spacing: CGFloat = 0
    private var contentInsets: UIEdgeInsets = .zero
    private var showsHeader = true
    private var showsFooter = true

    override init(frame: CGRect) {
        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: BSCollectionSectionedListContainerView.makeLayout(
                estimatedRowHeight: estimatedRowHeight,
                spacing: 0,
                contentInsets: .zero,
                showsHeader: true,
                showsFooter: true
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

    fileprivate func updateSupplementaryVisibility(showsHeader: Bool, showsFooter: Bool) {
        guard self.showsHeader != showsHeader || self.showsFooter != showsFooter else { return }
        self.showsHeader = showsHeader
        self.showsFooter = showsFooter
        updateLayout()
    }

    private func setupView() {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .automatic
        collectionView.backgroundColor = .clear
        collectionView.register(
            BSSectionedHostingCollectionViewCell.self,
            forCellWithReuseIdentifier: BSSectionedHostingCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            BSSectionedHostingSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: BSSectionedHostingSupplementaryView.reuseIdentifier
        )
        collectionView.register(
            BSSectionedHostingSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: BSSectionedHostingSupplementaryView.reuseIdentifier
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
                contentInsets: contentInsets,
                showsHeader: showsHeader,
                showsFooter: showsFooter
            ),
            animated: false
        )
    }

    private static func makeLayout(
        estimatedRowHeight: CGFloat,
        spacing: CGFloat,
        contentInsets: UIEdgeInsets,
        showsHeader: Bool,
        showsFooter: Bool
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

        var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []

        if showsHeader {
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            boundarySupplementaryItems.append(header)
        }

        if showsFooter {
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(24)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            boundarySupplementaryItems.append(footer)
        }

        section.boundarySupplementaryItems = boundarySupplementaryItems

        return UICollectionViewCompositionalLayout(section: section)
    }
}

private final class BSSectionedHostingCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "BSSectionedHostingCollectionViewCell"

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

private final class BSSectionedHostingSupplementaryView: UICollectionReusableView {
    static let reuseIdentifier = "BSSectionedHostingSupplementaryView"

    private let hostingController = UIHostingController(rootView: AnyView(EmptyView()))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        hostingController.rootView = AnyView(EmptyView())
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let targetSize = CGSize(
            width: layoutAttributes.size.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let fittedSize = systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        attributes.size.height = ceil(fittedSize.height)
        return attributes
    }

    func configure(rootView: AnyView, parentViewController: UIViewController?) {
        attachIfNeeded(to: parentViewController)
        hostingController.rootView = rootView
        hostingController.view.invalidateIntrinsicContentSize()
    }

    private func setupView() {
        backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
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
