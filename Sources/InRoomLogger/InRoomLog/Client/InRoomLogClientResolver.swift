//
//  InRoomLogCoreResolver.swift
//  InRoomLogApp
//
//  Created by Katsuhiko Terada on 2022/10/30.
//

import Foundation

struct InRoomLogClientResolver: InRoomLogClientDependency {
    var serviceType: String { Const.serviceType }
    var appName: String { InfoPlistKeys.displayName.getAsString() ?? "" }
    var identifier: String { UserDefaults.clientIdentifier }

    var clientIdentifier: String { Const.clientIdentifier }
    var monitorIdentifier: String { Const.monitorIdentifier }
    
    func log(_ information: LogInformation) {
        //
    }
}
