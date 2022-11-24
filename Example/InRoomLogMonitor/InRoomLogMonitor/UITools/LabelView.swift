//
//  LabelView.swift
//  SiruDoor
//
//  Created by Katsuhiko Terada on 2022/09/10.
//

import SwiftUI

@available(iOS 14.0, *)
public struct LabelView: View {
    @Binding var text: String
    @Binding var imageName: String

    public var body: some View {
        Label {
            // ""ブランク文字列は、幅を取るので完全排除するには、if文が必須
            if !text.isEmpty {
                Text(text)
            }
        } icon: {
            if !imageName.isEmpty {
                if #available(iOS 16.0, macOS 13.0,*) {
                    Image(systemName: imageName, variableValue: 1.0)
                } else {
                    Image(systemName: imageName)
                }
            }
        }
    }
}

struct LabelViewStyle: LabelStyle {
    let style: TextStyleModifier.TextStyle = .Predefined.default.style

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 32) {
            configuration.icon
            configuration.title
                .multilineTextAlignment(.leading)
                .lineLimit(style.lineLimit)
                .font(style.font)
                .foregroundColor(style.textColor)
        }
    }
}

extension LabelStyle where Self == LabelViewStyle {
    static var labelViewStyle: LabelViewStyle {
        .init()
    }
}
