/*

You are recommended to back up your database before running this script

Script created by SQL Compare version 14.2.9.15508 from Red Gate Software Ltd at 5/27/2020 1:00:08 PM

*/
		
SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS, NOCOUNT ON
GO
SET DATEFORMAT YMD
GO
SET XACT_ABORT ON
GO
SET TRANSACTION ISOLATION LEVEL Serializable
GO
BEGIN TRANSACTION

PRINT(N'Drop constraints from [dbo].[SurveyWeek]')
ALTER TABLE [dbo].[SurveyWeek] NOCHECK CONSTRAINT [FK_SurveyWeek_Survey]
ALTER TABLE [dbo].[SurveyWeek] NOCHECK CONSTRAINT [FK_SurveyWeek_Week]

PRINT(N'Drop constraints from [dbo].[BadgeWeek]')
ALTER TABLE [dbo].[BadgeWeek] NOCHECK CONSTRAINT [FK_BadgeWeek_Badge]
ALTER TABLE [dbo].[BadgeWeek] NOCHECK CONSTRAINT [FK_BadgeWeek_Week]

PRINT(N'Add 1 row to [dbo].[BadgeWeek]')
INSERT INTO [dbo].[BadgeWeek] ([BadgeID], [WeekID]) VALUES (1, 0)

PRINT(N'Add 25 rows to [dbo].[SurveyWeek]')
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (0, 0)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (36, 18)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (37, 8)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (38, 11)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (39, 15)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (40, 5)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (41, 1)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (42, 14)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (43, 4)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (44, 19)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (45, 9)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (46, 2)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (47, 17)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (48, 7)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (49, 16)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (50, 6)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (51, 10)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (52, 3)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (53, 13)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (54, 12)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (55, 20)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (56, 21)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (57, 24)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (58, 22)
INSERT INTO [dbo].[SurveyWeek] ([SurveyID], [WeekID]) VALUES (59, 23)

PRINT(N'Add constraints to [dbo].[SurveyWeek]')
ALTER TABLE [dbo].[SurveyWeek] WITH CHECK CHECK CONSTRAINT [FK_SurveyWeek_Survey]
ALTER TABLE [dbo].[SurveyWeek] WITH CHECK CHECK CONSTRAINT [FK_SurveyWeek_Week]

PRINT(N'Add constraints to [dbo].[BadgeWeek]')
ALTER TABLE [dbo].[BadgeWeek] WITH CHECK CHECK CONSTRAINT [FK_BadgeWeek_Badge]
ALTER TABLE [dbo].[BadgeWeek] WITH CHECK CHECK CONSTRAINT [FK_BadgeWeek_Week]
COMMIT TRANSACTION
GO

