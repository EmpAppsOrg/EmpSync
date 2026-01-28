// Sources/EmpSync/Types/ConflictStrategy.swift
import EmpCore
import Foundation

/// Strategy for resolving sync conflicts between local and remote records
public struct ConflictStrategy: Sendable {
    private let resolver: @Sendable (any EmpModel, any EmpModel) -> any EmpModel

    private init(resolver: @escaping @Sendable (any EmpModel, any EmpModel) -> any EmpModel) {
        self.resolver = resolver
    }

    /// Resolve conflict between local and remote models
    public func resolve<T: EmpModel>(local: T, remote: T) -> T {
        let resolved = resolver(local, remote)
        guard let result = resolved as? T else {
            preconditionFailure("ConflictStrategy resolver returned wrong type")
        }
        return result
    }

    /// Keep the record with the most recent updatedAt timestamp
    public static let lastWriteWins = ConflictStrategy { local, remote in
        local.updatedAt >= remote.updatedAt ? local : remote
    }

    /// Always keep the local version
    public static let keepLocal = ConflictStrategy { local, _ in
        local
    }

    /// Always keep the remote version
    public static let keepRemote = ConflictStrategy { _, remote in
        remote
    }

    /// Create a custom conflict resolution strategy
    public static func custom(
        _ resolver: @escaping @Sendable (any EmpModel, any EmpModel) -> any EmpModel
    ) -> ConflictStrategy {
        ConflictStrategy(resolver: resolver)
    }
}
