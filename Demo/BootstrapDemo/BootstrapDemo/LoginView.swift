//
//  LoginView.swift
//  BootstrapDemo
//
//  Created by 김동현 on 3/28/26.
//

import SwiftUI
import BootstrapFirebase
struct LoginView: View {
    @StateObject private var loginVM = LoginViewModel()
    var body: some View {
        VStack {
            Button {
                Task {
                    do {
                        let result = try await loginVM.loginWithApple()
                        print("로그인 성공")
                        print("uid: \(result.uid)")
                    } catch {
                        print("로그인 실패: \(error)")
                    }
                }
            } label: {
                Text("애플 로그인")
            }
            
            Button {
                Task {
                    do {
                        let result = try await loginVM.loginWithKakao()
                        print("로그인 성공")
                        print("uid: \(result.uid)")
                    } catch {
                        print("로그인 실패: \(error)")
                    }
                }
            } label: {
                Text("카카오 로그인")
            }
            
            Button {
                Task {
                    do {
                        let result = try await loginVM.loginWithGoogle()
                        print("로그인 성공")
                        print("uid: \(result.uid)")
                    } catch {
                        print("로그인 실패: \(error)")
                    }
                }
            } label: {
                Text("구글 로그인")
            }
        }
    }
}

#Preview {
    LoginView()
}

final class LoginViewModel: ObservableObject {
    func loginWithApple() async throws -> AuthResult {
        try await BootstrapFirebaseAuth.loginWithApple()
    }
    
    func loginWithKakao() async throws -> AuthResult {
        try await BootstrapFirebaseAuth.loginWithKakao()
    }
    
    func loginWithGoogle() async throws -> AuthResult {
        try await BootstrapFirebaseAuth.loginWithGoogle()
    }
}
