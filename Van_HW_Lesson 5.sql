-- ## DESIGN DATABASE --

-- Create research plan table --
Create table research_plan (
  plan_id int primary key generated always as identity, -- tự động tạo số thứ tự tăng dần --
  plan_name text not null,
  create_at timestamp default now()
);

-- Create interview table --
Create table interview (
  interview_id int primary key generated always as identity,
  plan_id int references research_plan(plan_id), -- references tới reseasrch plan table --
  interviewee text not null,
  content text,
  create_at timestamp default now()
);

-- Create research question table --
Create table research_question (
  research_question_id int primary key generated always as identity,
  interview_id int references interview(interview_id), -- references tới interview table --
  question text not null,
  create_at timestamp default now()
);

-- Create interview question table --
Create table interview_question (
  interview_question_id int primary key generated always as identity,
  research_question_id int references research_question(research_question_id),
  question text not null,
  create_at timestamp default now()
);

-- Bôi đen text -> run selected -> Chạy SQL từng phần
-- Bôi đen text -> check xem dùng ở những đâu

-- ## POPULATE DATA --
-- Table has no foreign keys must go first --

-- Research plan --
Insert into research_plan(plan_name) -- insert data vào table research_plan, column plan_name --
values
  ('Plan A'),
  ('Plan B'),
  ('Plan C');

-- Interview --
Insert into interview(plan_id, interviewee, content) -- insert data vào table interview, column plan_id, interviewee, content --
values
  ('1', 'Thomas', 'Tôi thấy mức giá hiện tại khá cao so với giá trị nhận được'),
  ('2', 'Nam', 'Nếu có gói rẻ hơn, tôi sẽ cân nhắc sử dụng lâu dài'),
  ('3', 'Daphne', 'Tôi thường so sánh giá với các sản phẩm khác trước khi quyết định');

-- Research question --
Insert into research_question(interview_id, question) -- insert data vào table research question, column interview_id, question --
values
  ('1', 'Người dùng đánh giá mức giá hiện tại của sản phẩm như thế nào?'),
  ('2', 'Những yếu tố nào ảnh hưởng đến quyết định chi trả của người dùng?'),
  ('3', 'Người dùng phản ứng như thế nào khi mức giá cao hơn kì vọng hoặc ngân sách');

-- Interview question --
Insert into interview_question(research_question_id, question)
values
  ('1', 'Bạn thường cân nhắc những yếu tố nào khi quyết định có trả tiền cho một sản phẩm?'),
  ('2', 'Mức giá nào khiến bạn cảm thấy đáng để trả tiền?'),
  ('3', 'Bạn sẽ làm gì nếu mức giá sản phẩm cao hơn ngân sách dự kiến của bạn?');

-- INTERATION 1: A USER PROBLEM THAT REQUIRES TABLE CHANGES --
 
-- Change the database --

-- Edit table --
/*
ALTER TABLE table_name -- ALTER: sửa cái table --
ADD COLUMN column_name = 'new value'
*/

alter table interview
add column status text
check (status in('planned','completed','cancelled')); -- check constrain: status chỉ được nhận 3 giá trị planned, completed, cancelled --

-- Update existing data --
/*
UPDATE table_name
SET column = 'value'
WHERE condition;
*/

update interview
set status = 'planned'
where interview_id = 1;

update interview
set status = 'completed'
where interview_id = 2;

update interview
set status = 'cancelled'
where interview_id = 3;

-- Show all interviews that are still planned, with their plan name --
select
  i.interview_id, -- alias table.column --
  i.status,
  rp.plan_name as "plan name" -- tên có dấu cách thì để trong "" --
from interview i
join research_plan rp
  on i.plan_id = rp.plan_id
where i.status = 'planned';

-- Show the most recently created interview --
select
  i.interview_id,
  i.create_at
from interview i
order by create_at desc
Limit 2;

-- Reflect: Why did you modify the existing table rather than drop and recreate it? What would have happened to your data if you had?
/* 1 interview có 1 status -> lưu status vào interview data object
-> chỉ cần add thêm column status thôi, nếu drop/recreate thì sẽ mất data cũ đã được insert trước đó. */

-- INTERATION 2: A USER PROBLEM THAT REQUIRES A NEW TABLE --

-- Creat a new table --
Create table highlight (
  highlight_id int primary key generated always as identity,
  interview_id int references interview(interview_id),
  quote text,
  tag text check (tag in ('pain point', 'motivation' , 'workaround')),
  create_at timestamp default now()
);

-- Populate data --
Insert into highlight(interview_id,quote,tag)
values
  ('1', 'Tôi muốn tìm một gói giá phù hợp để có thể sử dụng lâu dài', 'motivation'),
  ('2', 'Mức giá hiện tại khá cao so với ngân sách của tôi', 'pain point'),
  ('3', 'Tôi thường so sánh giá với các sản phẩm khác trước khi quyết định', 'workaround');

-- Show all highlights tagged as pain point, with the interviewee name who said them --
select
  i.interview_id,
  h.highlight_id,
  h.tag,
  i.interviewee
from interview i
join highlight h
  on i.interview_id = h.interview_id
where h.tag = 'pain point';

-- How many highlights are there per theme?
/*
SELECT column
COUNT (*) AS total
FROM table
Group by column;
*/
SELECT 
  h.tag,
COUNT (*) as total
from highlight h
group by tag;

-- Reflect: What makes this different from Iteration 1? When do you add a column vs. create a whole new table?
/* Highlight có các thuộc tính: quote, tag... -> tạo data object mới, table mới
Sự khác nhau giữa add column vs create a talbe là:
+ add column: thêm cột thông tin cho data cũ
+ create a new table: tạo data object mới và quản lý các thông tin của nó
*/