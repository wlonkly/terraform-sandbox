# resource "aws_iam_role" "instance-role" {
#   name = "rlafferty-eks-instance-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF

#   tags = {
#     Name  = "rlafferty-eks-instance-role"
#     owner = "rlafferty"
#   }
# }

# resource "aws_iam_role_policy_attachment" "role-attach" {
#   role       = aws_iam_role.instance-role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "profile" {
#   name = "rlafferty-eks-test-profile"
#   role = aws_iam_role.instance-role.name
# }

