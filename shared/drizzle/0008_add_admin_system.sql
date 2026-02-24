-- Admin role enum
DO $$ BEGIN
  CREATE TYPE "admin_role" AS ENUM('super_admin', 'admin', 'moderator');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Admin request status enum
DO $$ BEGIN
  CREATE TYPE "admin_request_status" AS ENUM('pending', 'approved', 'rejected');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Admin users table (approved admins)
CREATE TABLE IF NOT EXISTS "admin_users" (
  "id" serial PRIMARY KEY NOT NULL,
  "firebase_uid" text NOT NULL UNIQUE,
  "email" text NOT NULL UNIQUE,
  "name" text NOT NULL,
  "role" "admin_role" NOT NULL DEFAULT 'admin',
  "is_active" boolean NOT NULL DEFAULT true,
  "approved_at" timestamp,
  "approved_by" text,
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);

-- Admin access requests (pending approval)
CREATE TABLE IF NOT EXISTS "admin_requests" (
  "id" serial PRIMARY KEY NOT NULL,
  "firebase_uid" text NOT NULL UNIQUE,
  "email" text NOT NULL UNIQUE,
  "name" text NOT NULL,
  "reason" text NOT NULL,
  "status" "admin_request_status" NOT NULL DEFAULT 'pending',
  "approval_token" text NOT NULL UNIQUE,
  "rejection_reason" text,
  "reviewed_at" timestamp,
  "reviewed_by" text,
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS "idx_admin_users_email" ON "admin_users" ("email");
CREATE INDEX IF NOT EXISTS "idx_admin_users_firebase_uid" ON "admin_users" ("firebase_uid");
CREATE INDEX IF NOT EXISTS "idx_admin_requests_email" ON "admin_requests" ("email");
CREATE INDEX IF NOT EXISTS "idx_admin_requests_status" ON "admin_requests" ("status");
CREATE INDEX IF NOT EXISTS "idx_admin_requests_token" ON "admin_requests" ("approval_token");
