-- Device tokens for push notifications (FCM / APNs)
create table if not exists device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  token text not null,
  platform text not null default 'ios', -- 'ios' or 'android'
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, token)
);

-- Index for fast lookups by user_id
create index if not exists idx_device_tokens_user_id on device_tokens(user_id);

-- RLS
alter table device_tokens enable row level security;

-- Users can manage their own tokens
create policy "Users can insert own tokens"
  on device_tokens for insert
  with check (auth.uid() = user_id);

create policy "Users can view own tokens"
  on device_tokens for select
  using (auth.uid() = user_id);

create policy "Users can delete own tokens"
  on device_tokens for delete
  using (auth.uid() = user_id);

create policy "Users can update own tokens"
  on device_tokens for update
  using (auth.uid() = user_id);

-- Admins can read all tokens (for broadcast push)
create policy "Admins can read all tokens"
  on device_tokens for select
  using (
    exists (
      select 1 from users
      where users.id = auth.uid()
      and users.is_admin = true
    )
  );
