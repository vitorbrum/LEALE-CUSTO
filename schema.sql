-- Execute no SQL Editor do Supabase num projeto novo.
-- 1) Auth > Users: crie exatamente duas contas (e-mail + senha).
-- 2) Copie os UUIDs dessas contas e execute os INSERTs ao fim deste arquivo.
-- 3) Auth > Providers > Email: desative Sign ups (cadastro público).

create table if not exists public.authorized_users (
  user_id uuid primary key references auth.users(id) on delete cascade
);
create table if not exists public.expenses (
  id uuid primary key,
  spent_on date not null,
  amount numeric(12,2) not null check (amount > 0),
  description text not null check (char_length(description) between 1 and 150),
  category text not null,
  city text not null default '',
  payment_method text not null default '',
  recurring boolean not null default false,
  notes text not null default '',
  recurrence_id uuid,
  receipt_path text,
  created_at timestamptz not null default now()
);
create index if not exists expenses_spent_on_idx on public.expenses(spent_on);
create index if not exists expenses_recurrence_idx on public.expenses(recurrence_id);

alter table public.authorized_users enable row level security;
alter table public.expenses enable row level security;
revoke all on table public.authorized_users from anon,authenticated;
revoke all on table public.expenses from anon,authenticated;
grant select on public.authorized_users to authenticated;
grant select,insert,update,delete on public.expenses to authenticated;

create policy "only_self_can_check_authorization" on public.authorized_users
for select to authenticated using (user_id = (select auth.uid()));

create policy "authorized_read_expenses" on public.expenses
for select to authenticated
using (exists (select 1 from public.authorized_users a where a.user_id=(select auth.uid())));
create policy "authorized_add_expenses" on public.expenses
for insert to authenticated
with check (exists (select 1 from public.authorized_users a where a.user_id=(select auth.uid())));
create policy "authorized_edit_expenses" on public.expenses
for update to authenticated
using (exists (select 1 from public.authorized_users a where a.user_id=(select auth.uid())))
with check (exists (select 1 from public.authorized_users a where a.user_id=(select auth.uid())));
create policy "authorized_delete_expenses" on public.expenses
for delete to authenticated
using (exists (select 1 from public.authorized_users a where a.user_id=(select auth.uid())));

-- Comprovantes ficam privados; paths: <expense-uuid>/<arquivo-uuid>.pdf ou imagem.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('receipts','receipts',false,5242880,array['image/png','image/jpeg','image/webp','application/pdf'])
on conflict (id) do update set public=false,file_size_limit=5242880,allowed_mime_types=excluded.allowed_mime_types;

create policy "authorized_read_receipts" on storage.objects
for select to authenticated
using (bucket_id='receipts' and exists(select 1 from public.authorized_users a where a.user_id=(select auth.uid()))
  and exists(select 1 from public.expenses e where e.receipt_path=name));
create policy "authorized_upload_receipts" on storage.objects
for insert to authenticated
with check (bucket_id='receipts' and exists(select 1 from public.authorized_users a where a.user_id=(select auth.uid())));
create policy "authorized_remove_receipts" on storage.objects
for delete to authenticated
using (bucket_id='receipts' and exists(select 1 from public.authorized_users a where a.user_id=(select auth.uid())));

-- IMPORTANTE: substitua e execute SOMENTE após criar as contas em Authentication > Users:
-- insert into public.authorized_users(user_id) values
-- ('UUID-DA-PRIMEIRA-CONTA'),
-- ('UUID-DA-SEGUNDA-CONTA');
