# iOS App Store リリース用 署名設定手順

## 前提
- 有料の Apple Developer Program に加入済み
- Xcode がインストール済み

---

## 1. App ID（Bundle ID）を登録する

> **なぜ必要？** App ID はアプリの「戸籍」のようなもの。Apple のエコシステム上でアプリを一意に識別するために必要。これがないと証明書やプロファイルを紐づける対象がない。

1. [Apple Developer Portal](https://developer.apple.com/account/) にログイン
2. **Certificates, Identifiers & Profiles → Identifiers** に進む
3. 「+」ボタンをクリック
4. **App IDs** を選択
5. Bundle ID（例: `com.tommy.aerorota`）を入力して登録

---

## 2. CSR（証明書署名要求）を作成する

> **なぜ必要？** CSR は「この Mac の持ち主が証明書を要求しています」という申請書のようなもの。Mac 内部で秘密鍵が生成され、それとペアになる公開鍵が CSR に含まれる。Apple はこの CSR を受け取って、あなた専用の証明書を発行する。秘密鍵は Mac から外に出ないので、他人がなりすましてアプリを署名することを防げる。

1. Mac で **キーチェーンアクセス** アプリを開く
2. メニューバーの **キーチェーンアクセス → 証明書アシスタント → 認証局に証明書を要求** をクリック
3. メールアドレス（Apple ID のメールでOK）と名前を入力
4. 「ディスクに保存」を選択して保存
5. `.certSigningRequest` ファイルが生成される

---

## 3. Apple Distribution 証明書を作成する

> **なぜ必要？** Distribution 証明書は「この開発者は Apple に認められた正規の開発者です」という身分証明書。App Store に提出するアプリはこの証明書で署名されている必要がある。.cer ファイルをキーチェーンにインストールすることで、手順2で作った秘密鍵と紐づき、Xcode がアプリに署名できるようになる。

1. Apple Developer Portal の **Certificates** に進む
2. 「+」ボタンをクリック
3. **Apple Distribution** を選択
4. 手順2で作成した CSR ファイルをアップロード
5. 証明書が発行されるので **.cer ファイルをダウンロード**
6. **ダウンロードした .cer ファイルをダブルクリック** してキーチェーンにインストール（※これを忘れると Xcode が証明書を認識しない）

---

## 4. Provisioning Profile を作成する

> **なぜ必要？** Provisioning Profile は「この証明書を持つ開発者が、このApp IDのアプリを、この方法（App Store配布）で配布してよい」という許可証。証明書・App ID・配布方法の3つを結びつける役割がある。Apple はこの仕組みで、誰がどのアプリをどう配布するかを厳密に管理している。

1. Apple Developer Portal の **Profiles** に進む
2. 「+」ボタンをクリック
3. Distribution の中から **App Store Connect** を選択
4. 手順1で登録した **App ID** を選択
5. 手順3で作成した **Distribution 証明書** を選択
6. プロファイル名を入力して生成
7. ダウンロードして **ダブルクリック** で Xcode に読み込む

---

## 5. Xcode で署名設定をする

> **なぜ必要？** ここまでで作った素材（証明書・プロファイル）を Xcode のプロジェクトに紐づける最終ステップ。ここが正しく設定されていないと、Archive やApp Store への提出時にエラーになる。

1. プロジェクトの **Signing & Capabilities** を開く
2. **Automatically manage signing をオフ** にする
3. Provisioning Profile のドロップダウンから、手順4で作成したプロファイルを選択
4. Signing Certificate が **Apple Distribution** になっていることを確認
5. エラーが消えれば完了！

---

## 補足
- Distribution 証明書と Provisioning Profile には有効期限がある。期限切れの場合は再作成が必要
- **App Store リリース用にはデバイス（iPhone）の登録は不要**。デバイス登録が必要なのは Development（実機テスト）用のみ
