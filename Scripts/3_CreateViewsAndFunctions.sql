/*

You are recommended to back up your database before running this script

Script created by SQL Compare version 14.2.9.15508 from Red Gate Software Ltd at 6/29/2020 6:40:53 PM

*/
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[WCIDContentView]'
GO
CREATE VIEW [dbo].[WCIDContentView]
AS
SELECT        dbo.WCIDContent.ContentID, dbo.WCIDContent.Type, dbo.WCIDContent.Sequence, dbo.WCIDContentTranslations.Text, dbo.Languages.LanguageID, dbo.Languages.ISO639_Code, dbo.WCIDContentTranslations.linkText, 
                         dbo.WCIDContentTranslations.linkURL
FROM            dbo.Languages INNER JOIN
                         dbo.WCIDContentTranslations ON dbo.Languages.LanguageID = dbo.WCIDContentTranslations.LanguageID INNER JOIN
                         dbo.WCIDContent ON dbo.WCIDContentTranslations.ContentID = dbo.WCIDContent.ContentID
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CheckBadgeWeek]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Checks if BadgeID can be assigned for the WeekID passed in
-- =============================================
CREATE FUNCTION [dbo].[CheckBadgeWeek] 
(	
	@BadgeID tinyint,
	@WeekID smallint
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT a.BadgeID, a.WeekID
	FROM	
	(
	SELECT b.BadgeID, bw.WeekID
	FROM dbo.Badge b
	JOIN dbo.BadgeWeek bw ON bw.BadgeID = b.BadgeID

	UNION

	SELECT b.BadgeID, w.WeekID
	FROM dbo.Badge b
	CROSS JOIN dbo.[Week] w
	WHERE w.WeekID !=0 AND NOT EXISTS (SELECT * 
										FROM dbo.BadgeWeek bw
										WHERE bw.BadgeID = b.BadgeID)
	) a
	WHERE a.BadgeID = @BadgeID
	  AND a.WeekID = @WeekID
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[BadgeTranslationsView]'
GO


CREATE VIEW [dbo].[BadgeTranslationsView] 
AS 
SELECT b.BadgeID, bt.Badge, bt.Description, b.Sequence, b.ImageName, b.BadgeColor, b.MaxShown, b.Enabled,
		bt.LanguageID, l.ISO639_Code
	FROM dbo.Badge b
	JOIN dbo.BadgeTranslations bt ON b.BadgeID = bt.BadgeID
	JOIN dbo.Languages l ON bt.LanguageID = l.LanguageID
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[CheckZipCode]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Checks if a ZipCode is valid in AirNow
-- =============================================
CREATE FUNCTION [dbo].[CheckZipCode] 
(	
	@ZipCode nchar(5)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT zc.ZipCode
	FROM dbo.ZipCode zc
	WHERE zc.ZipCode = @ZipCode
)
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[IsChoiceCorrect]'
GO
-- =============================================
-- Author:		Angela Ekstrand
-- Create date: 2016-10-18
-- Description:	Retrieves flag for correct answers
-- =============================================
CREATE FUNCTION [dbo].[IsChoiceCorrect] 
(	
	@ChoiceID int
)
RETURNS @tbl TABLE (IsCorrect bit)
AS
BEGIN

	INSERT INTO @tbl ( IsCorrect )
	SELECT ck.Correct AS IsCorrect
	FROM dbo.ChoicesKey ck
	WHERE ck.ChoiceID = @ChoiceID

	INSERT INTO @tbl ( IsCorrect )
	SELECT 0 AS IsCorrect
	WHERE NOT EXISTS (SELECT ck.Correct
						FROM dbo.ChoicesKey ck
						WHERE ck.ChoiceID = @ChoiceID)

	RETURN

END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SurveyTranslationsView]'
GO
CREATE VIEW [dbo].[SurveyTranslationsView] 
AS 
SELECT s.SurveyID, s.TypeID, s.Image, s.Calendar, s.IsYesNo,
		st.Survey, st.LanguageID, l.ISO639_Code
FROM dbo.Survey s
JOIN dbo.SurveyTranslations st ON s.SurveyID = st.SurveyID
JOIN dbo.Languages l ON st.LanguageID = l.LanguageID
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[QuestionsTranslationsView]'
GO
CREATE VIEW [dbo].[QuestionsTranslationsView]
AS
SELECT q.QuestionID, q.MultiChoice, q.CorrectAnswer, q.SurveyID, q.[Sequence], q.Slider, q.Summary,
		qt.Question, qt.Answer,
		qt.LanguageID, l.ISO639_Code
FROM dbo.Questions q
JOIN dbo.QuestionsTranslations qt ON q.QuestionID = qt.QuestionID
JOIN dbo.Languages l ON qt.LanguageID = l.LanguageID
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[ChoicesTranslationsView]'
GO
CREATE VIEW [dbo].[ChoicesTranslationsView]
AS
SELECT c.ChoiceID, c.QuestionID, c.[Sequence], c.FreeResponse, c.Calendar,
		ct.Choice, ct.LanguageID, l.ISO639_Code
FROM dbo.Choices c
JOIN dbo.ChoicesTranslations ct ON c.ChoiceID = ct.ChoiceID
JOIN dbo.Languages l ON ct.LanguageID = l.LanguageID
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[SurveyTypeTranslationsView]'
GO


