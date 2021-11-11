

-- Removing string after the last index of _

-- Since there is no  LastIndexOf function in SQL so, it can be done using Reverse, and Substring

DECLARE @InputString nvarchar(1000) 
SELECT @InputString = 'this_is_underscore_separated_sentence_and_I_want_to_remove_last_word_TO-BE-REMOVED'
DECLARE @IDX int

SET @IDX = CHARINDEX('_', REVERSE(N''+ @InputString ))-1
SELECT SUBSTRING(@InputString,0,LEN(@InputString)-@IDX)

-- Table example

declare @t table (TestCol varchar(1000))
INSERT into @t Values(@inputString)

SELECT SUBSTRING(TestCol,0,LEN(TestCol)-CHARINDEX('_', REVERSE(N''+ TestCol ))-1) FROM @t
