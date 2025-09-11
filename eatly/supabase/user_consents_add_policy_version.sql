-- Var olan tabloda policy_version sütunu yoksa ekleyin ve geçici default atayın
do $$ begin
  if not exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'user_consents' and column_name = 'policy_version'
  ) then
    alter table public.user_consents add column policy_version text not null default '1.0.0';
    alter table public.user_consents alter column policy_version drop default;
  end if;
end $$;


