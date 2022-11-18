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

public protocol InRoomLogClientDependency: LogOutput {
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
    private let dispatch = DispatchQueue(label: "com.beowulf-tech.InRoomLogClient.send.queue")

    /// 複数のPeerの識別子を格納する
    private let peers = StructHolder()
    /// ログを一旦蓄積する
    private let logs = StructHolder()

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
            self.dependency.log(LogInformation("\(peer.displayName) Connected", prefix: "🔵", instance: self))
            // TODO: 切断された時の処理を追加すること

            let peerComponents = peer.displayName.components(separatedBy: ".")

            if let displayName = peerComponents.first, let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                self.peers.set(PeerIdentifier(id: uuid, displayName: displayName))
                self.peerNames = self.peers.map {
                    $0 as! PeerIdentifier
                }

                self.dependency.log(LogInformation("peerName | \(displayName), peerIdentifier = \(uuidString)", prefix: "🟡", instance: self))

                self.send()
            }
        }

        nearPeer.onDisconnect { peer in
            self.dependency.log(LogInformation("\(peer) is disconnected", prefix: "🔴", instance: self))

            let peerComponents = peer.displayName.components(separatedBy: ".")

            if let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                self.peers.remove(identifier: uuid)
                self.peerNames = self.peers.map {
                    $0 as! PeerIdentifier
                }
            }
        }

        nearPeer.onReceived { _, data in
            self.dependency.log(LogInformation("Received \(data?.description ?? "")", prefix: "🟢", instance: self))
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
        dispatch.async {
            self.logs.enqueue(log)
            self.send()
        }
    }

    private func send() {
        dispatch.async {
            guard !self.peers.isEmpty else {
                return
            }

            guard let log = self.logs.dequeue() as? LogInformation else {
                return
            }

            if let encodedContent: Data = try? JSONEncoder().encode(log) {
                self.nearPeer.send(encodedContent)
            } else {
                self.dependency.log(LogInformation("encode失敗", level: .error, prefix: "🔥", instance: self))

                sleep(1000)
            }

            self.send()
        }
    }
}
