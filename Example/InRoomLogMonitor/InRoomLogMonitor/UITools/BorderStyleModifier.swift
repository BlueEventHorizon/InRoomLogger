//
//  BorderStyle.swift
//  InRoomLogMonitor
//
//  Created by Katsuhiko Terada on 2022/11/19.
//

import Foundation
import SwiftUI

public struct BorderStyleModifier: ViewModifier {
    public struct BorderStyle {
        public let padding: CGSize
        public let fillColor: Color?
        public let cornerRadius: CGFloat
        public let borderLineWidth: CGFloat
        public let borderLineColor: Color
        public let shadowColor: Color
        public let shadowOffset: CGFloat

        public init(padding: CGSize = CGSize(width: 5, height: 3),
                    fillColor: Color? = nil,
                    cornerRadius: CGFloat = 7,
                    borderLineWidth: CGFloat = 0,
                    borderLineColor: Color = .clear,
                    shadowColor: Color = .clear,
                    shadowOffset: CGFloat = 0) {
            self.padding = padding
            self.fillColor = fillColor
            self.cornerRadius = cornerRadius
            self.borderLineWidth = borderLineWidth
            self.borderLineColor = borderLineColor
            self.shadowColor = shadowColor
            self.shadowOffset = shadowOffset
        }
    }

    var style: BorderStyle

    public init(style: BorderStyle) {
        self.style = style
    }

    public func body(content: Content) -> some View {
        content
            .padding(.horizontal, style.padding.width)
            .padding(.vertical, style.padding.height)

        #if canImport(UIKit)
            .background(style.fillColor)
            .cornerRadius(style.cornerRadius)
            // 角丸ボーダーライン
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(style.borderLineColor, lineWidth: style.borderLineWidth)
            )
        #else
            // Macでは角丸ボーダーラインがうまく表示できない🤔
        #endif

            // Viewの要素をグループ化
            .compositingGroup()
            .shadow(color: style.shadowColor,
                    radius: style.shadowOffset,
                    x: style.shadowOffset,
                    y: style.shadowOffset)
    }
}

extension View {
    func borderStyle(_ style: BorderStyleModifier.BorderStyle) -> some View {
        modifier(BorderStyleModifier(style: style))
    }
}

