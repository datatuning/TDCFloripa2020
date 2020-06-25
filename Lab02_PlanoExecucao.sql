
--=========================================== 
-- LAB - Analisando um Plano de Execução
-- @datatuning
-- https://datatuning.com.br/blog
--===========================================

USE StackOverflow2010_TDC
GO

--======= O QUE É UM PLANO DE EXECUÇÃO? COMO USAR?

-- Exibindo o Plano de Execução
     -- 1ª Opção: Include Actual Execution Plan (Ctrl + M)
	 -- 2ª Opção: Display Estimated Execution Plan (Ctrl + L)
	 -- 3ª Opção: Include Live Query Statistics (A partir do SQL 2016)
	 -- 4ª Opção: set showplan_xml on \ set showplan_xml off
	 -- 5ª Opção: set showplan_text on \ set showplan_text off


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


-- Percebam que cada Query possui um Plano de Execução
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

/***** Está rápido pra você? *****/
exec dbo.GetTopPosts @OwnerUserId = 2089740
-- menos de 1 segundo? Rápido, certo? Vamos ver

exec master.dbo.spGetProcStats @procName = 'GetTopPosts'
-- Salvar tempos para comparação

--
-- Fogo no parquinho. Vamos simular uma aplicação com várias chamadas.
-- ostress.exe
--

-- Vamos descobrir o problema então?
-- Analisando o plano de execução (Include Actual Execution Plan)
exec dbo.GetTopPosts @OwnerUserId = 2089740



-- OK! NON-SARGABLE
-- Vamos resolver então
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






