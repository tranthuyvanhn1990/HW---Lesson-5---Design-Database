-- 01. DESIGN DATABASE --
-- Create research plan table -
Create table research_plan (
  plan_id int primary key generated always as identity,
  plan_name text not null,
  create_at timestamp default now()
);

-- Create interview table --
Create table interview (
  interview_id int primary key generated always as identity,
  plan_id int references research_plan(plan_id),
  interviewee_name text not null,
  date date,
  content text
);

-- Create research question table --
Create table research_question (
  research_question_id int primary key generated always as identity,
  question text not null,
  create_at timestamp default now()
);
-- Add interview_id into research question table -
Alter table research_question
add column interview_id int;

Alter table research_question
add constraint fk_research_question_id
foreign key (interview_id)
references interview(interview_id);

-- Create interview question table --
Create table interview_question (
  interview_question_id int primary key generated always as identity,
  research_question_id int references research_question(research_question_id),
  question text not null,
  create_at timestamp default now()
);

-- 02. POPULATE DATABASE --
-- Research plan --
Insert into research_plan(plan_name)
values
  ('Plan A'),
  ('Plan B'),
  ('Plan C');

-- Interview ---
Insert into interview(plan_id, interviewee_name, date, content)
values
  ('1', 'Thomas', '2026-09-16', 'This is interview content from Thomas'),
  ('2', 'Nam', '2026-09-17', 'This is interview content from Nam'),
  ('3','Daphne', '2026-09-18', 'This is interview content from Daphne');

-- Research question --
Insert into research_question(question)
values
  ('Người dùng có hiểu onboarding dùng để làm gì không?'),
  ('Người dùng gặp khó khăn gì khi thực hiện onboarding?'),
  ('Người dùng cần thông tin hoặc bước nào để hoàn thành onboarding thành công?');

-- Interview question --
Insert into interview_question(research_question_id, question)
values
  ('1', 'Bạn nghĩ quy trình onboarding này giúp bạn thực hiện điều gì?'),
  ('1', 'Khi bắt đầu onboarding, bạn mong đợi điều gì sẽ xảy ra?'),
  ('2','Có điều gì về mục đích của onboarding khiến bạn cảm thấy chưa rõ ràng không?');

-- 03. INTERATION 1: USER PROBLEM THAT REQUIRES TABLE CAHNGES --
-- Change the database --
alter table interview
add column status text
  CHECK  (status IN ('planned','completed','cancelled'));

-- Update exiting rows --
update interview
  set status ='planned'
  where interview_id = 1;

update interview
  set status ='completed'
  where interview_id = 3;

update interview
  set status ='cancelled'
  where interview_id = 4;

-- Show all interviews that are still planned, with their plan name --
select
  i.interview_id,
  i.interviewee_name,
  rp.plan_name,
  i.status
from
  interview i
join research_plan rp
  on i.plan_id = rp.plan_id
where i.status = 'planned';

-- Show the most recently created interview --
select
  i.interview_id,
  i.date
from
  interview i
order by date desc
limit 2;

-- 04. INTERATION 2: A USER PROBLEM THAT REQUIRES A NEW TABALE --
-- Create tags table --
Create table highlights (
  highlight_id int primary key generated always as identity,
  interview_id int not null references interview(interview_id),
  quote text not null,
  tag text
    check (tag in('pain point', 'motivation', 'workaround')),
    create_at timestamp default now()
);

-- Populate data --
Insert into highlights(interview_id, quote, tag)
values
  ('1','Tôi thấy bước này hơi rối', 'pain point'),
  ('4','Tôi muốn nhanh chóng hoàn thành onboarding', 'motivation'),
  ('3','Tôi thoát app','workaround');

-- Show all highlights tagged as painpoint, with the interviewee name who said them --
select
  h.quote, --select column quote trong bảng highlights
  h.tag, --select column tag trong bảng hightlights
  i.interviewee_name as interviewee -- select column interview_name làm column interviewee
from
  interview i -- bắt đầu từ bảng interview
join highlights h -- nối thêm bảng highlight --
  on i.interview_id = h.interview_id -- với điều kiện interview.interview_id = highlights.interview_id --
where h.tag = 'pain point'; -- lọc ra tag = 'pain point' ---

-- How many highlights are there per theme?
select
  h.tag, count (*)
from highlights h
  group by tag;