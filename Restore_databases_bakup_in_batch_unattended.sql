Step-1: Enable / Configure extebded SP.

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1;
GO
-- To update the currently configured value for advanced options.
RECONFIGURE;
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1;
GO
-- To update the currently configured value for this feature.
RECONFIGURE;
GO

*******************************************************

Step-2

DECLARE @BacukupsSourceFolder nvarchar(100) ='C:\Users\DemoUser\Documents\Databases\'
DECLARE @RestoreToDestinationFolder varchar(1000)='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\'

DECLARE @FilesCmdshell TABLE (
outputCmd NVARCHAR (255)
)
DECLARE @FilesCmdshellCursor CURSOR
DECLARE @FilesCmdshellOutputCmd AS NVARCHAR(255)

DECLARE @cmdShellParam varchar(100)= 'dir /B ' + @BacukupsSourceFolder + '*.bak'
INSERT INTO @FilesCmdshell (outputCmd) EXEC master.sys.xp_cmdshell @cmdShellParam
SET @FilesCmdshellCursor = CURSOR FOR SELECT outputCmd FROM @FilesCmdshell

OPEN @FilesCmdshellCursor
FETCH NEXT FROM @FilesCmdshellCursor INTO @FilesCmdshellOutputCmd
WHILE @@FETCH_STATUS = 0
BEGIN

-- Get DB name without date postfix
DECLARE @SearchedCharIndex int
DECLARE @DbNameWithoutDatePostFix varchar(1000)
DECLARE @FileFullNameWithOutExt varchar(1000) = SUBSTRING(@FilesCmdshellOutputCmd, 0, CHARINDEX('.', @FilesCmdshellOutputCmd))
SET @SearchedCharIndex=CHARINDEX('_', REVERSE(N''+ @FileFullNameWithOutExt ))-1
SET @DbNameWithoutDatePostFix=SUBSTRING(N''+ @FileFullNameWithOutExt,0,LEN(N''+ @FileFullNameWithOutExt)- @SearchedCharIndex)

--***WARNING: @DbNameWithoutDatePostFix is only required in case you need to remove some postfix value from file name which is usually added due to naming a backup file while its not part of database name.

DECLARE @sqlRestore NVARCHAR(MAX) = 'RESTORE DATABASE [' + @FileFullNameWithOutExt +'] FROM DISK = N'''+ @BacukupsSourceFolder + @FileFullNameWithOutExt + '.bak'' WITH FILE = 1, MOVE N''' + @DbNameWithoutDatePostFix + ''' TO N'''+@RestoreToDestinationFolder + @FileFullNameWithOutExt + '.mdf'', MOVE N''' + @FileFullNameWithOutExt + '_log'' TO N'''+@RestoreToDestinationFolder  + @FileFullNameWithOutExt + '_log.ldf'', NOUNLOAD, STATS = 10'
--Print(@sqlRestore)
EXEC(@sqlRestore)

FETCH NEXT FROM @FilesCmdshellCursor INTO @FilesCmdshellOutputCmd
END


**********************
