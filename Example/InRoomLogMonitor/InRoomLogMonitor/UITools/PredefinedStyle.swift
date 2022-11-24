//
//  PredefinedStyle.swift
//  SiruDoor
//
//  Created by Katsuhiko Terada on 2022/11/19.
//

import Foundation
import SwiftUI

public extension TextStyleModifier.TextStyle {
    enum Predefined {
        case multiline
        case `default`

        public var style: TextStyleModifier.TextStyle {
            switch self {
                case .multiline:
                return TextStyleModifier.TextStyle(font: .system(size: 14, weight: .bold), textColor: Color.gray, lineLimit: 10)
                case .default:
                return TextStyleModifier.TextStyle(font: .system(size: 14, weight: .bold), textColor: Color.gray, lineLimit: 1)
            }
        }
    }
}

extension BorderStyleModifier.BorderStyle {
    static var `default`: Predefined = .default
    static var bordered: Predefined = .bordered
    static var shadowed: Predefined = .shadowed
    static var smallShadowed: Predefined = .smallShadowed

    enum Predefined {
        case `default`
        case bordered
        case shadowed
        case smallShadowed

        var fillColor: Color {
            Color.white
        }

        public var style: BorderStyleModifier.BorderStyle {
            switch self {
                case .default:
                    return BorderStyleModifier.BorderStyle(
                        padding: .init(width: 35, height: 15),
                        fillColor: fillColor,
                        cornerRadius: 10,
                        borderLineWidth: 1,
                        borderLineColor: Color.gray,
                        shadowColor: .clear,
                        shadowOffset: 3
                    )

                case .bordered:
                    return BorderStyleModifier.BorderStyle(
                        padding: .init(width: 35, height: 15),
                        fillColor: fillColor,
                        cornerRadius: 10,
                        borderLineWidth: 1,
                        borderLineColor: Color.gray,
                        shadowColor: .clear,
                        shadowOffset: 3
                    )

                case .shadowed:
                    return BorderStyleModifier.BorderStyle(
                        padding: .init(width: 35, height: 15),
                        fillColor: fillColor,
                        cornerRadius: 10,
                        borderLineWidth: 0,
                        borderLineColor: .clear,
                        shadowColor: Color.gray,
                        shadowOffset: 3
                    )

                case .smallShadowed:
                    return BorderStyleModifier.BorderStyle(
                        padding: .init(width: 5, height: 5),
                        fillColor: fillColor,
                        cornerRadius: 4,
                        borderLineWidth: 0,
                        borderLineColor: .clear,
                        shadowColor: Color.gray,
                        shadowOffset: 2
                    )
            }
        }
    }
}
