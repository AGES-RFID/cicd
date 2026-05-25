import {
  to = aws_iam_role.lambda_exec
  id = "ages-rfid-lambda-role-staging"
}

import {
  to = aws_s3_bucket.artifacts
  id = "ages-rfid-artifacts-staging"
}
