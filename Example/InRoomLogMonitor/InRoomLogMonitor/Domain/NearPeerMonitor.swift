//
//  NearPeerMonitor.swift
//  InRoomLogMonitor
//
//  Created by Katsuhiko Terada on 2022/08/11.
//

import BwLogger
import BwNearPeer
import Combine
import Foundation
#if canImport(UIKit)
    import UIKit.UIDevice
#endif

protocol NearPeerMonitorDependency {
    /// InfoPlistに記述が必要
    var serviceType: String { get }

    // Info.plistで記述される
    var appName: String { get }

    /// 永続的かつユニークである必要がある
    var identifier: String { get }

    var myDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { get }

    var targetDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { get }
}

struct NearPeerMonitorResolver: NearPeerMonitorDependency {
    var serviceType: String { Const.serviceType }
    var appName: String { InfoPlistKeys.displayName.getAsString() ?? "" }
    var identifier: String { UserDefaults.myIdentifier }

    var myDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { [.identifier: Const.monitorIdentifier, .passcode: Const.passcode] }
    var targetDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { nil }
}

class NearPeerMonitor: ObservableObject {
    @Published var peerNames: [PeerIdentifier] = []
    @Published var data: Data?

    private var dependency: NearPeerMonitorDependency = NearPeerMonitorResolver()
    private let nearPeer: NearPeer

    /// 複数の「しるドア」の識別子を格納する
    private let peers = StructHolder()

    private var sendCounter: Int = 0

    init() {
        // 一度に接続できる「しるドアモニター」は１つだけ
        nearPeer = NearPeer(maxPeers: 1)
    }

    func start() {
        nearPeer.start(serviceType: dependency.serviceType,
                       displayName: "\(dependency.appName).\(dependency.identifier)",
                       myDiscoveryInfo: dependency.myDiscoveryInfo,
                       targetDiscoveryInfo: dependency.targetDiscoveryInfo)

        nearPeer.onConnected { peer in
            logger.info("🔵 [MON] \(peer.displayName) Connected", instance: self)
            // TODO: 切断された時の処理を追加すること

            let peerComponents = peer.displayName.components(separatedBy: ".")

            if let displayName = peerComponents.first, let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                self.peers.set(PeerIdentifier(id: uuid, displayName: displayName))
                self.peerNames = self.peers.map {
                    $0 as! PeerIdentifier
                }

                logger.info("🟡 [MON] peerName | \(displayName), peerIdentifier = \(uuidString)", instance: self)
            }
        }

        nearPeer.onDisconnect { peer in
            Task {
                await MainActor.run {
                    logger.warning("🔴 [MON] \(peer) is disconnected")

                    let peerComponents = peer.displayName.components(separatedBy: ".")

                    if let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                        self.peers.remove(identifier: uuid)
                        self.peerNames = self.peers.map {
                            $0 as! PeerIdentifier
                        }
                    }
                }
            }
        }

        nearPeer.onReceived { _, data in
            Task {
                await MainActor.run {
                    logger.info("🟢 [MON] Received", instance: self)

                    guard let data = data else {
                        logger.error("データがありません")
                        return
                    }
                    
                    self.data = data

                    if let content = try? JSONDecoder().decode(LogInformation.self, from: data) {
                        print(content)
                    } else if let text = try? JSONDecoder().decode(String.self, from: data) {
                        print(text)
                    } else {
                        logger.error("decode失敗")
                    }
                }
            }
        }
    }

    func stop() {
        nearPeer.stop()
    }

    func resume() {
        nearPeer.resume()
    }

    func suspend() {
        nearPeer.suspend()
    }

    func send(text: String) {

    }
}
