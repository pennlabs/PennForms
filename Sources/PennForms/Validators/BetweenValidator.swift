//
//  BetweenValidator.swift
//
//
//  Created by Jordan H on 3/6/24.
//

import Foundation
import OrderedCollections

public struct BetweenValidator<T: Comparable>: Validator {
    public let message: (Input?) -> String?
    public let lowLimit: T
    public let highLimit: T

    public init(lowLimit: T, highLimit: T, _ message: (T, T) -> String) {
        self.lowLimit = lowLimit
        self.highLimit = highLimit
        let finalMessage = message(lowLimit, highLimit)
        self.message = { _ in finalMessage }
    }

    public init(lowLimit: T, highLimit: T, _ message: String) {
        self.lowLimit = lowLimit
        self.highLimit = highLimit
        self.message = { _ in message }
    }

    public init(lowLimit: T, highLimit: T) {
        self.lowLimit = lowLimit
        self.highLimit = highLimit
        self.message = { _ in "Must be between \(lowLimit) and \(highLimit)" }
    }

    public typealias Input = Any
    public func isValid(_ input: Any) -> Bool {
        if let input = input as? T {
            return input >= lowLimit && input <= highLimit
        } else {
            return true
        }
    }
}

public extension Validator {
    func between<T: Comparable>(lowLimit: T, highLimit: T, _ message: String) -> Self { BetweenValidator(lowLimit: lowLimit, highLimit: highLimit, message) as! Self }

    func between<T: Comparable>(lowLimit: T, highLimit: T) -> Self { BetweenValidator(lowLimit: lowLimit, highLimit: highLimit) as! Self }
}
