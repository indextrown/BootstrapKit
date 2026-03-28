//
//  BootstrapFirebaseAuth.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/28/26.
//

import Foundation

// MARK: - Public API
public enum BootstrapFirebaseAuth {
    private static var currentExecutor: AppleLoginExecutor?
}

// MARK: - Apple
extension BootstrapFirebaseAuth {
    // completion
    public static func loginWithApple(
        completion: @escaping (Result<AuthResult, Error>) -> Void
    ) {
        let excutor = AppleLoginExecutor()
        currentExecutor = excutor
        excutor.execute { result in
            completion(result)
            currentExecutor = nil
        }
    }
    
    // async
    public static func loginWithApple() async throws -> AuthResult {
        try await withCheckedThrowingContinuation { continuation in
            loginWithApple { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


