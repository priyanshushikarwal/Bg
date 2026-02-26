-- ================================================================
-- FIX: Disable RLS on all tables (simplest fix for single-user app)
-- Run this in Supabase Dashboard -> SQL Editor
-- ================================================================

-- Option 1: DISABLE RLS completely (simplest for personal/team app)
ALTER TABLE bank_guarantees DISABLE ROW LEVEL SECURITY;
ALTER TABLE bg_extensions DISABLE ROW LEVEL SECURITY;
ALTER TABLE fdr_details DISABLE ROW LEVEL SECURITY;

-- Drop existing policies (optional, cleanup)
DROP POLICY IF EXISTS "Users can view own BGs" ON bank_guarantees;
DROP POLICY IF EXISTS "Users can insert own BGs" ON bank_guarantees;
DROP POLICY IF EXISTS "Users can update own BGs" ON bank_guarantees;
DROP POLICY IF EXISTS "Users can delete own BGs" ON bank_guarantees;

DROP POLICY IF EXISTS "Users can view own extensions" ON bg_extensions;
DROP POLICY IF EXISTS "Users can insert own extensions" ON bg_extensions;
DROP POLICY IF EXISTS "Users can update own extensions" ON bg_extensions;
DROP POLICY IF EXISTS "Users can delete own extensions" ON bg_extensions;

DROP POLICY IF EXISTS "Users can view own FDR" ON fdr_details;
DROP POLICY IF EXISTS "Users can insert own FDR" ON fdr_details;
DROP POLICY IF EXISTS "Users can update own FDR" ON fdr_details;
DROP POLICY IF EXISTS "Users can delete own FDR" ON fdr_details;
