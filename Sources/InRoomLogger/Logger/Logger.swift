//
//  Logger.swift
//  InRoomLogger
//
//  Created by k2moons on 2022/10/28.
//  Copyright (c) 2022 k2moons. All rights reserved.
//

import Foundation

// ------------------------------------------------------------------------------------------
// MARK: - Logger
// ------------------------------------------------------------------------------------------

public class Logger {
    private static let semaphore = DispatchSemaphore(value: 1)

    /// ログのアウトプット先
    private(set) var outputs: [LogOutput]

    public init(passcode: String) {
        self.outputs = [InRoomLogOutput(passcode: passcode)]
    }

    /// ログのアウトプット先設定
    @discardableResult
    public func setOutput(_ outputs: [LogOutput]) -> Self {
        Logger.semaphore.wait()
        defer { Logger.semaphore.signal() }

        self.outputs = outputs
        return self
    }

    public func log(_ log: LogInformation) {
        outputs.forEach { output in
            output.log(log)
        }
    }

    /// 情報表示
    public func info(_ message: Any, instance: Any? = nil, function: StaticString = #function, file: StaticString = #fileID, line: Int = #line) {
        log(LogInformation(message, level: .info, function: function, file: file, line: line, instance: instance))
    }

    /// デバッグ情報
    public func debug(_ message: Any, instance: Any? = nil, function: StaticString = #function, file: StaticString = #fileID, line: Int = #line) {
        log(LogInformation(message, level: .debug, function: function, file: file, line: line, instance: instance))
    }

    /// 警告
    public func warning(_ message: Any, instance: Any? = nil, function: StaticString = #function, file: StaticString = #fileID, line: Int = #line) {
        log(LogInformation(message, level: .warning, function: function, file: file, line: line, instance: instance))
    }

    /// エラー
    public func error(_ message: Any, instance: Any? = nil, function: StaticString = #function, file: StaticString = #fileID, line: Int = #line) {
        log(LogInformation(message, level: .error, function: function, file: file, line: line, instance: instance))
    }

    /// 致命的なエラー
    public func fault(_ message: Any, instance: Any? = nil, function: StaticString = #function, file: StaticString = #fileID, line: Int = #line) {
        log(LogInformation(message, level: .fault, function: function, file: file, line: line, instance: instance))
    }
}

// ------------------------------------------------------------------------------------------
// MARK: - LogOutput
// ------------------------------------------------------------------------------------------

public protocol LogOutput {
    func log(_ information: LogInformation)
}
