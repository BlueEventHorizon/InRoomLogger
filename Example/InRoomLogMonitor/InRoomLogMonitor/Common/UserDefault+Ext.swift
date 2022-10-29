// swiftlint:disable:this file_name
//
//  UserDefault+Ext.swift
//  InRoomLogMonitor
//
//  Created by Katsuhiko Terada on 2022/07/23.
//

import Foundation

enum UserDefaultKeys: String, CaseIterable {
    case myIdentifier
}

extension UserDefaults {
    @UserDefaultsWrapper(UserDefaultKeys.myIdentifier.rawValue, defaultValue: UUID().uuidString)
    static var myIdentifier: String
}
