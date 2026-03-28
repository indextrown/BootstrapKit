//
//  File.swift
//  BootstrapKit
//
//  Created by 김동현 on 3/28/26.
//

import FirebaseAuth

enum FirebaseAuthService {
    static func signIn(
        credential: AuthCredential,
        completion: @escaping (Result<User, Error>) -> Void
    ) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user else {
                completion(.failure(NSError(domain: "Auth", code: -1)))
                return
            }
            
            completion(.success(user))
        }
    }
}

