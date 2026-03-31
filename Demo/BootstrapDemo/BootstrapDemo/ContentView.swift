//
//  ContentView.swift
//  BootstrapDemo
//
//  Created by 김동현 on 3/23/26.
//

import SwiftUI
import BootstrapKit
import BootstrapFirebase

struct DemoRow: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

struct CustomCell: View {
    let row: DemoRow
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(row.title)
                .font(.headline)

            Text(row.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct ContentView: View {

    private let rows = (1...10).map {
        DemoRow(
            title: "Bootstrap Row \($0)",
            subtitle: "UICollectionView engine + SwiftUI cell composition"
        )
    }

    var body: some View {
        BSCollectionList(rows, spacing: 10) { row in
            CustomCell(row: row)
        }
        .onSelect { info in
            print("\(info)")
        }
        .scrollIndicators(false)
        .contentInsets(UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        .backgroundColor(.systemBackground)
        .navigationTitle("BSCollectionList")
    }
}

#Preview {
    ContentView()
}
