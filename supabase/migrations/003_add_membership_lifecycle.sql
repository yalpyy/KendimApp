-- Migration 003: Add membership lifecycle columns
--
-- Extends the users table to support membership states:
--   - free (is_premium = false)
--   - premium (is_premium = true AND premium_expires_at > now())
--   - expired (is_premium = true AND premium_expires_at <= now())
--
-- Also adds premium_started_at for tracking subscription history.
-- Non-destructive: all new columns have safe defaults.

-- ─── New columns ──────────────────────────────────────

-- When the current premium subscription expires (null = lifetime/no expiry)
alter table public.users
  add column if not exists premium_expires_at timestamptz;

-- When the user first became premium
alter table public.users
  add column if not exists premium_started_at timestamptz;

-- ─── Helper function: get membership status ───────────
-- Returns 'free', 'premium', or 'expired' for a given user row.
-- Can be used in queries: SELECT get_membership_status(premium_expires_at, is_premium)

create or replace function public.get_membership_status(
  p_is_premium boolean,
  p_premium_expires_at timestamptz
)
returns text as $$
begin
  if not p_is_premium then
    return 'free';
  end if;

  -- premium with no expiry = lifetime premium
  if p_premium_expires_at is null then
    return 'premium';
  end if;

  if p_premium_expires_at > now() then
    return 'premium';
  else
    return 'expired';
  end if;
end;
$$ language plpgsql immutable;

-- ─── Index for membership queries ─────────────────────
create index if not exists idx_users_premium_expiry
  on public.users (is_premium, premium_expires_at)
  where is_premium = true;
