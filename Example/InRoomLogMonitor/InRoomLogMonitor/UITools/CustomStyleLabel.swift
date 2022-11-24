//
//  StyledLabel.swift
//  SiruDoor
//
//  Created by Katsuhiko Terada on 2022/11/19.
//

import Foundation
import SwiftUI

public struct CustomStyleLabel: View {
    @Binding var text: String
    @Binding var imageName: String
    @Binding var textStyle: TextStyleModifier.TextStyle
    @Binding var borderStyle: BorderStyleModifier.BorderStyle

    public var body: some View {
        LabelView(text: $text, imageName: $imageName)
            .textStyle(textStyle)
            .borderStyle(borderStyle)
    }
}

struct CustomStyleLabel_Previews: PreviewProvider {
    static let text: String = "あいうえおかきくけこさしすせそ\nたちつてと\nなにぬねの\nこれはテストだよ\nこれはテストだよ"
    static let text2: String = "あいうえお"
    static let imageName: String = "square.and.arrow.up.on.square"

    static var previews: some View {
        Group {
            CustomStyleLabel(text: .constant(text),
                             imageName: .constant(imageName),
                             textStyle: .constant(.Predefined.multiline.style),
                             borderStyle: .constant(.Predefined.bordered.style))

            CustomStyleLabel(text: .constant(text2),
                             imageName: .constant(imageName),
                             textStyle: .constant(.Predefined.default.style),
                             borderStyle: .constant(.Predefined.shadowed.style))

            CustomStyleLabel(text: .constant(""),
                             imageName: .constant(imageName),
                             textStyle: .constant(.Predefined.default.style),
                             borderStyle: .constant(.Predefined.smallShadowed.style))
        }
    }
}
