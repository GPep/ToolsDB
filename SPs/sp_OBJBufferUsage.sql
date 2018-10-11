USE [Tools]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('sp_OBJBufferUsage') IS NULL
  EXEC ('CREATE PROCEDURE sp_OBJBufferUsage AS RETURN 0;')
GO

ALTER PROCEDURE sp_OBJBufferUsage @dbname NVARCHAR(50)
AS
BEGIN

SET NOCOUNT ON;

-- =============================================
-- Author:		Glenn Pepper
-- Create date: 2018-09-20
-- Version 1.0
-- Description:	this Stored Procedure finding the top objects that are using the buffer pool per database. 
-- 
-- =============================================





WITH obj_buffer AS
(
SELECT
       [Object] = o.name,
       [Type] = o.type_desc,
       [Index] = COALESCE(i.name, ''),
       [Index_Type] = i.type_desc,
       p.[object_id],
       p.index_id,
       au.allocation_unit_id
FROM
       sys.partitions AS p
       INNER JOIN sys.allocation_units AS au ON p.hobt_id = au.container_id
       INNER JOIN sys.objects AS o ON p.[object_id] = o.[object_id]
       INNER JOIN sys.indexes AS i ON o.[object_id] = i.[object_id] AND p.index_id = i.index_id
WHERE
       au.[type] IN (1,2,3) AND o.is_ms_shipped = 0
)
SELECT
       b.[database_id],
	   obj.[Object],
       obj.[Type],
       obj.[Index],
       obj.Index_Type,
       COUNT_BIG(b.page_id) AS 'buffer_pages',
       COUNT_BIG(b.page_id) / 128 AS 'buffer_mb'
FROM
       obj_buffer obj 
       INNER JOIN sys.dm_os_buffer_descriptors AS b ON obj.allocation_unit_id = b.allocation_unit_id
WHERE
       b.database_id = DB_ID(@dbName)
GROUP BY
	   B.database_id,
       obj.[Object],
       obj.[Type],
       obj.[Index],
       obj.Index_Type
ORDER BY
       buffer_pages DESC;

END

GO