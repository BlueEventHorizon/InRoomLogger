//
//  Date+Ext.swift
//
//
//  Created by Katsuhiko Terada on 2022/04/04.
//

import Foundation

extension Date {
    // Date → String
    func string(dateFormatType: FormatterType = .std, timeZone: TimeZone = .current) -> String {
        string(dateFormat: dateFormatType.rawValue, timeZone: timeZone)
    }

    // Date → String
    func string(dateFormat: String, timeZone: TimeZone) -> String {
        let formatter = DateFormatter.withTimeZone(timeZone)
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }

    // String → Date
    init?(dateString: String, dateFormatType: FormatterType = .std) {
        self.init(dateString: dateString, dateFormat: dateFormatType.rawValue)
    }

    // String → Date
    init?(dateString: String, dateFormat: String) {
        let formatter = DateFormatter.standard
        formatter.dateFormat = dateFormat
        guard let date = formatter.date(from: dateString) else { return nil }
        self = date
    }
}

extension Date {
    func stringTokyoTimeZone(dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = dateFormat

        return formatter.string(from: self)
    }
}

enum FormatterType: String {
    case detail = "yyyy/MM/dd HH:mm:ss.SSS z"
    case full = "yyyy-MM-dd'T'HH:mm:ssZ"
    case std = "yyyy-MM-dd HH:mm:ss"
    case birthday = "yyyy-MM-dd"
}

// MARK: - DateFormatter

extension DateFormatter {
    // 現在タイムゾーンの標準フォーマッタ
    static let standard: DateFormatter = withTimeZone(.current)

    static func withTimeZone(_ timeZone: TimeZone) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }
}
