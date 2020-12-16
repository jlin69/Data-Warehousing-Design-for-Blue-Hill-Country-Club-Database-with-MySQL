USE club;

## create dining summary view 
CREATE OR REPLACE VIEW dining_summary AS 
select member_number, sum(spending) as total_spending, sum(visits) as total_visits,
sum(case when service = "Brunch_Weekend" then spending end ) as brunch_spending,
sum(case when service = "Brunch_Weekend" then visits end) as brunch_visits,
sum(case when service = "Lunch" then spending end) as lunch_spending,
sum(case when service = "Lunch" then visits end) as lunch_visits,
sum(case when service = "Dinner_Weekday" then spending end) as dinner_weekday_spending,
sum(case when service = "Dinner_Weekday" then visits end) as dinner_weekday_visits,
sum(case when service = "Dinner_Weekend" then spending end) as dinner_weekend_spending,
sum(case when service = "Dinner_Weekend" then visits end) as dinner_weekend_visits,
sum(case when service = "Special" then spending end) as special_spending,
sum(case when service = "Special" then visits end) as special_visits
from (
select member_number, service, count(*) as visits, sum(total) as spending
from dining 
group by member_number, service) as dining_spending
group by member_number;

select * from dining_summary;

## create golf summary view 
CREATE OR REPLACE VIEW golf_summary AS
select member_number, sum(spending) as total_spending, sum(visits) as total_visits,
sum(case when description = "Golf_Lessons" then spending end ) as lesson_spending,
sum(case when description = "Golf_Lessons"then visits end) as lesson_visits,
sum(case when description = "Golf_Shop" then spending end) as shop_spending,
sum(case when description = "Golf_Shop" then visits end) as shop_visits,
sum(case when description = "Green_Fee"  then spending end) as green_fee_spending,
sum(case when description = "Green_Fee"  then visits end) as green_fee_visits
from (
select member_number, description, count(*) as visits, sum(amount) as spending
from golf
group by member_number, description) as golf_spending
group by member_number;

select * from golf_summary;

## creat memebers_summary
CREATE OR REPLACE VIEW members_summary AS
SELECT memberships.member_number,COUNT(*) AS total_members 
FROM memberships
join members
on memberships.member_number = members.member_number
group by memberships.member_number;

select * from members_summary;


## create other summary view 
CREATE OR REPLACE VIEW other_summary AS
select member_number, sum(spending) as total_spending, sum(visits) as total_visits,
sum(case when description = "Rifle Club" then spending end ) as rifle_spending,
sum(case when description = "Rifle Club"then visits end) as rifle_visits,
sum(case when description = "Ski_Club" then spending end) as ski_spending,
sum(case when description = "Ski_Club" then visits end) as ski_visits,
sum(case when description = "Bridge_Tournament"  then spending end) as Bridge_spending,
sum(case when description = "Bridge_Tournament"  then visits end) as Bridgee_visits,
sum(case when description = "Speakers_Series"  then spending end) as Speakers_spending,
sum(case when description = "Speakers_Series"  then visits end) as Speakers_visits,
sum(case when description = "Special Event_Other"  then spending end) as special_spending,
sum(case when description = "Special Event_Other"  then visits end) as special_visits,
sum(case when description = "Misc"  then spending end) as Misc_spending,
sum(case when description = "Misc"  then visits end) as Misc_visits,
sum(case when description = "Education_Series"  then spending end) as education_spending,
sum(case when description = "Education_Series"  then visits end) as education_visits
from (
select member_number, description, count(*) as visits, sum(amount) as spending
from other
group by member_number, description) as other_spending
group by member_number;

select * from other_summary;


## create pool summary view 
CREATE OR REPLACE VIEW pool_summary AS
select member_number, sum(spending) as total_spending, sum(visits) as total_visits,
CASE 
        WHEN description = "Membership_Early" THEN "Early Membership"
        else  "Membership" 
END AS Membership_Type,
case when description = "Membership_Early" then 500
		  else 800 end as membership_fee,
