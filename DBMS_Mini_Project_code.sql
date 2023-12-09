
-- USE IPL DATABASE
USE ipl;

-- Read & Understand the data in all the tables in the database
Select * from ipl_bidder_details;
Select * from ipl_bidder_points;
Select * from ipl_bidding_details;
Select * from ipl_match;
Select * from ipl_match_schedule;
Select * from ipl_player;
Select * from ipl_stadium;
Select * from ipl_team;
Select * from ipl_team_players;
Select * from ipl_team_standings;
Select * from ipl_tournament;
Select * from ipl_user;

# 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.

select a.bidder_id as `Bidder ID` , a.bidder_name as `Bidder Name` , 
( select count(*) 
from ipl_bidding_details b 
where b.bid_status = 'won' 
and a.bidder_id = b.bidder_id ) / 
( select no_of_bids 
from ipl_bidder_points c 
where c.bidder_id = a.bidder_id ) * 100 as 'Percentage of Wins (%)'
from ipl_bidder_details a
order by 3 desc;

# 2.	Display the number of matches conducted at each stadium with the stadium name and city.

Select count(MATCH_ID) `Number Of Matches` , ms.STADIUM_ID as `Stadium ID` , s.STADIUM_NAME as `Stadium Name` , s.CITY as City
from ipl_match_schedule as ms
join ipl_stadium as s
on ms.STADIUM_ID = s.STADIUM_ID 
group by ms.STADIUM_ID ;

# 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?

select stadium_id as `Stadium ID` , stadium_name as `Stadium Name` ,
( select count(*) 
from ipl_match m 
join ipl_match_schedule ms 
on m.match_id = ms.match_id
where ms.stadium_id = s.stadium_id 
and ( toss_winner = match_winner ) ) /
( select count(*) 
from ipl_match_schedule ms 
where ms.stadium_id = s.stadium_id ) * 100 
as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;

# 4.	Show the total bids along with the bid team and team name.

select BID_TEAM as `Bid Team` , Team_name as `Team Name` , count(bidder_id) as `Bid Count`
from ipl_bidding_details bd
join ipl_team t
on bd.BID_TEAM = t.team_id
group by bid_team;

# 5.	Show the team id who won the match as per the win details.

select win_details as `Win Details` , match_winner as `Match Winner` 
from ipl_match
group by win_details;

# 6.	Display total matches played, total matches won and total matches lost by the team along with its team name.

select its.team_id as `Team ID` , it.team_name `Team Name` , 
sum(MATCHES_PLAYED) as `Total Matches Played` ,
sum(MATCHES_WON) as `Total Matches Won` ,
sum(MATCHES_LOST) as `Total Matches Lost`
from ipl_team_standings as its
join ipl_team as it 
on its.team_id = it.team_id
group by its.team_ID;

# 7.	Display the bowlers for the Mumbai Indians team.

SELECT player_name as `Player Name`
FROM ipl_team_players i1
JOIN ipl_team i2 
ON i1.team_id = i2.team_id
JOIN ipl_player i3 
ON i1.player_id = i3.player_id
WHERE i1.player_role = 'Bowler'
AND i2.team_name = 'Mumbai Indians';

# 8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.

SELECT COUNT(*) AS 'Count Of All Rounders',
i1.team_id AS `Team ID` , i2.team_name as `Team Name`
FROM ipl_team_players i1
JOIN ipl_team i2 
ON i1.team_id = i2.team_id
JOIN ipl_player i3 
ON i1.player_id = i3.player_id
WHERE i1.player_role = 'All-Rounder'
GROUP BY i1.team_id
HAVING COUNT(*) > 4
ORDER BY COUNT(*) DESC;

# 9.	 Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in 
#        M. Chinnaswamy Stadium bidding year-wise. Note the total bidders’ points in descending order and the year is bidding year.
#        Display columns: bidding status, bid date as year, total bidder’s points.

