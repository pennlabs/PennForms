//
//  AtLeastValidator.swift
//
//
//  Created by Jordan H on 3/6/24.
//

import Foundation
import OrderedCollections

public struct AtLeastValidator<T: Comparable>: Validator {
    public let message: (Input?) -> String?
    public let limit: T

    public init(value: T, _ message: (T) -> String) {
        self.limit = value
        let finalMessage = message(value)
        self.message = { _ in finalMessage }
    }

    public init(value: T, _ message: String) {
        self.limit = value
        self.message = { _ in message }
    }

    public init(value: T) {
        self.limit = value
        self.message = { _ in "Must be at least \(value)" }
    }

    public typealias Input = Any
    public func isValid(_ input: Any) -> Bool {
        if let input = input as? T {
            return input >= limit
        } else {
            return true
        }
    }
}

public extension Validator {
    func atLeast<T: Comparable>(value: T, _ message: String) -> Self { AtLeastValidator(value: value, message) as! Self }

    func atLeast<T: Comparable>(value: T) -> Self { AtLeastValidator(value: value) as! Self }
}
