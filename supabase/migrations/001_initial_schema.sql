-- Kendin App — Initial Database Schema
-- Run this in Supabase SQL Editor or as a migration.

-- ─── Users table ────────────────────────────────────
-- Extends Supabase auth.users with app-specific fields.
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  is_premium boolean not null default false,
  premium_miss_tokens integer not null default 3,
  premium_tokens_reset_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- ─── Entries table ──────────────────────────────────
-- Daily journal entries. One per day per user.
create table if not exists public.entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  text text not null check (char_length(text) >= 1 and char_length(text) <= 2000),
  created_at timestamptz not null default now()
);

-- Ensure one entry per user per calendar day.
create unique index if not exists idx_entries_user_day
  on public.entries (user_id, (created_at::date));

-- Index for week queries.
create index if not exists idx_entries_user_created
  on public.entries (user_id, created_at);

-- ─── Weekly Reflections table ───────────────────────
create table if not exists public.weekly_reflections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  week_start_date date not null,
  content text not null,
  is_archived boolean not null default false,
  created_at timestamptz not null default now()
);

-- One reflection per user per week.
create unique index if not exists idx_reflections_user_week
  on public.weekly_reflections (user_id, week_start_date);

-- ─── Row Level Security ─────────────────────────────

alter table public.users enable row level security;
alter table public.entries enable row level security;
alter table public.weekly_reflections enable row level security;

-- Users: can only read/update their own row.
create policy "Users can view own profile"
  on public.users for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.users for update
  using (auth.uid() = id);

-- Entries: users can CRUD their own entries.
create policy "Users can view own entries"
  on public.entries for select
  using (auth.uid() = user_id);

create policy "Users can create own entries"
  on public.entries for insert
  with check (auth.uid() = user_id);

create policy "Users can update own entries"
  on public.entries for update
  using (auth.uid() = user_id);

create policy "Users can delete own entries"
  on public.entries for delete
  using (auth.uid() = user_id);

-- Weekly reflections: users can read their own; inserts via edge function.
create policy "Users can view own reflections"
  on public.weekly_reflections for select
  using (auth.uid() = user_id);

create policy "Users can update own reflections"
  on public.weekly_reflections for update
  using (auth.uid() = user_id);

-- Service role can insert reflections (edge function).
create policy "Service can insert reflections"
  on public.weekly_reflections for insert
  with check (true);

-- ─── Auto-create user row on signup ─────────────────
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id)
  values (new.id);
  return new;
end;
$$ language plpgsql security definer;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ─── Monthly token reset function ───────────────────
-- Call this via a Supabase cron job on the 1st of each month.
create or replace function public.reset_monthly_miss_tokens()
returns void as $$
begin
  update public.users
  set premium_miss_tokens = 3,
      premium_tokens_reset_at = now(),
      updated_at = now()
  where is_premium = true;
end;
$$ language plpgsql security definer;
