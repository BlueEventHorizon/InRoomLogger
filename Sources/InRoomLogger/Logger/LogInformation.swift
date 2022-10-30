//
//  LogInformation.swift
//  BwTools
//
//  Created by k2moons on 2022/10/28.
//  Copyright (c) 2022 k2moons. All rights reserved.
//

import Foundation

// ------------------------------------------------------------------------------------------
// MARK: - LogInformation
// ------------------------------------------------------------------------------------------

/// Logの基本情報を保持する構造体
public struct LogInformation: Codable {
    public enum Level: String, Codable, CaseIterable {
        case log
        case debug
        case info
        case warning
        case error
        case fault
    }

    public let level: Level
    public let message: String
    public let date: Date
    public let objectName: String
    public let function: String
    public let file: String
    public let line: Int
    public let prefix: String?

    /// 初期化
    /// - Parameters:
    ///   - message: ログ内容（String以外にも、CustomStringConvertible / TextOutputStreamable / CustomDebugStringConvertibleも可）
    ///   - level: ログレベル
    ///   - function: 関数名（自動で付加）
    ///   - file: ファイル名（自動で付加）
    ///   - line: ファイル行（自動で付加）
    ///   - prefix: 先頭に追加する文字列（初期値は無し）
    ///   - instance: インスタンスを渡すと、ログに「クラス名:関数名」を出力
    public init(_ message: Any, level: Level = .log, function: StaticString = #function, file: StaticString = #fileID, line: Int = #line, prefix: String? = nil, instance: Any? = nil) {
        self.level = level
        self.prefix = prefix

        // メッセージのdescriptionを取り出す（よってCustomStringConvertible / TextOutputStreamable / CustomDebugStringConvertibleを持つclassであれば何でも良いことになる）
        self.message = (message as? String) ?? String(describing: message)
        date = Date()

        self.function = "\(function)"
        self.file = "\(file)"
        self.line = line

        if let instance = instance {
            objectName = "\(String(describing: type(of: instance))):\(function)"
        } else {
            objectName = "\(function)"
        }
    }

    /// タイムスタンプを生成
    func timestamp(_ format: String = "yyyy/MM/dd HH:mm:ss.SSS z") -> String {
        date.string(dateFormat: format, timeZone: .current)
    }

    /// スレッド名を取得する
    public var threadName: String {
        if Thread.isMainThread {
            return "main"
        }
        if let threadName = Thread.current.name, threadName.isNotEmpty {
            return threadName
        }
        if let threadName = String(validatingUTF8: __dispatch_queue_get_label(nil)), threadName.isNotEmpty {
            return threadName
        }
        return Thread.current.description
    }

    /// ファイル名を取得する
    public var fileName: String {
        URL(fileURLWithPath: "\(file)").lastPathComponent
    }
}
