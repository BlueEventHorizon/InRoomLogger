//
//  StructHolder.swift
//  InRoomLogger
//
//  Created by Katsuhiko Terada on 2022/08/21.
//

import Foundation

/// Classインスタンスを保持するユーティリティクラス
final class StructHolder: Sequence, IteratorProtocol {
    static let `default` = StructHolder()

    private var holder = [any UUIDIdentifiable]()
    private var queueMax: Int = 0 // 0 means no max limitation when using enqueue/dequeue
    private var counter: Int = 0

    var isEmpty: Bool {
        holder.isEmpty
    }

    /// 一番古いオブジェクトを取得する
    var first: (any UUIDIdentifiable)? {
        holder.first
    }

    /// 一番新しいオブジェクトを取得する
    var last: (any UUIDIdentifiable)? {
        holder.last
    }

    // MARK: - lifecycle

    init() {}

    // MARK: - func

    func makeIterator() -> StructHolder {
        counter = 0
        return self
    }

    // IteratorProtocol
    func next() -> (any UUIDIdentifiable)? {
        if holder.count > counter {
            let index = counter
            counter += 1
            return holder[index]
        }
        return nil
    }

    // MARK: - 基本機能

    /// オブジェクトを新規追加
    func set(_ obj: any UUIDIdentifiable) {
        holder.append(obj)
    }

    /// オブジェクトを取得する
    func get(identifier: UUID) -> (any UUIDIdentifiable)? {
        holder.enumerated().first(where: { $0.element.id == identifier })?.element
    }

    /// オブジェクトを削除
    @discardableResult
    func remove(identifier: UUID) -> (any UUIDIdentifiable)? {
        if let enumerated = holder.enumerated().first(where: { $0.element.id == identifier }) {
            let obj = enumerated.element
            holder.remove(at: enumerated.offset)
            return obj
        }
        return nil
    }

    func reset() {
        counter = 0
        holder = [any UUIDIdentifiable]()
    }

    // MARK: - Queue

    // Queue [FIFO] オブジェクトを追加
    func enqueue(_ obj: any UUIDIdentifiable) {
        if queueMax != 0, holder.count > queueMax {
            dequeue()
        }
        set(obj)
    }

    /// Queue [FIFO] オブジェクトを取り出す（最初に追加したオブジェクトから取り出して、取り出したら削除）
    @discardableResult
    func dequeue() -> (any UUIDIdentifiable)? {
        if let first = first {
            remove(identifier: first.id)
            return first
        }
        return nil
    }

    // MARK: - Push/Pop

    /// Stack [LIFO] オブジェクトを追加
    func push(_ obj: any UUIDIdentifiable) {
        set(obj)
    }

    /// Stack [LIFO] オブジェクトを取り出す（最後に追加したオブジェクトから取り出して、取り出したら削除）
    func pop() -> (any UUIDIdentifiable)? {
        if let last = last {
            remove(identifier: last.id)
            return last
        }
        return nil
    }
}
