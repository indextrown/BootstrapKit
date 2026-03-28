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
                        // error handling
                        print("로그인 실패: \(error)")
                    }
                }
            } label: {
                Text("애플 로그인")
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
}
