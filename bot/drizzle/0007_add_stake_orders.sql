-- Migration: Add stake_orders table for Swap and Stake feature
-- Created: 2026-02-28
-- Issue: #222

CREATE TABLE IF NOT EXISTS "stake_orders" (
  "id" SERIAL PRIMARY KEY,
  "telegram_id" BIGINT NOT NULL,
  "sideshift_order_id" TEXT NOT NULL UNIQUE,
  "quote_id" TEXT NOT NULL,
  "from_asset" TEXT NOT NULL,
  "from_network" TEXT NOT NULL,
  "from_amount" REAL NOT NULL,
  "swap_to_asset" TEXT NOT NULL,
  "swap_to_network" TEXT NOT NULL,
  "stake_asset" TEXT NOT NULL,
  "stake_protocol" TEXT NOT NULL,
  "stake_network" TEXT NOT NULL,
  "settle_amount" TEXT,
  "deposit_address" TEXT NOT NULL,
  "deposit_memo" TEXT,
  "stake_address" TEXT,
  "stake_tx_hash" TEXT,
  "swap_status" TEXT NOT NULL DEFAULT 'pending',
  "stake_status" TEXT NOT NULL DEFAULT 'pending',
  "created_at" TIMESTAMP DEFAULT NOW(),
  "updated_at" TIMESTAMP DEFAULT NOW(),
  "completed_at" TIMESTAMP,
  CONSTRAINT chk_swap_status CHECK (swap_status IN ('pending', 'processing', 'settled', 'failed')),
  CONSTRAINT chk_stake_status CHECK (stake_status IN ('pending', 'submitted', 'confirmed', 'failed')),
  CONSTRAINT chk_positive_amount CHECK (from_amount > 0)
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS "idx_stake_orders_telegram_id" ON "stake_orders" ("telegram_id");
CREATE INDEX IF NOT EXISTS "idx_stake_orders_swap_status" ON "stake_orders" ("swap_status");
CREATE INDEX IF NOT EXISTS "idx_stake_orders_stake_status" ON "stake_orders" ("stake_status");
CREATE INDEX IF NOT EXISTS "idx_stake_orders_created_at" ON "stake_orders" ("created_at" DESC);

-- Composite index for worker queries (orders that need processing)
CREATE INDEX IF NOT EXISTS "idx_stake_orders_worker" ON "stake_orders" ("swap_status", "stake_status", "updated_at")
  WHERE swap_status IN ('pending', 'processing') OR (swap_status = 'settled' AND stake_status = 'pending');

-- Comment for documentation
COMMENT ON TABLE "stake_orders" IS 'Tracks swap and stake orders - combines SideShift swaps with DeFi protocol staking';
COMMENT ON COLUMN "stake_orders"."swap_status" IS 'Status of the swap portion: pending, processing, settled, failed';
COMMENT ON COLUMN "stake_orders"."stake_status" IS 'Status of the staking portion: pending, submitted, confirmed, failed';
