
--=========================================== 
-- LAB 01 - Row-by-Row vs Set-Based
-- @datatuning
-- https://datatuning.com.br/blog
--===========================================

USE StackOverflow2010_TDC
GO

select top 10 * from dbo.Posts
select top 10 * from dbo.Users

--============================================================
-- Objetivo: Fechar posts com usuários com baixa reputação
--============================================================

/***** SOLUÇÃO ROW-BY-ROW *****/
begin tran

declare @IdPost int

declare cursorIdsPosts cursor for
select p.Id
from dbo.Posts p inner join
     dbo.Users u on p.OwnerUserId = u.Id
where u.Reputation = 1
and p.ClosedDate is null

open cursorIdsPosts
fetch next from cursorIdsPosts into @IdPost

while @@FETCH_STATUS = 0
begin
	update dbo.Posts set ClosedDate = GETDATE() where Id = @IdPost
	fetch next from cursorIdsPosts into @IdPost
end

rollback

close cursorIdsPosts
deallocate cursorIdsPosts


/***** SOLUÇÃO SET-BASED *****/
set nocount off

begin tran
	update p 
		set ClosedDate = GETDATE()
	from 
		dbo.Posts p inner join
		dbo.Users u on p.OwnerUserId = u.Id
	where 
		u.Reputation = 1
	and p.ClosedDate is null
rollback
