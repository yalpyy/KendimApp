-- Kendin App — Add display_name to users table
-- Run this after 001_initial_schema.sql

-- Add display_name column
alter table public.users
  add column if not exists display_name text;

-- Update the handle_new_user trigger to include display_name from metadata.
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users (id, display_name)
  values (
    new.id,
    new.raw_user_meta_data ->> 'display_name'
  );
  return new;
end;
$$ language plpgsql security definer;
