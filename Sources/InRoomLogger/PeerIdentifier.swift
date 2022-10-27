//
//  PeerIdentifier.swift
//  InRoomLogger
//
//  Created by Katsuhiko Terada on 2022/09/20.
//

import Foundation

struct PeerIdentifier: UUIDIdentifiable {
    let id: UUID
    let displayName: String

    init(id: UUID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}
