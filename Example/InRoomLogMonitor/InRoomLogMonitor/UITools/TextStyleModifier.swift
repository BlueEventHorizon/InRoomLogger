//
//  BTextStyle.swift
//  InRoomLogMonitor
//
//  Created by Katsuhiko Terada on 2022/11/19.
//

import Foundation
import SwiftUI

public struct TextStyleModifier: ViewModifier {
    public struct TextStyle {
        public let font: Font
        public let textColor: Color
        public let alignment: TextAlignment
        public let lineLimit: Int

        public init(font: Font, textColor: Color = .white, alignment: TextAlignment = .center, lineLimit: Int = 0) {
            self.font = font
            self.textColor = textColor
            self.alignment = alignment
            self.lineLimit = lineLimit
        }
    }

    var style: TextStyle

    public init(style: TextStyle) {
        self.style = style
    }

    public func body(content: Content) -> some View {
        content
            .font(style.font)
            .foregroundColor(style.textColor)
            .multilineTextAlignment(style.alignment)
            .lineLimit(style.lineLimit)
    }
}

extension View {
    func textStyle(_ style: TextStyleModifier.TextStyle) -> some View {
        modifier(TextStyleModifier(style: style))
    }
}
