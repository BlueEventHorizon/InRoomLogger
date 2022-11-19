//
//  ContentView.swift
//  InRoomLogMonitor
//
//  Created by Katsuhiko Terada on 2022/10/26.
//

import SwiftUI
import Combine
import InRoomLogger

//protocol LogMonitorMainViewDependency: ObservableObject {
//    var logHistory: AnyPublisher<[LogInformationIdentified], Never> { get }
//}

struct LogMonitorMainView: View {
    @EnvironmentObject var monitor: InRoomLogMonitor
    @State var logHistory: [LogInformationIdentified] = []
    @State private var flag = true
    
    let bottomID = UUID()

    var body: some View {
        VStack(alignment: .trailing) {
            #if canImport(UIKit)
                let textStyle: TextStyleModifier.TextStyle = .init(font: .subheadline, textColor: .white)
                let borderStyle: BorderStyleModifier.BorderStyle = .init(fillColor: .accentColor )
            #else
                let textStyle: TextStyleModifier.TextStyle = .init(font: .subheadline, textColor: .accentColor)
                let borderStyle: BorderStyleModifier.BorderStyle = .init()
            #endif

            Button {
                //
            } label: {
                CustomStyleLabel(text: .constant("clear"), imageName: .constant(""), textStyle: .constant(textStyle), borderStyle: .constant(borderStyle))
            }

            Toggle(isOn: $flag) {
                Text(flag ? "最新のログを追尾する": "最新のログを追尾しない")
            }

            ScrollViewReader { reader in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(self.logHistory) { log in
                            Text(generateMessage(with: log))
                                .font(.system(size: 12, design: .monospaced))
                        }
                    }
                    .onReceive(monitor.logHistory, perform: { value in
                        self.logHistory = value
                    })
                    .onAppear {
                        self.logHistory = monitor.logs
                    }
                    Spacer()
                        .id(bottomID)
                }
                .onChange(of: logHistory) { newValue in
                    if flag {
                        withAnimation {
                            // 一番下にスクロールする
                            reader.scrollTo(bottomID)
                        }
                    }
                }
            }
        }
        .padding(20)
    }

    // stringが空でなければstringの前にspacerを追加する
    func addSeparater(_ string: String, prefix: String = " ") -> String {
        guard !string.isEmpty else { return "" }

        return "\(prefix)\(string)"
    }

    // swiftlint:disable switch_case_on_newline
    func prefix(with info: LogInformation) -> String {
        if let prefix = info.prefix {
            return prefix
        }

        switch info.level {
            case .log: return ""
            case .debug: return "#DEBG"
            case .info: return "#INFO"
            case .warning: return "#WARN"
            case .error: return "#🔥"
            case .fault: return "#🔥🔥"
        }
    }

    func generateMessage(with info: LogInformation) -> String {
        let prefix = prefix(with: info)
        return info.level == .info ?
            "\(prefix)\(addSeparater(info.message)) [\(info.objectName)]" :
            "\(prefix) [\(info.timestamp())]\(addSeparater(info.message)) [\(info.threadName)] [\(info.objectName)] \(info.fileName): \(info.line))"
    }
}

struct LogMonitorMainView_Previews: PreviewProvider {
    // @StateObject private var monitor = InRoomLogMonitor()

    static var previews: some View {
        LogMonitorMainView()
           // .environmentObject(monitor)
    }
}
