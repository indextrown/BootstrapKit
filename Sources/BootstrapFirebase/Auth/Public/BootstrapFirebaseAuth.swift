//
//  BootstrapFirebaseAuth.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/28/26.
//

import Foundation
import UIKit

// MARK: - Public API
public enum BootstrapFirebaseAuth {
    private static var currentExecutor: AppleLoginExecutor?
    private static var currentKakaoExecutor: KakaoLoginExecutor?
    private static var currentGoogleExecutor: GoogleLoginExecutor?
}

// MARK: - Apple
public extension BootstrapFirebaseAuth {
    // completion
    static func loginWithApple(
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
    static func loginWithApple() async throws -> AuthResult {
        try await withCheckedThrowingContinuation { continuation in
            loginWithApple { result in
                switch result {
                case .success(let authResult):
                    continuation.resume(returning: authResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Kakao
public extension BootstrapFirebaseAuth {
    // completion
    static func loginWithKakao(
        completion: @escaping (Result<AuthResult, Error>) -> Void
    ) {
        let executor = KakaoLoginExecutor()
        currentKakaoExecutor = executor
        
        executor.execute { result in
            completion(result)
            currentKakaoExecutor = nil
        }
    }
    
    // async
    static func loginWithKakao() async throws -> AuthResult {
        try await withCheckedThrowingContinuation { continuation in
            loginWithKakao { result in
                switch result {
                case .success(let authResult):
                    continuation.resume(returning: authResult)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Google
public extension BootstrapFirebaseAuth {
    // completion
    @MainActor
    static func loginWithGoogle(
        completion: @escaping (Result<AuthResult, Error>) -> Void
    ) {
        let executor = GoogleLoginExecutor()
        currentGoogleExecutor = executor
        
        executor.execute { result in
            completion(result)
            currentGoogleExecutor = nil
        }
    }
    
    // async
    @MainActor
    static func loginWithGoogle() async throws -> AuthResult {
        try await withCheckedThrowingContinuation { continuation in
            loginWithGoogle { result in
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
