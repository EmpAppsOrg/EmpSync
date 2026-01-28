// Sources/EmpSync/Types/SyncError.swift
import Foundation

/// Errors that can occur during synchronization
public enum SyncError: Error, Equatable, Sendable {
    /// Network is not available
    case networkUnavailable
    /// CloudKit storage quota exceeded
    case quotaExceeded
    /// Model version or schema mismatch
    case modelMismatch(String)
    /// User is not authenticated with iCloud
    case unauthorized
    /// Unknown error wrapper
    case unknown(NSError)

    public static func == (lhs: SyncError, rhs: SyncError) -> Bool {
        switch (lhs, rhs) {
        case (.networkUnavailable, .networkUnavailable): true
        case (.quotaExceeded, .quotaExceeded): true
        case let (.modelMismatch(a), .modelMismatch(b)): a == b
        case (.unauthorized, .unauthorized): true
        case let (.unknown(a), .unknown(b)): a == b
        default: false
        }
    }
}
