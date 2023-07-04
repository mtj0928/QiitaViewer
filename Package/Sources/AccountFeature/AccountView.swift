import SwiftUI

public struct AccountView: View {

    @Environment(\.openURL) var openURL

    @State var viewModel: AccountViewModel

    public init(viewModel: AccountViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if let user = viewModel.user {
                        HStack {
                            AsyncImage(url: user.profileImageURL) { phase in
                                switch phase {
                                case .success(let image):
                                    image.resizable()
                                        .scaledToFit()
                                default:
                                    Color.gray
                                }
                            }
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                            Text(user.displayName)
                                .bold()
                        }
                    } else {
                        Text("ユーザー未登録")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("アクセストークン") {
                    SecureField("アクセストークンを入力", text: $viewModel.accessToken)
                        .onSubmit {
                            Task {
                                await viewModel.submitToken()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button("アクセストークンの取得方法") {
                        let url = URL(string: "https://qiita.com/settings/applications")!
                        openURL(url)
                    }
                }
            }
            .navigationTitle("アカウント情報")
        }
        .task {
            if viewModel.user == nil {
                await viewModel.updateUser()
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView(
            viewModel: AccountViewModel(
                apiClient: .mock,
                keychain: .mock
            )
        )
    }
}
