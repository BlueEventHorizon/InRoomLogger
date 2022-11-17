//
//  InRoomLogOutput.swift
//  InRoomLogger
//
//  Created by k2moons on 2022/10/27.
//  Copyright © 2020 k2moons. All rights reserved.
//

import Foundation
import BwNearPeer

public class InRoomLogOutput {
    let client: InRoomLogClient

    public init(passcode: String) {
        client = InRoomLogClient(passcode: passcode)
    }
}

extension InRoomLogOutput: LogOutput {
    public func log(_ information: LogInformation) {
        client.send(log: information)
    }
}