CREATE VIEW [dbo].[SurveyTypeTranslationsView] 
AS 
SELECT st.TypeID AS SurveyTypeID, st.Timeframe, stt.Type, stt.LanguageID, l.ISO639_Code
FROM dbo.SurveyType st
JOIN dbo.SurveyTypeTranslations stt ON st.TypeID = stt.SurveyTypeID
JOIN dbo.Languages l ON stt.LanguageID = l.LanguageID
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[Trunc]'
GO
CREATE FUNCTION [dbo].[Trunc]( @dt datetime2(2) ) 
RETURNS smalldatetime
AS 
BEGIN      
    RETURN DATEADD(dd,0,datediff(dd,0,@dt));
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[TblID]'
GO
CREATE FUNCTION [dbo].[TblID] (@tmpstr nvarchar(MAX))
   RETURNS @tbl TABLE ([PKID] [int] IDENTITY(1,1), ID bigint) AS
BEGIN

    IF @tmpstr = '' OR @tmpstr IS NULL
    BEGIN
        INSERT @tbl (ID) VALUES(NULL)
    END
    ELSE
    BEGIN
        DECLARE @startpos int,
                @endpos   int,
                @textpos  int,
                @str      nvarchar(MAX),
                @leftover nvarchar(MAX)

        SET @textpos  = 1
        SET @startpos = 0
        SET @endpos   = charindex(' ' COLLATE Slovenian_BIN2, @tmpstr)
        SET @leftover = ''

        WHILE @endpos > 0
        BEGIN
            SET @str = substring(@tmpstr, @startpos + 1, @endpos - @startpos - 1)
            IF @str <> ''
                INSERT @tbl (ID) VALUES(convert(bigint, @str))
            SET @startpos = @endpos
            SET @endpos = charindex(' ' COLLATE Slovenian_BIN2, @tmpstr, @startpos + 1)
        END

        SET @leftover = right(@tmpstr, datalength(@tmpstr) / 2 - @startpos)
   
        IF ltrim(rtrim(@leftover)) <> ''
            INSERT @tbl (ID) VALUES(convert(bigint, @leftover))
    END
   
    RETURN
   
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[TblCode]'
GO
CREATE FUNCTION [dbo].[TblCode] (@tmpstr nvarchar(MAX))
   RETURNS @tbl TABLE ([PKID] [bigint] IDENTITY(1,1), Code nvarchar(max)) AS
BEGIN

    IF @tmpstr = '' OR @tmpstr IS NULL
    BEGIN
        INSERT @tbl (Code) VALUES(NULL)
    END
    ELSE
    BEGIN
        DECLARE @startpos int,
                @endpos   int,
                @textpos  int,
                @str      nvarchar(MAX),
                @leftover nvarchar(MAX)

        SET @textpos  = 1
        SET @startpos = 0
        SET @endpos   = charindex(' ' COLLATE Slovenian_BIN2, @tmpstr)
        SET @leftover = ''

        WHILE @endpos > 0
        BEGIN
            SET @str = substring(@tmpstr, @startpos + 1, @endpos - @startpos - 1)
            IF @str <> ''
                INSERT @tbl (Code) VALUES (@str)
            SET @startpos = @endpos
            SET @endpos = charindex(' ' COLLATE Slovenian_BIN2, @tmpstr, @startpos + 1)
        END

        SET @leftover = right(@tmpstr, datalength(@tmpstr) / 2 - @startpos)
   
        IF ltrim(rtrim(@leftover)) <> ''
            INSERT @tbl (Code) VALUES (@leftover)
    END
   
    RETURN
   
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[TruncToHour]'
GO
CREATE FUNCTION [dbo].[TruncToHour]( @dt datetime2(2), @HourAdd int = 0 ) 
RETURNS smalldatetime
AS 
BEGIN
    RETURN DATEADD(hh,DATEPART(hh,@dt)+@HourAdd,DATEADD(dd,0,datediff(dd,0,@dt)));
END

GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
PRINT N'Creating [dbo].[TruncToMin]'
GO
-- =============================================
-- Author:		Eric Gray
-- Create date: 
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[TruncToMin]( @dt datetime2(2), @AvgInMin tinyint) 
RETURNS datetime2(2)
AS 
BEGIN
	RETURN CASE WHEN @AvgInMin = 0 
	            --THEN @DT 
				THEN DATEADD(s,-DATEPART(s,@DT),@DT)
	            --ELSE DATEADD(mi,((DATEPART(mi, @DT)/@AvgInMin)*@AvgInMin)-DATEPART(mi, @DT), @DT)
				ELSE DATEADD(s,-DATEPART(s,@DT),DATEADD(mi,((DATEPART(mi, @DT)/@AvgInMin)*@AvgInMin)-DATEPART(mi, @DT), @DT))
	       END;
END
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
COMMIT TRANSACTION
GO
IF @@ERROR <> 0 SET NOEXEC ON
GO
-- This statement writes to the SQL Server Log so SQL Monitor can show this deployment.
IF HAS_PERMS_BY_NAME(N'sys.xp_logevent', N'OBJECT', N'EXECUTE') = 1
BEGIN
    DECLARE @databaseName AS nvarchar(2048), @eventMessage AS nvarchar(2048)
    SET @databaseName = REPLACE(REPLACE(DB_NAME(), N'\', N'\\'), N'"', N'\"')
    SET @eventMessage = N'Redgate SQL Compare: { "deployment": { "description": "Redgate SQL Compare deployed to ' + @databaseName + N'", "database": "' + @databaseName + N'" }}'
    EXECUTE sys.xp_logevent 55000, @eventMessage
END
GO
DECLARE @Success AS BIT
SET @Success = 1
SET NOEXEC OFF
IF (@Success = 1) PRINT 'The database update succeeded'
ELSE BEGIN
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	PRINT 'The database update failed'
END
GO
