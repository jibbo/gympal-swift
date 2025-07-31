//
//  FlowLayout.swift
//  GymFocus
//
//  Created by Giovanni De Francesco on 16/07/25.
//

import SwiftUI

struct FlowLayout: Layout {
    var alignment: RowAlignment
    var spacing: CGFloat

    init(alignment: RowAlignment = .center, spacing: CGFloat = 10) {
        self.alignment = alignment
        self.spacing = spacing
    }

    func makeRows(subviews: Subviews, maxWidth: CGFloat) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var currentRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if !rows.last!.isEmpty && currentRowWidth + size.width + spacing > maxWidth {
                rows.append([])
                currentRowWidth = 0
            }
            rows[rows.count - 1].append(subview)
            currentRowWidth += size.width + (rows[rows.count - 1].count > 1 ? spacing : 0)
        }
        return rows
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = makeRows(subviews: subviews, maxWidth: maxWidth)
        var height: CGFloat = 0
        for row in rows {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            height += rowHeight
        }
        height += CGFloat(max(0, rows.count - 1)) * spacing
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = makeRows(subviews: subviews, maxWidth: bounds.width)
        var y = bounds.minY

        for row in rows {
            let rowHeights = row.map { $0.sizeThatFits(.unspecified).height }
            let rowMaxHeight = rowHeights.max() ?? 0
            let rowWidths = row.map { $0.sizeThatFits(.unspecified).width }
            let rowTotalWidth = rowWidths.reduce(0, +) + CGFloat(max(0, row.count - 1)) * spacing

            let xOffset: CGFloat
            switch alignment {
            case .leading:
                xOffset = bounds.minX
            case .center:
                xOffset = bounds.minX + (bounds.width - rowTotalWidth) / 2
            case .trailing:
                xOffset = bounds.minX + bounds.width - rowTotalWidth
            }

            var x = xOffset
            for (i, subview) in row.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(
                    at: CGPoint(x: x, y: y + (rowMaxHeight - size.height) / 2),
                    proposal: ProposedViewSize(width: size.width, height: size.height)
                )
                x += size.width + spacing
            }
            y += rowMaxHeight + spacing
        }
    }
}

enum RowAlignment {
    case leading
    case center
    case trailing
}
