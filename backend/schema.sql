-- Run in the Supabase SQL editor. Creates tables, RLS, an auto-profile trigger,
-- and the atomic XP RPC.

-- ---------- profiles ----------
create table if not exists public.profiles (
    id    uuid primary key references auth.users (id) on delete cascade,
    xp    integer not null default 0,
    level integer not null default 1
);

-- Auto-create a profile row when a user signs up.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
    insert into public.profiles (id) values (new.id) on conflict (id) do nothing;
    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute function public.handle_new_user();

-- ---------- recipes ----------
create table if not exists public.recipes (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references auth.users (id) on delete cascade,
    dish       jsonb not null,
    bookmarked boolean not null default false,
    status     text not null default 'saved' check (status in ('saved', 'completed')),
    created_at timestamptz not null default now()
);
create index if not exists recipes_user_idx on public.recipes (user_id, created_at desc);

-- ---------- chat_messages ----------
create table if not exists public.chat_messages (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references auth.users (id) on delete cascade,
    session_id text not null,
    role       text not null check (role in ('user', 'assistant')),
    content    text not null,
    created_at timestamptz not null default now()
);
create index if not exists chat_session_idx
    on public.chat_messages (user_id, session_id, created_at);

-- ---------- meal_plans ----------
create table if not exists public.meal_plans (
    id         uuid primary key default gen_random_uuid(),
    user_id    uuid not null references auth.users (id) on delete cascade,
    plan_date  date not null,
    slot       text not null check (slot in ('breakfast', 'lunch', 'dinner', 'snack')),
    recipe_id  uuid not null references public.recipes (id) on delete cascade,
    created_at timestamptz not null default now(),
    unique (user_id, plan_date, slot)
);
create index if not exists meal_plans_user_date_idx
    on public.meal_plans (user_id, plan_date);

-- ---------- atomic XP increment ----------
create or replace function public.increment_xp(p_user_id uuid, p_amount integer)
returns table (xp integer, level integer)
language plpgsql security definer set search_path = public as $$
begin
    return query
    update public.profiles
       set xp    = profiles.xp + p_amount,
           level = floor((profiles.xp + p_amount) / 100) + 1
     where id = p_user_id
    returning profiles.xp, profiles.level;
end;
$$;

-- ---------- Row Level Security ----------
alter table public.profiles      enable row level security;
alter table public.recipes       enable row level security;
alter table public.chat_messages enable row level security;
alter table public.meal_plans    enable row level security;

drop policy if exists "own profile"  on public.profiles;
create policy "own profile"  on public.profiles
    for select using (auth.uid() = id);
drop policy if exists "own recipes"  on public.recipes;
create policy "own recipes"  on public.recipes
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own messages" on public.chat_messages;
create policy "own messages" on public.chat_messages
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
drop policy if exists "own meal plans" on public.meal_plans;
create policy "own meal plans" on public.meal_plans
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
