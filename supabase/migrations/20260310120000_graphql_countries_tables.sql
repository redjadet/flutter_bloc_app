-- Migration: GraphQL demo countries tables (continents + countries) for Supabase-backed reads.
-- Idempotent: safe to re-run.

CREATE TABLE IF NOT EXISTS public.graphql_continents (
  code text PRIMARY KEY,
  name text NOT NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.graphql_countries (
  code text PRIMARY KEY,
  name text NOT NULL,
  continent_code text NOT NULL
    REFERENCES public.graphql_continents(code) ON DELETE CASCADE,
  capital text,
  currency text,
  emoji text,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS graphql_countries_continent_code_idx
  ON public.graphql_countries(continent_code);

ALTER TABLE public.graphql_continents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.graphql_countries ENABLE ROW LEVEL SECURITY;

-- App reads from Supabase only when signed in.
-- Edge Function writes using the service role key (bypasses RLS).
DROP POLICY IF EXISTS "graphql_continents_select_auth" ON public.graphql_continents;
CREATE POLICY "graphql_continents_select_auth" ON public.graphql_continents
  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "graphql_countries_select_auth" ON public.graphql_countries;
CREATE POLICY "graphql_countries_select_auth" ON public.graphql_countries
  FOR SELECT TO authenticated USING (true);

