//
//  InRoomLogMonitor.swift
//  InRoomLogMonitor
//
//  Created by Katsuhiko Terada on 2022/08/11.
//

import BwNearPeer
import Combine
import Foundation
#if canImport(UIKit)
    import UIKit.UIDevice
#endif

protocol InRoomLogMonitorDependency {
    /// InfoPlistに記述が必要
    var serviceType: String { get }

    // Info.plistで記述される
    var appName: String { get }

    /// 永続的かつユニークである必要がある
    var identifier: String { get }

    var myDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { get }

    var targetDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { get }
}

struct InRoomLogMonitorResolver: InRoomLogMonitorDependency {
    var serviceType: String { Const.serviceType }
    var appName: String { InfoPlistKeys.displayName.getAsString() ?? "" }
    var identifier: String { UserDefaults.monitorIdentifier }

    var myDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { [.identifier: Const.monitorIdentifier, .passcode: Const.passcode] }
    var targetDiscoveryInfo: [NearPeerDiscoveryInfoKey: String]? { nil }
}

public class LogInformationIdentified: LogInformation, Identifiable, Equatable {
    public static func == (lhs: LogInformationIdentified, rhs: LogInformationIdentified) -> Bool {
        lhs.id == rhs.id
    }

    public let id: UUID

    public override init(_ log: LogInformation) {
        id = UUID()
        
        super.init(log)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

@available(iOS 13.0, *)
public class InRoomLogMonitor: ObservableObject {
    @Published public var peerNames: [PeerIdentifier] = []
    @Published public var logHistory: [LogInformationIdentified] = []

    private var dependency: InRoomLogMonitorDependency = InRoomLogMonitorResolver()
    private let nearPeer: NearPeer

    /// 複数のPeerの識別子を格納する
    private let peers = StructHolder()

    private var sendCounter: Int = 0

    public init() {
        // 一度に接続できるPeerは１つだけ
        nearPeer = NearPeer(maxPeers: 1)
    }

    public func start() {
        nearPeer.start(serviceType: dependency.serviceType,
                       displayName: "\(dependency.appName).\(dependency.identifier)",
                       myDiscoveryInfo: dependency.myDiscoveryInfo,
                       targetDiscoveryInfo: dependency.targetDiscoveryInfo)

        nearPeer.onConnected { peer in
            print("🔵 [MON] \(peer.displayName) Connected")
            // TODO: 切断された時の処理を追加すること

            let peerComponents = peer.displayName.components(separatedBy: ".")

            if let displayName = peerComponents.first, let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                self.peers.set(PeerIdentifier(id: uuid, displayName: displayName))
                self.peerNames = self.peers.map {
                    $0 as! PeerIdentifier
                }

                print("🟡 [MON] peerName | \(displayName), peerIdentifier = \(uuidString)")
            }
        }

        nearPeer.onDisconnect { peer in
            Task {
                await MainActor.run {
                    print("🔴 [MON] \(peer) is disconnected")

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

        nearPeer.onReceived { peer, data in
            Task {
                await MainActor.run {
                    print("🟢 [MON] Received")

                    guard let data = data else {
                        print("データがありません")
                        return
                    }

                    if let content = try? JSONDecoder().decode(LogInformation.self, from: data) {
                        self.logHistory.append(LogInformationIdentified(content))
                        print(content)

                    } else if let text = try? JSONDecoder().decode(String.self, from: data) {
                        print(text)
                    } else {
                        print("decode失敗")
                    }
                }
            }
        }
    }

    public func stop() {
        nearPeer.stop()
    }

    public func resume() {
        nearPeer.resume()
    }

    public func suspend() {
        nearPeer.suspend()
    }
}
