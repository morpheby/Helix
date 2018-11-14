//
//  HelixInject.swift
//  Helix
//
//  Created by Ilya Mikhaltsou on 14.11.2018.
//  Copyright © 2018 Filtercode Ltd. All rights reserved.
//

import Foundation

public protocol HelixInject {

    /// Injects the property
    static func inject<T>(_ inj: @autoclosure () -> T.Type) -> T

    static func inject<T, A>(_ inj: @autoclosure () -> T.Type, arguments arg1: A) -> T

    static func inject<T, A, B>(_ inj: @autoclosure () -> T.Type, arguments arg1: A, _ arg2: B) -> T

    static func inject<T, A, B, C>(_ inj: @autoclosure () -> T.Type, arguments arg1: A, _ arg2: B, _ arg3: C) -> T

    static func inject<T, A, B, C, D>(_ inj: @autoclosure () -> T.Type, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D) -> T

    static func inject<T, A, B, C, D, E>(_ inj: @autoclosure () -> T.Type, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E) -> T
}

struct HelixInitContext {
    let helix: Helix
}

extension HelixInitContext: Equatable {
    static func ==(lhs: HelixInitContext, rhs: HelixInitContext) -> Bool {
        return lhs.helix === rhs.helix
    }
}

fileprivate let HELIX_INIT_CONTEXT_KEY = "HELIX_INIT_CONTEXT_KEY"

public extension HelixInject {
    internal static var initContext: HelixInitContext {
        let dict = Thread.current.threadDictionary
        guard let ctxObj = dict[HELIX_INIT_CONTEXT_KEY] else {
            fatalError("Attempting to use init context when init context is not set")
        }
        guard let ctxStore = ctxObj as? Array<HelixInitContext> else {
            fatalError("Invalid data in thread dictionary")
        }
        guard let ctx = ctxStore.last else {
            fatalError("Attempting to use invalid init context")
        }
        return ctx
    }

    internal static func push(context: HelixInitContext) {
        let dict = Thread.current.threadDictionary
        let ctxObj: Any
        if let t = dict[HELIX_INIT_CONTEXT_KEY] {
            ctxObj = t
        } else {
            ctxObj = Array<HelixInitContext>()
        }
        guard var ctxStore = ctxObj as? Array<HelixInitContext> else {
            fatalError("Invalid data in thread dictionary")
        }
        ctxStore.append(context)

        dict[HELIX_INIT_CONTEXT_KEY] = ctxStore as Any
    }

    internal static func pop(context: HelixInitContext) {
        let dict = Thread.current.threadDictionary
        let ctxObj: Any
        if let t = dict[HELIX_INIT_CONTEXT_KEY] {
            ctxObj = t
        } else {
            ctxObj = Array<HelixInitContext>()
        }
        guard var ctxStore = ctxObj as? Array<HelixInitContext> else {
            fatalError("Invalid data in thread dictionary")
        }
        let ctx = ctxStore.removeLast()
        assert(ctx == context)

        dict[HELIX_INIT_CONTEXT_KEY] = ctxStore as Any
    }

    static func inject<T>(_ inj: @autoclosure () -> T.Type) -> T {
        return try! initContext.helix.resolve()
    }

    static func inject<T, A>(_ inj: @autoclosure () -> T.Type, arguments arg1: A) -> T {
        return try! initContext.helix.resolve(arguments: arg1)
    }

    static func inject<T, A, B>(_ inj: @autoclosure () -> T.Type, arguments arg1: A, _ arg2: B) -> T {
        return try! initContext.helix.resolve(arguments: arg1, arg2)
    }

    static func inject<T, A, B, C>(_ inj: @autoclosure () -> T.Type, arguments arg1: A, _ arg2: B, _ arg3: C) -> T {
        return try! initContext.helix.resolve(arguments: arg1, arg2, arg3)
    }

    static func inject<T, A, B, C, D>(_ inj: @autoclosure () -> T.Type, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D) -> T {
        return try! initContext.helix.resolve(arguments: arg1, arg2, arg3, arg4)
    }

    static func inject<T, A, B, C, D, E>(_ inj: @autoclosure () -> T.Type, arguments arg1: A, _ arg2: B, _ arg3: C, _ arg4: D, _ arg5: E) -> T {
        return try! initContext.helix.resolve(arguments: arg1, arg2, arg3, arg4, arg5)
    }
}
