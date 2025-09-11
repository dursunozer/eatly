-- user_consents tablo oluşturma ve RLS politikaları

create table if not exists public.user_consents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kvkk_accepted boolean not null,
  healthdata_accepted boolean not null,
  policy_version text not null,
  accepted_at timestamptz not null default now(),
  constraint user_consents_unique_user unique(user_id)
);

alter table public.user_consents enable row level security;

-- Kullanıcılar yalnızca kendi kayıtlarını görebilsin
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'user_consents' and policyname = 'Users can view own consents'
  ) then
    create policy "Users can view own consents"
      on public.user_consents for select
      using (auth.uid() = user_id);
  end if;
end $$;

-- Kullanıcı kendi adına insert edebilsin
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'user_consents' and policyname = 'Users can insert own consents'
  ) then
    create policy "Users can insert own consents"
      on public.user_consents for insert
      with check (auth.uid() = user_id);
  end if;
end $$;

-- Kullanıcı kendi kaydını güncelleyebilsin (ör. geri çekme)
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname = 'public' and tablename = 'user_consents' and policyname = 'Users can update own consents'
  ) then
    create policy "Users can update own consents"
      on public.user_consents for update
      using (auth.uid() = user_id)
      with check (auth.uid() = user_id);
  end if;
end $$;


