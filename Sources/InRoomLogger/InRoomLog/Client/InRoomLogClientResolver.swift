//
//  InRoomLogCoreResolver.swift
//  InRoomLogApp
//
//  Created by Katsuhiko Terada on 2022/10/30.
//

import Foundation
import BwNearPeer

struct InRoomLogClientResolver: InRoomLogClientDependency {
    var serviceType: String { Const.serviceType }
    var appName: String { InfoPlistKeys.displayName.getAsString() ?? "" }
    var identifier: String { UserDefaults.clientIdentifier }

    var myDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { [.identifier: Const.clientIdentifier, .passcode: Const.passcode] }
    var targetDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { [.identifier: Const.monitorIdentifier, .passcode: Const.passcode] }
}
