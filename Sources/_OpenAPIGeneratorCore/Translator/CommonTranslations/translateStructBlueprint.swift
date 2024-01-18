//
//  translateStructBlueprint.swift
//  MTH Accounting
//
//  Created by Colton Hillebrand on 1/18/24.
//
//  Copyright © 2024 MTill Holdings. All rights reserved.
//
//  Confidential and Proprietary. This source code is the exclusive property of MTill Holdings and
//  may not be
//  reproduced, disseminated or utilized without the express written consent of MTill Holdings.
//  Use of this source code is governed by the license agreement entered into with MTill Holdings.

import Foundation
//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftOpenAPIGenerator open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftOpenAPIGenerator project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftOpenAPIGenerator project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import OpenAPIKit

extension FileTranslator {

    /// Returns a declaration of the specified blueprint.
    /// - Parameter blueprint: Structure blueprint containing the information
    /// required to generate the Swift structure.
    /// - Returns: A `Declaration` representing the generated Swift structure.
    func translateStructBlueprint(_ blueprint: StructBlueprint) -> Declaration {

        let typeName = blueprint.typeName
        let allProperties = blueprint.properties
        let serializableProperties = allProperties.filter(\.isSerializedInTopLevelDictionary)

        let propertyDecls = allProperties.flatMap(self.translatePropertyBlueprint)

        let uuidFunctionCall = FunctionCallDescription(
            calledExpression: .identifier(.pattern("UUID")),
            arguments: [] as [FunctionArgumentDescription]
        )
        let idRightExpression = Expression.functionCall(uuidFunctionCall)

        let idProperty = Declaration.commentable(
            nil,
            .variable(
                .init(
                    accessModifier: config.access,
                    kind: .var,
                    left: .identifier(.pattern("id")),
                    type: .init(TypeName.uuid),
                    right: idRightExpression
                )
            )
        )
        var members = propertyDecls
        members.append(idProperty)
        let initDecl = self.translateStructBlueprintInitializer(
            typeName: typeName,
            properties: allProperties
        )
        members.append(initDecl)

        if blueprint.shouldGenerateCodingKeys && !serializableProperties.isEmpty {
            let codingKeysDecl = self
                .translateStructBlueprintCodingKeys(properties: serializableProperties)
            members.append(codingKeysDecl)
        }

        if let customDecoder = translateStructBlueprintDecoder(
            strategy: blueprint.codableStrategy,
            properties: serializableProperties
        ) {
            members.append(customDecoder)
        }

        if let customEncoder = translateStructBlueprintEncoder(
            strategy: blueprint.codableStrategy,
            properties: serializableProperties
        ) {
            members.append(customEncoder)
        }

        let structDesc = StructDescription(
            accessModifier: config.access,
            name: typeName.shortSwiftName,
            conformances: blueprint.conformances,
            members: members
        )

        return .commentable(
            blueprint.comment,
            .struct(structDesc).deprecate(if: blueprint.isDeprecated)
        )
    }

    /// Returns a declaration of an initializer declared in a structure.
    /// - Parameters:
    ///   - typeName: The type name of the structure.
    ///   - properties: The properties to include in the initializer.
    /// - Returns: A `Declaration` representing the translated struct.
    func translateStructBlueprintInitializer(
        typeName: TypeName,
        properties: [PropertyBlueprint]
    ) -> Declaration {

        let comment: Comment = properties.initializerComment(typeName: typeName.shortSwiftName)

        let decls: [(ParameterDescription, String)] = properties.map { property in
            (
                ParameterDescription(
                    label: property.swiftSafeName,
                    type: .init(property.typeUsage),
                    defaultValue: property.defaultValue?.asExpression
                ), property.swiftSafeName
            )
        }

        let parameters = decls.map(\.0)
        let assignments: [CodeBlock] = decls.map(\.1)
            .map { variableName in
                .expression(
                    .assignment(
                        Expression.identifierPattern("self").dot(variableName)
                            .equals(.identifierPattern(variableName))
                    )
                )
            }

        return .commentable(
            comment,
            .function(
                accessModifier: config.access,
                kind: .initializer,
                parameters: parameters,
                body: assignments
            )
        )
    }

    /// Returns a list of declarations for a specified property blueprint.
    ///
    /// May return multiple declarations when the property contains an unnamed
    /// JSON schema, in which case a type declaration of that type is included
    /// in the returned array.
    /// - Parameter property: Information about the property.
    /// - Returns: A list of Swift declarations representing the translated property.
    func translatePropertyBlueprint(_ property: PropertyBlueprint) -> [Declaration] {
        let propertyDecl: Declaration = .commentable(
            property.comment,
            .variable(
                accessModifier: config.access,
                kind: .var,
                left: property.swiftSafeName,
                type: .init(property.typeUsage)
            )
            .deprecate(if: property.isDeprecated)
        )
        return property.associatedDeclarations + [propertyDecl]
    }

    /// Returns a declaration of a coding keys enum.
    /// - Parameter properties: The properties of the structure.
    /// - Returns: A coding keys enum declaration.
    func translateStructBlueprintCodingKeys(properties: [PropertyBlueprint]) -> Declaration {
        let members: [Declaration] = properties.map { property in
            let swiftName = property.swiftSafeName
            let rawName = property.originalName
            return .enumCase(
                name: swiftName,
                kind: swiftName == rawName ? .nameOnly :
                    .nameWithRawValue(.string(property.originalName))
            )
        }
        return .enum(
            accessModifier: config.access,
            name: Constants.Codable.codingKeysName,
            conformances: Constants.Codable.conformances,
            members: members
        )
    }
}

private extension Array where Element == PropertyBlueprint {

    /// Returns the comment string for an initializer of a structure with
    /// the properties contained in the current array.
    /// - Parameter typeName: The name of the structure type.
    /// - Returns: A comment string describing the initializer.
    func initializerComment(typeName: String) -> Comment {
        Comment.functionComment(
            abstract: "Creates a new `\(typeName)`.",
            parameters: map { ($0.swiftSafeName, $0.comment?.firstLineOfContent) }
        )! // This force-unwrap is safe as the method never returns nil when
        // a non-nil abstract is provided.
    }
}
