//
//  UIColor+Color.swift
//
//
//  Created by Katsuhiko Terada on 2022/08/14.
//

import SwiftUI

#if canImport(UIKit)

public extension UIColor {
    var color: Color {
        Color(self)
    }
}

#endif
