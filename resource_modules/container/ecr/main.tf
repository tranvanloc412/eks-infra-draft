resource "aws_ecr_repository" "this" {
  count                = length(var.repos)
  name                 = var.repos[count.index]
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    {
      "Name" : "${var.project_name}-${var.env}-ecr-${var.repos[count.index]}",
    },
    var.tags
  )
}

resource "aws_ecr_repository_policy" "this" {
  count      = length(var.repos)
  repository = aws_ecr_repository.this[count.index].name

  policy = file("${path.module}/policies/repo_policy.json")
}

resource "aws_ecr_lifecycle_policy" "this" {
  count      = length(var.repos)
  repository = aws_ecr_repository.this[count.index].name

  policy = file("${path.module}/policies/ecr_lifecycle.json")
}
