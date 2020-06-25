
use master
go

create or alter procedure dbo.spGetProcStats (
 @procName varchar(256)
) as
begin
	select 
		DB_NAME(ps.database_id) as DbName
	  , OBJECT_NAME(ps.object_id, ps.database_id) as ObjectName
	  , ps.cached_time
	  , ps.last_execution_time
	  , ps.execution_count
	  , ( ps.total_elapsed_time / ps.execution_count ) / 1000 as AvgElapsedTimeMs
	  , ps.min_elapsed_time / 1000 as MinElapsedTimeMs
	  , ps.max_elapsed_time / 1000 as MaxElapsedTimeMs
	  , ( ps.total_logical_reads / ps.execution_count ) as AvgLogicalReads
	  , ps.last_logical_reads as LastLogicalReads
	  , ps.min_logical_reads as MinLogicalReads
	  , ps.max_logical_reads as MaxLogicalReads
	  , qp.query_plan
	  , ps.sql_handle
	  , ps.plan_handle
	  , st.text
	from 
		sys.dm_exec_procedure_stats ps
	  outer apply
		sys.dm_exec_query_plan(ps.plan_handle) qp
	  outer apply
		sys.dm_exec_sql_text(ps.sql_handle) st
	where object_Name(ps.object_id,ps.database_id) = @procName
end
go

