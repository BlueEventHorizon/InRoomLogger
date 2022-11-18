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

public protocol InRoomLogMonitorDependency {
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
    
    public override init(_ log: LogInformation) {
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
    private let passcode: String
    private var sendCounter: Int = 0

    public init(passcode: String, dependency: InRoomLogMonitorDependency? = nil) {
        // 一度に接続できるPeerは１つだけ
        nearPeer = NearPeer(maxPeers: 1)

        if let dependency = dependency {
            self.dependency = dependency
        }

        self.passcode = passcode
    }
    
    private func receive(log: LogInformation) {
        self.logs.append(LogInformationIdentified(log))
        self.logHistorySubject.send(self.logs)
    }

    private func log(_ log: LogInformation) {
        receive(log: log)
    }

    public func start() {
        nearPeer.start(serviceType: dependency.serviceType,
                       displayName: "\(dependency.appName).\(dependency.identifier)",
                       myDiscoveryInfo: [.identifier: dependency.monitorIdentifier, .passcode: passcode],
                       targetDiscoveryInfo: nil)

        nearPeer.onConnected { peer in
            self.log(LogInformation("[MON] \(peer.displayName) Connected", prefix: "🔵", instance: self))
            // TODO: 切断された時の処理を追加すること

            let peerComponents = peer.displayName.components(separatedBy: ".")

            if let displayName = peerComponents.first, let uuidString = peerComponents.last, let uuid = UUID(uuidString: uuidString) {
                self.peers.set(PeerIdentifier(id: uuid, displayName: displayName))
                let peerNames = self.peers.map {
                    $0 as! PeerIdentifier
                }
                self.peerNamesSubject.send(peerNames)

                self.log(LogInformation("[MON] peerName | \(displayName), peerIdentifier = \(uuidString)", prefix: "🟡", instance: self))
            }
        }

        nearPeer.onDisconnect { peer in
            Task {
                await MainActor.run {
                    self.log(LogInformation("[MON] \(peer) is disconnected", prefix: "🔴", instance: self))

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
                    self.log(LogInformation("[MON] Received", prefix: "🟢", instance: self))

                    guard let data = data else {
                        self.log(LogInformation("[MON] データがありません", level: .warning, prefix: "⚠️"))
                        return
                    }

                    if let content = try? JSONDecoder().decode(LogInformation.self, from: data) {
                        self.receive(log: content)

                    } else if let text = try? JSONDecoder().decode(String.self, from: data) {
                        self.log(LogInformation(text))
                    } else {
                        self.log(LogInformation("[MON] decode失敗", level: .error, prefix: "🔥", instance: self))
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