select bd.BID_STATUS as `Bid Status` , bp.TOTAL_POINTS as `Total Points` , year(bd.BID_DATE) as `Year of Bidding`
from ipl_match_schedule ms
join ipl_match m
on ms.MATCH_ID=m.MATCH_ID
join ipl_bidding_details bd
on ms.SCHEDULE_ID = bd.SCHEDULE_ID
join ipl_bidder_points bp
on bd.BIDDER_ID = bp.BIDDER_ID
where ms.STADIUM_ID = 7 and m.TEAM_ID1 = 1 and m.MATCH_WINNER = 1
UNION ALL
select bd.BID_STATUS, bp.TOTAL_POINTS, year(bd.BID_DATE)
from ipl_match_schedule ms
join ipl_match m
on ms.MATCH_ID=m.MATCH_ID
join ipl_bidding_details bd
on ms.SCHEDULE_ID = bd.SCHEDULE_ID
join ipl_bidder_points bp
on bd.BIDDER_ID = bp.BIDDER_ID
where ms.STADIUM_ID = 7 and m.TEAM_ID2 = 1 and m.MATCH_WINNER = 2;


# 10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
-- Note :-
-- 1. use the performance_dtls column from ipl_player to get the total number of wickets
-- 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3. Do not use joins in any cases.
-- 4. Display the following columns teamn_name, player_name, and player_role.

select p.PLAYER_ID as `Player ID` , p.PLAYER_NAME as `Player Name` , tp.PLAYER_ROLE as `Player Role` , t.TEAM_NAME as `Team Name`,
CAST(SUBSTRING_INDEX(SUBSTRING_INDEX((SUBSTRING_INDEX(PERFORMANCE_DTLS,' ',3)),' ',-1), '-', -1) AS UNSIGNED) AS Wicket, 
rank() over(partition by PLAYER_ROLE ORDER BY (CAST(SUBSTRING_INDEX(SUBSTRING_INDEX((SUBSTRING_INDEX(PERFORMANCE_DTLS,' ',3)),' ',-1), '-', -1) AS UNSIGNED)) DESC) as `Rank Of Players`
from ipl_player as p
join ipl_team_players as tp
on p.PLAYER_ID = tp.PLAYER_ID
join ipl_team as t
on tp.TEAM_ID = t.TEAM_ID
where PLAYER_ROLE='All-Rounder' or player_role='bowler';

# 11.	Show the percentage of toss wins of each bidder and display the results in descending order based on the percentage

select count(*) as `Total No Of Bids`,
(select count(*)
from ipl_bidding_details as bd
join ipl_match_schedule as ms
on ms.SCHEDULE_ID = bd.schedule_id
join ipl_match as m
on m.match_id = ms.match_id
where (bd.BID_TEAM = team_id1 and toss_winner = 1) or (bd.BID_TEAM = team_id2 and toss_winner = 2)) / 
( select count(*) 
from ipl_bidding_details bd ) * 100 as 'Percentage of Toss Wins'
from ipl_bidding_details as bd;

# 12.	Find the IPL season which has min duration and max duration.
--      Output columns should be like the below:
--      Tournment_ID, Tourment_name, Duration column, Duration

select TOURNMT_ID as `Tournament ID` , TOURNMT_NAME as `Tournmane Name` , datediff(TO_DATE , FROM_DATE) as Duration
from ipl_tournament
where datediff(TO_DATE , FROM_DATE) = 
( select max(datediff(TO_DATE , FROM_DATE)) 
from ipl_tournament )
UNION ALL
select TOURNMT_ID , TOURNMT_NAME , datediff(TO_DATE , FROM_DATE) as Duration
from ipl_tournament
where datediff(TO_DATE , FROM_DATE) = 
( select min(datediff(TO_DATE , FROM_DATE)) 
from ipl_tournament ) ; 

# 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. 
-- Sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
-- Only use joins for the above query queries.

