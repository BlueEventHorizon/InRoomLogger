//
//  UUIDIdentifiable.swift
//  InRoomLogMonitor
//
//  Created by Katsuhiko Terada on 2022/08/21.
//

import Foundation

public protocol UUIDIdentifiable {
    var id: UUID { get }
}
