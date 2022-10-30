//
//  UUIDIdentifiable.swift
//  InRoomLogger
//
//  Created by Katsuhiko Terada on 2022/08/21.
//

import Foundation

protocol UUIDIdentifiable: Equatable {
    var id: UUID { get }
}
