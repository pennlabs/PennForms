//
//  AtLeastValidator.swift
//
//
//  Created by Jordan H on 3/6/24.
//

import Foundation
import OrderedCollections

public struct AtLeastValidator<T: Comparable>: Validator {
    public let message: String?
    public let limit: T
    
    public init(value: T, _ message: (T) -> String) {
        self.limit = value
        self.message = message(value)
    }
    
    public init(value: T, _ message: String = "Must be at least") {
        self.limit = value
        self.message = "\(message) \(value)"
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
    func atLeast<T: Comparable>(value: T, _ message: String = "Must be at least") -> Self { AtLeastValidator(value: value, message) as! Self }
}
