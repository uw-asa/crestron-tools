/*
 * Purge old logs that can grow very large
 */


DELETE
FROM CrestronFusion.dbo.CRV_UsageLog
WHERE LogTimeStamp < DATEADD(month, -24, GETUTCDATE())

DELETE
FROM CrestronFusion.dbo.CRV_AttributeLog
WHERE LogTimeStamp < DATEADD(month, -9, GETUTCDATE())

DELETE
FROM CrestronFusion.dbo.CRV_SignalLog
WHERE LogTimeStamp < DATEADD(month, -9, GETUTCDATE())