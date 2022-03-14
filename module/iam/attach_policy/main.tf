resource "aws_iam_role_policy_attachment" "aws_iam_role_policy_attachment" {
  role = var.role
  policy_arn = "arn:aws:iam::aws:policy/${var.policy}"
}