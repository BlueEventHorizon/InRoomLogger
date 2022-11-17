//
//  InRoomLogMonitorResolver.swift
//  
//
//  Created by Katsuhiko Terada on 2022/11/17.
//

import Foundation

struct InRoomLogMonitorResolver: InRoomLogMonitorDependency {
    var serviceType: String { Const.serviceType }
    var appName: String { InfoPlistKeys.displayName.getAsString() ?? "" }
    var identifier: String { UserDefaults.monitorIdentifier }

    var clientIdentifier: String { Const.clientIdentifier }
    var monitorIdentifier: String { Const.monitorIdentifier }
}

