//
//  SectionView.swift
//  BootstrapDemo
//
//  Created by 김동현 on 3/31/26.
//

import SwiftUI
import BootstrapKit

struct SectionView: View {
    private struct DemoSection: Identifiable {
        let id: String
        let title: String
        let caption: String
        let items: [DemoRow]
    }

    private let rawSections: [DemoSection] = [
        DemoSection(
            id: "favorites",
            title: "Favorites",
            caption: "자주 보는 항목",
            items: (1...4).map {
                DemoRow(
                    title: "Favorite Row \($0)",
                    subtitle: "Pinned collection section item"
                )
            }
        ),
        DemoSection(
            id: "recent",
            title: "Recent",
            caption: "최근 추가된 항목",
            items: (5...10).map {
                DemoRow(
                    title: "Recent Row \($0)",
                    subtitle: "Recently updated collection section item"
                )
            }
        )
    ]

    private var sections: [BSCollectionSection<String, DemoRow>] {
        rawSections.map { section in
            BSCollectionSection(
                id: section.id,
                items: section.items
            )
        }
    }

    private func metadata(for section: BSCollectionSection<String, DemoRow>) -> DemoSection {
        rawSections.first { $0.id == section.id }!
    }

    var body: some View {
        BSCollectionSectionedList(sections, spacing: 10) { item in
            CustomCell(row: item)
        } header: { section in
            let meta = metadata(for: section)

            VStack(alignment: .leading, spacing: 4) {
                Text(meta.title)
                    .font(.title3.weight(.semibold))

                Text(meta.caption)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 18)
            .padding(.bottom, 8)
        }
        /*
        footer: { section in
            let meta = metadata(for: section)

            Text("\(meta.items.count)개의 항목")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.bottom, 4)
        }
         */
        .onSelect { item in
            print("selected section item: \(item.title)")
        }
        .scrollIndicators(false)
        .contentInsets(UIEdgeInsets(top: 0, left: 16, bottom: 24, right: 16))
        .backgroundColor(.systemBackground)
        .navigationTitle("BSSectionedList")
    }
}

#Preview {
    NavigationStack {
        SectionView()
    }
}
