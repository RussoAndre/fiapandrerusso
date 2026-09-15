# ──────────────────────────────────────────────────────────────────────────────
# Module: databases
# Provisions:
#   - 3 RDS PostgreSQL instances (auth, flag, analytics)
#   - 1 ElastiCache Redis cluster
#   - 1 DynamoDB table (ToggleMasterAnalytics)
# ──────────────────────────────────────────────────────────────────────────────

# ── Security Group: RDS ───────────────────────────────────────────────────────
resource "aws_security_group" "rds" {
  name        = "${var.project}-rds-sg"
  description = "Allow PostgreSQL traffic from within VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-rds-sg" })
}

# ── DB Subnet Group ───────────────────────────────────────────────────────────
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.project}-db-subnet-group" })
}

# ── RDS Instances ─────────────────────────────────────────────────────────────
# Credentials are stored in AWS Secrets Manager (see outputs).
# The actual secret value is passed in as a variable — never hardcoded.
resource "aws_db_instance" "postgres" {
  for_each = toset(var.rds_databases)

  identifier        = "${var.project}-${each.key}"
  engine            = "postgres"
  engine_version    = "15.5"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = replace(each.key, "-", "_")
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false
  backup_retention_period = 7

  tags = merge(var.tags, { Name = "${var.project}-${each.key}" })
}

# ── Security Group: ElastiCache ───────────────────────────────────────────────
resource "aws_security_group" "redis" {
  name        = "${var.project}-redis-sg"
  description = "Allow Redis traffic from within VPC"
  vpc_id      = var.vpc_id

  ingress {
    description = "Redis from VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-redis-sg" })
}

# ── ElastiCache Subnet Group ──────────────────────────────────────────────────
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project}-redis-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.project}-redis-subnet-group" })
}

# ── ElastiCache Redis Cluster ─────────────────────────────────────────────────
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  tags = merge(var.tags, { Name = "${var.project}-redis" })
}

# ── DynamoDB Table ────────────────────────────────────────────────────────────
resource "aws_dynamodb_table" "analytics" {
  name         = "ToggleMasterAnalytics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "flag_key"
  range_key    = "event_id"

  attribute {
    name = "flag_key"
    type = "S"
  }

  attribute {
    name = "event_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.tags, { Name = "ToggleMasterAnalytics" })
}
