// // This source file was generated by SwiftOpenAPIGenerator
// // Copyright (c) 2023 by the project authors
// // Licensed under Apache License v2.0
import Foundation
import OpenAPIKit
/// Types generated from the `#/components/schemas` section of the OpenAPI document.
internal enum Schemas {
    /// A value with the greeting contents.
    ///
    /// - Remark: Generated from `#/components/schemas/Greeting`.
    internal struct Greeting: Codable, Hashable, Sendable, Identifiable {
        /// The string representation of the greeting.
        ///
        /// - Remark: Generated from `#/components/schemas/Greeting/message`.
        internal var message: Swift.String
        internal var id: Foundation.UUID = UUID()
        /// Creates a new `Greeting`.
        ///
        /// - Parameters:
        ///   - message: The string representation of the greeting.
        internal init(message: Swift.String) {
            self.message = message
        }
        internal enum CodingKeys: String, CodingKey {
            case message
        }
    }
}

// // This source file was generated by SwiftOpenAPIGenerator
// // Copyright (c) 2023 by the project authors
// // Licensed under Apache License v2.0
import Foundation
import OpenAPIKit
/// Types generated from the `#/components/parameters` section of the OpenAPI document.
internal enum Parameters {}
