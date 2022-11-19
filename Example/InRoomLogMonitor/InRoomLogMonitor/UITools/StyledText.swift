//
//  BorderButton.swift
//  CombineExample
//
//  Created by Katsuhiko Terada on 2021/06/07.
//

import SwiftUI

public struct StyledText: View {
    public let text: String
    public let textStyle: TextStyleModifier.TextStyle
    public let borderStyle: BorderStyleModifier.BorderStyle

    public var body: some View {
        Text(text)
            .textStyle(textStyle)
            .borderStyle(borderStyle)
    }

    public init(text: String, textStyle: TextStyleModifier.TextStyle, borderStyle: BorderStyleModifier.BorderStyle) {
        self.text = text
        self.textStyle = textStyle
        self.borderStyle = borderStyle
    }
}

@ViewBuilder public func makeBorderedButton(text: String, textStyle: TextStyleModifier.TextStyle, borderStyle: BorderStyleModifier.BorderStyle, action: ((String) -> Void)?) -> some View {
    Button {
        action?(text)
    } label: {
        StyledText(text: text, textStyle: textStyle, borderStyle: borderStyle)
    }
}

struct BorderedText_Previews: PreviewProvider {
    static var text: String = "これはテストだよ\nこれはテストだよ\nこれはテストだよ\nこれはテストだよ\nこれはテストだよ\nこれはテストだよ"
    static var textStyle: TextStyleModifier.TextStyle = .init(font: .headline)
    static var borderStyle: BorderStyleModifier.BorderStyle = .init()

    static var previews: some View {
        Group {
            makeBorderedButton(text: text, textStyle: textStyle, borderStyle: borderStyle) { _ in print("pushed") }
            makeBorderedButton(text: text, textStyle: textStyle, borderStyle: borderStyle) { _ in print("pushed") }
        }
    }
}
