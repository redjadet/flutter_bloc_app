-- Migration: Chart demo trending points table for Supabase-backed reads.
-- Synced from CoinGecko via Edge Function sync-chart-trending.
-- Idempotent: safe to re-run.

CREATE TABLE IF NOT EXISTS public.chart_trending_points (
  date_utc timestamptz NOT NULL PRIMARY KEY,
  value double precision NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.chart_trending_points ENABLE ROW LEVEL SECURITY;

-- App reads from Supabase when signed in.
-- Edge Function writes using the service role key (bypasses RLS).
DROP POLICY IF EXISTS "chart_trending_points_select_auth"
  ON public.chart_trending_points;
CREATE POLICY "chart_trending_points_select_auth"
  ON public.chart_trending_points
  FOR SELECT TO authenticated USING (true);
