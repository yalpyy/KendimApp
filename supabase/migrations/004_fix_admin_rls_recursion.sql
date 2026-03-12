-- Migration: Fix infinite recursion in admin RLS policies
--
-- The "Admins can view all users" policy on public.users queries public.users
-- inside its own USING clause, which triggers the same policy again → infinite loop.
--
-- Fix: Create a SECURITY DEFINER helper that bypasses RLS to check admin status,
-- then rewrite the admin policies to call that helper instead.

-- ─── Helper function (runs as table owner, bypasses RLS) ──────────
create or replace function public.is_admin()
returns boolean as $$
  select coalesce(
    (select is_admin from public.users where id = auth.uid()),
    false
  );
$$ language sql security definer stable;

-- ─── Drop the recursive policies ─────────────────────────────────
drop policy if exists "Admins can view all users"        on public.users;
drop policy if exists "Admins can view all entries"      on public.entries;
drop policy if exists "Admins can view all reflections"  on public.weekly_reflections;

-- ─── Recreate using the safe helper ──────────────────────────────
create policy "Admins can view all users"
  on public.users for select
  using (public.is_admin());

create policy "Admins can view all entries"
  on public.entries for select
  using (public.is_admin());

create policy "Admins can view all reflections"
  on public.weekly_reflections for select
  using (public.is_admin());
