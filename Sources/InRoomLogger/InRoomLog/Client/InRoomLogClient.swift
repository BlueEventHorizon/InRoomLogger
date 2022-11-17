//
//  InRoomLogClient.swift
//  InRoomLogger
//
//  Created by Katsuhiko Terada on 2022/08/11.
//

import BwNearPeer
import Foundation
#if canImport(UIKit)
    import UIKit.UIDevice
#endif

public protocol InRoomLogClientDependency {
    /// InfoPlistに記述が必要
    var serviceType: String { get }

    // Info.plistで記述される
    var appName: String { get }

    /// 永続的かつユニークである必要がある
    var identifier: String { get }

    var clientIdentifier: String { get }
    var monitorIdentifier: String { get }
}

public class InRoomLogClient {
    var peerNames: [PeerIdentifier] = []

    private var dependency: InRoomLogClientDependency = InRoomLogClientResolver()
    private let nearPeer: NearPeer
    private let passcode: String

    /// 複数のPeerの識別子を格納する
    private let peers = StructHolder()

    public init(passcode: String, dependency: InRoomLogClientDependency? = nil) {
        // 一度に接続できるPeerは１つだけ
        nearPeer = NearPeer(maxPeers: 1)

        self.passcode = passcode
        
        if let dependency = dependency {
            self.dependency = dependency
        }

        start()
    }
    
    private func start() {
        nearPeer.onConnected { peer in
            print("🔵 \(peer.displayName) Connected")
            // TODO: 切断された時の処理を追加すること

            let peerComponents = peer.displayName.components(separatedBy: ".")

            if let displayName = peerComponents.first, let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                self.peers.set(PeerIdentifier(id: uuid, displayName: displayName))
                self.peerNames = self.peers.map {
                    $0 as! PeerIdentifier
                }

                print("🟡 peerName | \(displayName), peerIdentifier = \(uuidString)")
            }
        }

        nearPeer.onDisconnect { peer in
            print("🔴 \(peer) is disconnected")

            let peerComponents = peer.displayName.components(separatedBy: ".")

            if let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                self.peers.remove(identifier: uuid)
                self.peerNames = self.peers.map {
                    $0 as! PeerIdentifier
                }
            }
        }

        nearPeer.onReceived { _, data in
            print("🟢 Received \(data?.description ?? "")")
        }
        
        nearPeer.start(serviceType: dependency.serviceType,
                       displayName: "\(dependency.appName).\(dependency.identifier)",
                       myDiscoveryInfo: [.identifier: dependency.clientIdentifier, .passcode: passcode],
                       targetDiscoveryInfo: [.identifier: dependency.monitorIdentifier, .passcode: passcode])
    }

    public func resume() {
        nearPeer.resume()
    }

    public func suspend() {
        nearPeer.suspend()
    }

    public func send(log: LogInformation) {
        if let encodedContent: Data = try? JSONEncoder().encode(log) {
            nearPeer.send(encodedContent)
        } else {
            print("encode失敗")
        }
    }
}
