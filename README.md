## Terraform

### 初期化
`tf init`

### コードのフォーマット
`tf fmt -recursive`

### 変更確認
`tf plan`

### 変更の反映
`tf apply -auto-approve`

### リソース一覧確認
`tf state list`

### リソース詳細確認
`tf state show <ADDRESS>`
```
例）
tf state show aws_instance.app_server
```

### リソース名変更
1. tfstateファイル内のリソース名を変更する<br>
`tf state mv <BEFOE_ADDRESS> <AFTER_ADDRESS>`
```
例）
tf state mv aws_instance.app_server aws_instance.app_server2
```
2. ソースコード内のリソース名を変更する
3. tf planを実行し、No changes.と表示されればOK

### 手動作成したリソースの取り込み(Terraform管理対象にする)
1. ソースコードに取り込み分を追加する(一旦箱だけ)<br>
```
例）
resource "aws_instance" "test" {
}
```
2. tfstateファイルに取り込み分を書き込む<br>
`tf import <ADDRESS> <ID>`
```
例）
tf import aws_instance.test i-0b1fe74647588d42f

module化している場合
tf import module.network.aws_vpc.vpc vpc-04c08c10b544c0358
```
3. 1で作成したソースに必要な項目を追記する<br>
```
例）
resource "aws_instance" "test" {
  ami           = "ami-0e25eba2025eea319"
  instance_type = "t2.micro"
}
```
4. tf planを実行し、No changes.と表示されればOK

### リソースをTerraformから管理対象外にする
1. ソースコードからリソースのコードを削除
2. tfstateファイルから削除<br>
`tf state rm <ADDRESS>`
```
例）
tf state rm aws_instance.app_server
```
3. tf planを実行し、No changes.と表示されればOK
4. 3まで実施で該当のリソースはTerraform管理対象外にはなっているが、AWS上にはまだリソースは残っている<br>
→ 必要に応じてAWS上から手動でリソースを削除する

### AWS上とソースコードの差異の修正（AWS上のリソースに対して手作業で修正を加えた場合）
1. tfstateファイルを最新化する<br>
`tf refresh`<br>
上記コマンド実行時点で、AWS上の状態とtfstateファイルの内容は合っている、ソースコードの内容は合っていない状態<br>
2. 手作業での修正を正とする場合は、ソースコードを修正する<br>
ソースコードを正とする場合は、tf apply -auto-approveを実行してソースコードの内容を反映する
