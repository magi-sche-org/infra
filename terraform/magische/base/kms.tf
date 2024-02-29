resource "aws_kms_key" "main" {
  description         = "KMS key for magische ${var.env}"
  enable_key_rotation = true

  # # このKMSキーポリシーはキーへのアクセス制御の「門戸」を設定します。
  # # 注意: ここで `AWS = "*"` と設定することで、理論上は全てのAWSアカウントからのアクセスを許可しています。
  # # 実際にキーを使用するためには、呼び出し元のIAMポリシーによるさらなるアクセス許可が必要です。
  # # この広範な許可はセキュリティリスクを伴うため、実運用ではより制限的なポリシーを検討してください。by chatgpt
  # policy = jsonencode({
  #   Version = "2012-10-17",
  #   Statement = [
  #     {
  #       Effect = "Allow",
  #       Principal = {
  #         AWS = "*"
  #       },
  #       Action   = "kms:*",
  #       Resource = "*"
  #     },
  #   ]
  # })

  tags = {
    Name = "magische-${var.env}-kms"
  }
}

resource "aws_kms_alias" "main" {
  name          = "alias/magische-${var.env}-key"
  target_key_id = aws_kms_key.main.id
}
