
--=========================================== 
-- LAB - Analisando um Plano de Execu��o
-- @datatuning
-- https://datatuning.com.br/blog
--===========================================

USE StackOverflow2010_TDC
GO

--======= O QUE � UM PLANO DE EXECU��O? COMO USAR?

-- Exibindo o Plano de Execu��o
     -- 1� Op��o: Include Actual Execution Plan (Ctrl + M)
	 -- 2� Op��o: Display Estimated Execution Plan (Ctrl + L)
	 -- 3� Op��o: Include Live Query Statistics (A partir do SQL 2016)
	 -- 4� Op��o: set showplan_xml on \ set showplan_xml off
	 -- 5� Op��o: set showplan_text on \ set showplan_text off


select
	p.Id as PostID
,	p.CreationDate
,	t.Type
,	p.Title
from 
	dbo.Posts p inner join
	dbo.PostTypes t on p.PostTypeId = t.Id
where
	p.OwnerUserId = 2089740
and t.Type = 'Question'


-- Percebam que cada Query possui um Plano de Execu��o
select top 10 * from dbo.VoteTypes
select * from dbo.VoteTypes
select * from dbo.VoteTypes where Id = 10




--======= USANDO UM CASO REAL

use StackOverflow2010_TDC
go

-- Criando uma procedure para nosso lab
create or alter procedure dbo.GetTopPosts (
	@OwnerUserId int = null
) as
begin
	select top 10
		p.Id as PostID
	,	p.CreationDate
	,	t.Type
	,	p.Title
	from 
		dbo.Posts p inner join
		dbo.PostTypes t on p.PostTypeId = t.Id
	where
		( p.OwnerUserId = @OwnerUserId or @OwnerUserId is null)
	and t.Type = 'Question'
	order by p.ViewCount desc
end
go

/***** Est� r�pido pra voc�? *****/
exec dbo.GetTopPosts @OwnerUserId = 2089740
-- menos de 1 segundo? R�pido, certo? Vamos ver

exec master.dbo.spGetProcStats @procName = 'GetTopPosts'
-- Salvar tempos para compara��o

--
-- Fogo no parquinho. Vamos simular uma aplica��o com v�rias chamadas.
-- ostress.exe
--

-- Vamos descobrir o problema ent�o?
-- Analisando o plano de execu��o (Include Actual Execution Plan)
exec dbo.GetTopPosts @OwnerUserId = 2089740



-- OK! NON-SARGABLE
-- Vamos resolver ent�o
-- Bora rodar os testes novamente?


create or alter procedure dbo.GetTopPosts (
	@OwnerUserId int = null
) as
begin

	if @OwnerUserId is not null
	begin
		select top 10
			p.Id as PostID
		,	p.CreationDate
		,	t.Type
		,	p.Title
		from 
			dbo.Posts p inner join
			dbo.PostTypes t on p.PostTypeId = t.Id
		where
			p.OwnerUserId = @OwnerUserId
		and t.Type = 'Question'
		order by p.ViewCount desc
	end
	else
	begin
		select top 10
			p.Id as PostID
		,	p.CreationDate
		,	t.Type
		,	p.Title
		from 
			dbo.Posts p inner join
			dbo.PostTypes t on p.PostTypeId = t.Id
		where
			t.Type = 'Question'
		order by p.ViewCount desc
	end
end
go






