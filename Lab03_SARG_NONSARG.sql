--=========================================== 
-- LAB 03 - SARG vs NONSARG
-- @datatuning
-- https://datatuning.com.br/blog
--===========================================

USE StackOverflow2010_TDC
GO

--======= TRATAMENTOS COM DATA

set statistics io, time on

-- NON-SARG
SELECT
	p.Id as PostID
,	p.CreationDate
,	p.Title
FROM 
	dbo.Posts p
WHERE 
	DATEPART(year, p.CreationDate) = 2008
and DATEPART(month, p.CreationDate) = 08

-- Table 'Posts'. Scan count 5, logical reads 20561
--  SQL Server Execution Times:
--   CPU time = 813 ms,  elapsed time = 267 ms.

-- SARG
SELECT
	p.Id as PostID
,	p.CreationDate
,	p.Title
FROM
	dbo.Posts p
WHERE
	p.CreationDate between '2008-08-01' and '2008-08-31'

-- Table 'Posts'. Scan count 1, logical reads 84
--  SQL Server Execution Times:
--   CPU time = 0 ms,  elapsed time = 143 ms.



--======= CAST \ CONVERT

-- NON-SARG
declare @paramData varchar(10) = '2008-07-31'
select top 10 
	*
from 
	dbo.Posts
where
	CONVERT(varchar(10), CreationDate) = @paramData
go

-- SARG
declare @paramData varchar(10) = '2008-07-31'
select top 10 
	*
from 
	dbo.Posts
where
	CreationDate = convert(date, @paramData)



--======= Strings e Funções

-- NON-SARG
select top 10
	*
from 
	dbo.Posts
where
	replace(Title,'?','') = 'Convert Decimal to Double'

-- Colunas Computadas
alter table dbo.Posts add TitleReplace as replace(Title,'?','')
create nonclustered index IX_Posts_TitleReplace on dbo.Posts (TitleReplace)
-- drop index dbo.Posts.IX_Posts_TitleReplace 
-- alter table dbo.Posts drop column TitleReplace 

-- SARG
select top 10
	*
from 
	dbo.Posts
where
	TitleReplace = 'Convert Decimal to Double'



--======= Strings e Like

-- NON-SARG
select top 10
	*
from 
	dbo.Posts
where
	Title like '%Convert%'

-- SARG
select top 10
	*
from 
	dbo.Posts
where
	Title like 'Convert%'
	


--======= Conversão implícita (CUIDADO COM ORM)
-- Quem quiser, assista esse Metuup:
-- https://www.youtube.com/watch?v=is_H6FXT4uY&t=85s

DECLARE @FlatFileIDs as table (
	ID varchar(9)
)
insert into @FlatFileIDs values ('000000011')
insert into @FlatFileIDs values ('000000004')
insert into @FlatFileIDs values ('000000017')
insert into @FlatFileIDs values ('012496684')
insert into @FlatFileIDs values ('012496711')
insert into @FlatFileIDs values ('012496709')
insert into @FlatFileIDs values ('012481415')

-- NON-SARG
SELECT *
FROM 
	dbo.Posts p inner join
	@FlatFileIDs f on p.Id = convert(int, f.ID)
go

-- SARG
DECLARE @FlatFileIDs as table (
	ID int
)
insert into @FlatFileIDs values (convert(int, '000000011'))
insert into @FlatFileIDs values (convert(int, '000000004'))
insert into @FlatFileIDs values (convert(int, '000000017'))
insert into @FlatFileIDs values (convert(int, '012496684'))
insert into @FlatFileIDs values (convert(int, '012496711'))
insert into @FlatFileIDs values (convert(int, '012496709'))
insert into @FlatFileIDs values (convert(int, '012481415'))

SELECT *
FROM 
	dbo.Posts p inner join
	@FlatFileIDs f on p.Id = f.ID



--======= Conector OR
set statistics io, time on

-- NON-SARG
select top 10 * 
from dbo.Posts
where CreationDate = '2009-02-10'
or Id between 530614 and 530614

order by Id

-- NON-SARG???
select top 10 * 
from dbo.Posts
where CreationDate = '2009-02-10'
or Id between 530614 and 530614
--order by Id

-- NON SARG?? Depende muito. O SQL consegue, dependendo da situação criar N predicates, mas é bom evitar a utilização de OR.


-- SARG
select top 10 * 
from (
	select * 
	from dbo.Posts
	where CreationDate = '2009-02-10'
	
	union
	
	select * 
	from dbo.Posts
	where Id between 530614 and 530614
	
	union
	
	select * 
	from dbo.Posts
	where AnswerQuality = 5
) a
order by Id