sum(case when description = "Swim_Lessons" then visits end) as lesson_visits,
sum(case when description = "Swim_Lessons" and spending != 0 then spending end) as paid_lesson_spending,
sum(case when description = "Swim_Lessons" and spending = 0 then visits end) as free_lesson_visits,
sum(case when description = "Swim_Lessons" and spending != 0 then visits end) as paid_lesson_visits,
sum(case when description = "Swim_Team"  then spending end) as team_spending,
sum(case when description = "Swim_Team"  then visits end) as team_visits,
sum(case when description = "Private_Function"  then spending end) as private_spending,
sum(case when description = "Private_Function"  then visits end) as private_visits,
sum(case when description = "Pool_Shop"  then spending end) as shop_spending,
sum(case when description = "Pool_Shop"  then visits end) as shop_visits,
sum(case when description = "Waterpark_Trip"  then spending end) as waterpark_spending,
sum(case when description = "Waterpark_Trip"  then visits end) as waterpark_visits,
sum(case when description = "Snack_Bar"  then spending end) as snack_spending,
sum(case when description = "Snack_Bar"  then visits end) as snack_visits
from (
select member_number, description, count(*) as visits, sum(amount) as spending
from 
(select Member_Number, pool.* 
from pool
left join poolaccounts
on pool.Pool_Account = poolaccounts.Pool_Account)as pl
group by member_number, description) as pool_spending
group by member_number;

select * from pool_summary;

## Create special summary
CREATE OR REPLACE VIEW special_summary AS
SELECT SUBSTRING(Invoice_Account, 5)AS member_number, COUNT(*) AS total_sepcial_attended 
FROM special
GROUP BY SUBSTRING(Invoice_Account, 5);

select * from special_summary;

## create tennis summary view
CREATE OR REPLACE VIEW tennis_summary AS
select Member_Number, sum(spending) as total_spending, sum(visits) as total_visits,
sum(CASE WHEN Description = "Tennis_Lessons" THEN visits END )AS lesson_visits,
sum(CASE WHEN Description = "Tennis_Lessons" THEN spending END )AS lesson_spending,
sum(CASE WHEN Description = "Tennis_Camp" THEN visits END )AS camp_visits,
sum(CASE WHEN Description = "Tennis_Camp" THEN spending END )AS camp_spending,
sum(CASE WHEN Description = "Court_Fee" THEN visits END )AS court_visit,
sum(CASE WHEN Description = "Court_Fee" THEN spending END )AS court_fee
from (select Member_Number, Description, count(*) as visits,sum(Amount) as spending  from tennis
group by Member_Number, Description) as tennis_spending
group by Member_Number;
select * from tennis_summary;


## Create Data Warehouse
DROP TABLE IF EXISTS `club_membership_summary`;
CREATE TABLE  `club_membership_summary` AS
SELECT memberships.member_number, memberships.membership_type, Family_Name as family_name, year_joined, total_members,
(ifnull(dining_summary.total_spending, 0)+ifnull(golf_summary.total_spending, 0)+ifnull(other_summary.total_spending, 0)+ifnull(pool_summary.total_spending, 0)+ifnull(tennis_summary.total_spending, 0)) as total_spending,
(ifnull(dining_summary.total_visits, 0)+ifnull(golf_summary.total_visits, 0)+ifnull(other_summary.total_visits, 0)+ifnull(pool_summary.total_visits, 0)+ifnull(tennis_summary.total_visits, 0)) as total_visits,
COUNT(distinct(promoone.Date)) AS promo1,
COUNT(distinct(promotwo.member_number)) AS promo2,
dining_summary.total_spending AS dining_total_spending, dining_summary.total_visits AS  dining_total_visits,
golf_summary.total_spending AS golf_total_spending, golf_summary.total_visits AS golf_total_visits,
other_summary.total_spending AS other_total_spending, other_summary.total_visits AS other_total_visits,
pool_summary.total_spending AS pool_total_spending, pool_summary.total_visits AS pool_total_visits,
total_sepcial_attended,
tennis_summary.total_spending AS tennis_total_spending, tennis_summary.total_visits AS tennis_total_visits
from memberships
left join members_summary on memberships.member_number = members_summary.member_number
left join promoone on memberships.member_number = promoone.member_number
left join promotwo on memberships.member_number = promotwo.member_number
left join dining_summary on memberships.member_number = dining_summary.member_number
left join golf_summary on memberships.member_number = golf_summary.member_number
left join other_summary on memberships.member_number = other_summary.member_number
left join pool_summary on memberships.member_number = pool_summary.member_number
left join special_summary on memberships.member_number =special_summary.member_number
left join tennis_summary on memberships.member_number = tennis_summary.member_number
Group By memberships.member_number;
SELECT * FROM club_membership_summary;


