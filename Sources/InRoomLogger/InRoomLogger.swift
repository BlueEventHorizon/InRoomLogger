//
//  InRoomLogger.swift
//  InRoomLogger
//
//  Created by k2moons on 2022/10/27.
//  Copyright © 2020 k2moons. All rights reserved.
//

import Foundation
import BwLogger
import BwNearPeer

public class InRoomLogger {
    let nearPeerNotifier: NearPeerNotifier

    public init() {
        nearPeerNotifier = NearPeerNotifier()
    }
}

extension InRoomLogger: LogOutput {
    public func log(_ information: LogInformation) {
        nearPeerNotifier.send(log: information)
    }
}
