-- Migration: Add is_admin and display_name columns to users table
-- These columns support the admin panel and user display features.

-- Add display_name column
alter table public.users
  add column if not exists display_name text;

-- Add is_admin column (default false)
alter table public.users
  add column if not exists is_admin boolean not null default false;

-- ─── Admin RLS policies ──────────────────────────────
-- Admin users can read all rows in users, entries, weekly_reflections.

create policy "Admins can view all users"
  on public.users for select
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.is_admin = true
    )
  );

create policy "Admins can view all entries"
  on public.entries for select
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.is_admin = true
    )
  );

create policy "Admins can view all reflections"
  on public.weekly_reflections for select
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid() and u.is_admin = true
    )
  );

-- Users can insert their own row (needed for auto-upsert in auth_datasource)
create policy "Users can insert own profile"
  on public.users for insert
  with check (auth.uid() = id);

-- Users can delete own data (needed for account deletion)
create policy "Users can delete own profile"
  on public.users for delete
  using (auth.uid() = id);

create policy "Users can delete own reflections"
  on public.weekly_reflections for delete
  using (auth.uid() = user_id);
