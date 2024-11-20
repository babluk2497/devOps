# EBS Volume
resource "aws_ebs_volume" "vol-1" {
  availability_zone = "us-west-2a"
  size              = 5
  tags = {
    Name = "tf-volume-1"
  }
}