Select bd.bidder_id as `Bidder ID` , a.bidder_name as `Bidder Name` , ms.TOURNMT_ID as `Tournmanet ID` , 
day(ms.match_date) as `Bid Date` , month(ms.match_date) as `Bid Month` , year(ms.match_date) as `Bid Year` ,  bp.total_points as
`Total Points`
from ipl_bidder_points bp
join ipl_bidding_details bd
on bp.bidder_id = bd.bidder_id
join ipl_bidder_Details a
on a.bidder_id = bd.bidder_id
join ipl_match_schedule ms
on ms.schedule_id = bd.schedule_id
where bp.tournmt_id = ms.TOURNMT_ID 
order by total_points desc , `Bid Month` asc;

# 14.	Write a query for the above question using sub queries by having the same constraints as the above question.

SELECT TOTAL_POINTS 
FROM ipl_bidder_points
WHERE bidder_id IN ( SELECT bidder_id 
FROM ipl_bidding_details 
WHERE TOURNMT_ID IN ( SELECT TOURNMT_ID
FROM ipl_match_schedule 
GROUP BY MONTH(MATCH_DATE) )) ;

# 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be like:
-- Bidder Id, Ranks (optional), Total points, 
-- Highest_3_Bidders --> columns contains name of bidder, 
-- Lowest_3_Bidders  --> columns contains name of bidder;

select bd.bidder_id as `Bidder ID` , bp.total_points as `Total Points` ,
row_number() over( order by bp.TOTAL_POINTS desc) as `Rank Of Bidders`
from ipl_bidder_points as bp
join ipl_bidding_details as bd
on bp.bidder_id = bd.bidder_id
where year(bid_date) = 2018 
group by bd.bidder_id
union
select   bd.bidder_id as `Bidder ID` , bp.total_points as `Total Points` ,
row_number() over( order by bp.TOTAL_POINTS desc) as `Rank Of Bidders`
from ipl_bidder_points as bp
join ipl_bidding_details as bd
on bp.bidder_id = bd.bidder_id
where year(bid_date) = 2018 
group by bd.bidder_id;

# 16.	Create two tables called Student_details and Student_details_backup.
-- Table 1: Attributes 		Table 2: Attributes
-- Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.
-- Feel free to add more columns the above one is just an example schema.
-- Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and 
-- modifying the details of the students in the Student details table. 
-- Every time the students changed their details like mobile number, You need to update their details in the student details table.  
-- Here is one thing you should ensure whenever the new students' details come , 
-- you should also store them in the Student backup table so that if you modify the details in the student details table, 
-- you will be having the old details safely. You need not insert the records separately into both tables rather 
-- Create a trigger in such a way that It should insert the details into the Student back table 
-- when you inserted the student details into the student table automatically.

# Creating Table 1 - Student_Details
CREATE TABLE Student_Details
(
Student_ID int,
Student_Name varchar(30),
Mail_ID varchar(30),
Mobile_No bigint(15)
);

# Creating Table 2 - Student_Details_Backup
CREATE TABLE Student_Details_Backup
(
ID int,
`Name` varchar(30),
Mail varchar(30),
Mobile bigint(15)
references student(Student_ID)
);

# Creating a trigger from Table 1 to Table 2
CREATE TRIGGER AFTERINSERT AFTER INSERT
ON student_details for each row
INSERT INTO student_details_backup VALUES(new.Student_ID, new.Student_Name , new.Mail_ID , new.Mobile_No);

# Inserting Values to Original Table 1
INSERT INTO student_details VALUES 
    (1, 'ABC', 'abc@gmail.com', 1234567890),
    (2, 'DEF', 'def@gmail.com', 2345678901),
    (3, 'GHI', 'ghi@pwc.com', 3456789012),
    (4, 'JKL', 'jkl@pwc.com', 4567890123),
    (5, 'MNO', 'mno@pwc.com', 5678901234);

# Checking if values are inserted into both tables or not
SELECT * from student_details;
SELECT * from student_details_backup;


