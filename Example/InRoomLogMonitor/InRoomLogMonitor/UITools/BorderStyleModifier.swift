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
        public let shadowColor: Color?
        public let shadowOffset: CGFloat

        public init(padding: CGSize = CGSize(width: 5, height: 3),
                    fillColor: Color? = nil,
                    cornerRadius: CGFloat = 7,
                    borderLineWidth: CGFloat = 0,
                    shadowColor: Color? = nil,
                    shadowOffset: CGFloat = 0
        ) {
            self.padding = padding
            self.fillColor = fillColor
            self.cornerRadius = cornerRadius
            self.borderLineWidth = borderLineWidth
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
            // .lineSpacing(10.0)
            // .frame(height: height)
        #if canImport(UIKit)
            .background(style.fillColor)
            .cornerRadius(style.cornerRadius)
            // 角丸ボーダーライン
            .overlay(
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .stroke(Color.gray, lineWidth: 0)
            )
        #else
            
        #endif
    }
}

extension View {
    func borderStyle(_ style: BorderStyleModifier.BorderStyle) -> some View {
        modifier(BorderStyleModifier(style: style))
    }
}
