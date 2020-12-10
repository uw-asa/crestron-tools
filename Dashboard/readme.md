# UW Crestron Dashboard

UW Crestron Dashboard provides device use metrics, using Crestron Programming, Crestron Fusion, Microsoft SQL, and Tableau.

## Crestron Controller Programming

Include and program for the Crestron Fusion Device Usage Module.

Crestron Answer ID 5757 - How To Program Fusion SSI Modules for Crestron Fusion
https://support.crestron.com/app/answers/detail/a_id/5757/

Crestron Answer ID 5758 - How To Program Fusion SSI Modules for Crestron Fusion (Guided Assistance)
https://support.crestron.com/app/answers/detail/a_id/5758/

## Crestron Fusion Server Setup

This project requires SQL read access to the Fusion database.

## Microsoft SQL Setup

### Create new database ClassroomTechData 



### Create new view v_CRV_log_DeviceUsage
This view provides a filtered and condensed version of the Fusion Usage Log.
```
CREATE VIEW ClassroomTechData.dbo.v_CRV_log_DeviceUsage
AS
SELECT    CrestronFusion.dbo.CRV_UsageLog.LogID
		, CrestronFusion.dbo.CRV_UsageLog.LogTimeStamp
		, DATEADD(minute, - CrestronFusion.dbo.CRV_UsageLog.Data5, CAST(GETDATE() - GetUtcDate() + CrestronFusion.dbo.CRV_UsageLog.LogTimeStamp AS datetime)) AS Local_StartTime
		, CAST(GETDATE() - GetUtcDate() + CrestronFusion.dbo.CRV_UsageLog.LogTimeStamp AS datetime) AS Local_EndTime
		, CrestronFusion.dbo.CRV_Rooms.RoomName
		, CrestronFusion.dbo.CRV_UsageLog.Data2 AS DeviceType
		, CrestronFusion.dbo.CRV_UsageLog.Data3 AS DeviceName
		, CrestronFusion.dbo.CRV_UsageLog.Data5 AS DurationMinutes
FROM	CrestronFusion.dbo.CRV_UsageLog 
		INNER JOIN CrestronFusion.dbo.CRV_Rooms ON CrestronFusion.dbo.CRV_Rooms.RoomID = CrestronFusion.dbo.CRV_UsageLog.RoomID
WHERE	(CrestronFusion.dbo.CRV_UsageLog.DataType = 'USAGE') AND (CrestronFusion.dbo.CRV_UsageLog.Data1 = 'TIME')
```

### Create new table log_DeviceUsage
```
CREATE TABLE [dbo].[log_DeviceUsage](
	[LogID] [varchar](50) NOT NULL,
	[LogTimeStamp] [datetime] NOT NULL,
	[Local_StartTime] [datetime] NOT NULL,
	[Local_EndTime] [datetime] NOT NULL,
	[RoomName] [nvarchar](128) NOT NULL,
	[DeviceType] [nvarchar](255) NOT NULL,
	[DeviceName] [nvarchar](255) NOT NULL,
	[DurationMinutes] [int] NOT NULL
)
```

### Create 
