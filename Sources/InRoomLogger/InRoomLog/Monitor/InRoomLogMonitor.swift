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
    
    var clientIdentifier: String { get }
    var monitorIdentifier: String { get }
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
    /// AnyPublisherとして外部へ公開
    public lazy var logHistory = { logHistorySubject.eraseToAnyPublisher() }()
    public lazy var peerNames = { peerNamesSubject.eraseToAnyPublisher() }()

    /// Subject
    private var peerNamesSubject = PassthroughSubject<[PeerIdentifier], Never>()
    private var logHistorySubject = PassthroughSubject<[LogInformationIdentified], Never>()

    /// ログ履歴
    public private(set) var logs: [LogInformationIdentified] = []
    /// 複数のPeerの識別子を格納する
    private let peers = StructHolder()

    private var dependency: InRoomLogMonitorDependency = InRoomLogMonitorResolver()
    private let nearPeer: NearPeer
    private var sendCounter: Int = 0

    public init() {
        // 一度に接続できるPeerは１つだけ
        nearPeer = NearPeer(maxPeers: 1)
    }

    public func start() {
        nearPeer.start(serviceType: dependency.serviceType,
                       displayName: "\(dependency.appName).\(dependency.identifier)",
                       myDiscoveryInfo: [.identifier: dependency.monitorIdentifier, .passcode: Const.passcode],
                       targetDiscoveryInfo: nil)

        nearPeer.onConnected { peer in
            print("🔵 [MON] \(peer.displayName) Connected")
            // TODO: 切断された時の処理を追加すること

            let peerComponents = peer.displayName.components(separatedBy: ".")

            if let displayName = peerComponents.first, let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                self.peers.set(PeerIdentifier(id: uuid, displayName: displayName))
                let peerNames = self.peers.map {
                    $0 as! PeerIdentifier
                }
                self.peerNamesSubject.send(peerNames)

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
                        let peerNames = self.peers.map {
                            $0 as! PeerIdentifier
                        }
                        self.peerNamesSubject.send(peerNames)
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
                        self.logs.append(LogInformationIdentified(content))
                        self.logHistorySubject.send(self.logs)
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
