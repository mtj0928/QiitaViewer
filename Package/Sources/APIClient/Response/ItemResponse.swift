import Foundation

public struct ItemResponse: Codable, Identifiable, Hashable, Sendable {
    public var id: String
    public var title: String
    public var body: String
    public var createdAt: Date
    public var commentsCount: Int
    public var likesCount: Int
    public var user: UserResponse
    public var url: URL

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case body
        case createdAt = "created_at"
        case commentsCount = "comments_count"
        case likesCount = "likes_count"
        case user
        case url
    }
}

extension ItemResponse {
    public static var dummy: ItemResponse {
        ItemResponse(
            id: "item id",
            title: "ダミータイトル",
            body: sampleMarkdown,
            createdAt: .now,
            commentsCount: 10,
            likesCount: 5,
            user: .dummy,
            url: URL(string: "https://qiita.com/matsuji/items/be33e4338e0b19084174")!)
    }
}

let sampleMarkdown = """
最近、SwiftUIでプレゼンスライドが作れる[mtj0928/SlideKit](https://github.com/mtj0928/SlideKit)というライブラリを作りました。

ライブラリを開発する上で、ドキュメントというものは考えなければいけないものの1つです。
Swiftで書かれたコードのドキュメントを書く方法としてDocCがあります。
DocCはSwift公式のツールで、APIのドキュメントだけじゃなくて、記事やチュートリアルも追加できます。
最近は[swift-docc-plugin](https://github.com/apple/swift-docc-plugin)がリリースされ、静的サイトとしてドキュメント（以降、単に静的サイトと呼びます）を出力することもできるようになりました。

こうなるとGitHub Pagesにデプロイしたくなってきます。
さらに、このデプロイも自動化したくなります。

この記事では、GitHub ActionsでDocCをビルドしてGitHub Pagesにデプロイする方法を説明します。

# DocCで静的サイトを出力する方法
まずはDocCで静的サイトを出力する方法を説明します。
これを実現するには前述の[swift-docc-plugin](https://github.com/apple/swift-docc-plugin)を`Package.swift`に追加します。
```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ]
)
```
これを追加することで、以下のコマンドで静的サイトを出力できるようになります。
```sh
$ swift package --allow-writing-to-directory [path-to-docs-directory] \
    generate-documentation --target [target-name] \
    --disable-indexing \
    --transform-for-static-hosting \
    --hosting-base-path [hosting-base-path] \
    --output-path [path-to-docs-directory]
```
パラメータの説明をします。
- path-to-docs-directory: 静的サイトを生成するディレクトリへのパスです。
- target-name: 生成するターゲットの名前です。SwiftPMは複数のターゲットをもつのでこれが必要になります。
- hosting-base-path: ホスティングするドメインからみて、どこにデプロイされるかです。GitHhub Pagesの場合、`https://<username>.github.io/<repository name>`にデプロイされるので、repositoryの名前を渡せばOKです。

これで`path-to-docs-directory`に静的サイトが生成されます。

# GitHub ActionsとGitHub Pagesの設定
## 静的サイトの生成
さて、では次に上の手順をGitHub Actionsで設定します。
といっても、上のコマンドをymlに移すだけです。
この例では`./docs`に静的サイトを生成します。

```yml
jobs:
  build:
    runs-on: macos-12
    env:
      DEVELOPER_DIR: /Applications/Xcode_14.0.app/Contents/Developer
    steps:
      - uses: actions/checkout@v3
      - name: build docc
        run: |
          swift package --allow-writing-to-directory ./docs generate-documentation \
          --target [target-name] \
          --disable-indexing \
          --output-path ./docs \
          --transform-for-static-hosting \
          --hosting-base-path [hosting-base-path]
```
SlideKitはXcode14が必要なのですが、記事執筆時ではデフォルトのXcodeがまだ13だったので、ここでは環境変数`DEVELOPER_DIR`を上書きして、Xcode14にしています。

## GitHub Pagesの設定
さてGitHub Pagesの設定をしていきます。
今まではリポジトリの中にhtmlファイルを直接保存したり、別のブランチでhtmlファイルを管理したりする必要がありましたが、最近別の新しい方法が登場しました。
新しい方法ではGitHub ActionsからGitHub Pagesにサイトを直接デプロイできます。
なのでリポジトリの中でhtmlファィルの管理をする必要がなく、リポジトリが汚染されないというメリットがあります。
この機能は記事執筆時の2022/09/19の時点ではまだβ版です。

どちらの方法を使うかは、GitHub Pagesの設定の画面でSourceから選択できます。
![github_action.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/70011/264e0955-77a5-f3dc-3ac0-2272751a7ee6.png)
今回は、GitHub Actionsを用いた新しい方法で進めたいと思います。

以下の手順で、GitHub ActionsからGitHub Pagesにデプロイできます。
1. デプロイしたいファイルをartifactにアップロードする
2. アップロードされたartifactをGitHub Pagesにデプロイする

### artifactのアップロード
まず、`actions/upload-pages-artifact`を使ってアップロードをしていきます。
今回は`docs`に静的サイトを生成したので、pathには`docs`を指定しています。
```diff_yaml
jobs:
  build:
    runs-on: macos-12
    env:
      DEVELOPER_DIR: /Applications/Xcode_14.0.app/Contents/Developer
    steps:
      - uses: actions/checkout@v3
      - name: build docc
        run: |
          swift package --allow-writing-to-directory ./docs generate-documentation \
          --target SlideKit \
          --disable-indexing \
          --output-path ./docs \
          --transform-for-static-hosting \
          --hosting-base-path SlideKit
+     - uses: actions/upload-pages-artifact@v1
+       with:
+         path: docs
```

### GitHub Pagesへのデプロイ
次にアップロードしたartifactを`actions/deploy-pages@v1`を使ってGitHub Pagesにデプロイします。
```diff_yaml
jobs:
  build:
    runs-on: macos-12
    env:
      DEVELOPER_DIR: /Applications/Xcode_14.0.app/Contents/Developer
    steps:
      - uses: actions/checkout@v3
      - name: build docc
        run: |
          swift package --allow-writing-to-directory ./docs generate-documentation \
          --target SlideKit \
          --disable-indexing \
          --output-path ./docs \
          --transform-for-static-hosting \
          --hosting-base-path SlideKit
      - uses: actions/upload-pages-artifact@v1
        with:
          path: docs

+ deploy:
+   needs: build
+   permissions:
+     pages: write
+     id-token: write
+   environment:
+     name: github-pages
+     url: ${{ steps.deployment.outputs.page_url }}
+   runs-on: macos-12
+   steps:
+     - name: Deploy to GitHub Pages
+       id: deployment
+       uses: actions/deploy-pages@v1
```

これでアップロードしたartifactがGitHub Pagesにデプロイされます。
デプロイされたサイトは`https://<username>.github.io/<repository name>/documentation/<target name>/`からアクセスできます。


# まとめ
GitHub ActionsでDocCをビルドしてGitHub Pagesにデプロイする方法を紹介しました。
GitHub Pagesのためにリポジトリを汚染する必要がないのが非常に良いなと感じました。

正直、GitHub Actionsにはあまり詳しくなくて、参考にしたURLのつぎはぎに近いですが、この記事が誰かの手助けになれば幸いです。

# 参考
- 新しいGitHub Pagesのデプロイ方法を試す: https://zenn.dev/ssssota/articles/f2509a21b768ed
- GitHub Pages: Custom GitHub Actions Workflows (beta): https://github.blog/changelog/2022-07-27-github-pages-custom-github-actions-workflows-beta/
- Publishing to GitHub Pages: https://apple.github.io/swift-docc-plugin/documentation/swiftdoccplugin/publishing-to-github-pages/
"""
