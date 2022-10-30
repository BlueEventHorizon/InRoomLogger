// swiftlint:disable:this file_name
//
//  UserDefault+Ext.swift
//  InRoomLogger
//
//  Created by Katsuhiko Terada on 2022/07/23.
//

import Foundation

enum UserDefaultKeys: String, CaseIterable {
    case clientIdentifier
    case monitorIdentifier
}

extension UserDefaults {
    @UserDefaultsWrapper(UserDefaultKeys.clientIdentifier.rawValue, defaultValue: UUID().uuidString)
    static var clientIdentifier: String

    @UserDefaultsWrapper(UserDefaultKeys.monitorIdentifier.rawValue, defaultValue: UUID().uuidString)
    static var monitorIdentifier: String
}
