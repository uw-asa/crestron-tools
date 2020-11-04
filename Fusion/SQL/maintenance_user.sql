
/*
 * A specific user should be assigned to the maintenance role, to receive notifications.
 */



/*
 * Return a list of room names that don’t have a specific user assigned to the maintenance role.  
 */
SELECT RoomName
FROM CrestronFusion.dbo.CRV_Rooms
WHERE RoomID NOT IN (
	SELECT DISTINCT RoomID 
	FROM CrestronFusion.dbo.CRV_RoomPeopleRoleMap 
	WHERE RoomViewRoleID = 'MAINTENANCE' AND UserID = '0BF34A53-3DD3-438D-B88F-BEC77EAB3009' 
	)
AND Type = 'Room'
ORDER BY RoomName


/*
 * Add the specific user to the maintenance role, excluding the testing tree node
 */
INSERT INTO CrestronFusion.dbo.CRV_RoomPeopleRoleMap (RoomViewRoleID, UserID, RoomID, Created, LastModified)
SELECT
	'MAINTENANCE' AS RoomViewRoleID, 
	'0BF34A53-3DD3-438D-B88F-BEC77EAB3009' AS UserID, 
	RoomID, 
	GETDATE() AS Created,
	GETDATE() AS LastModified
FROM CrestronFusion.dbo.CRV_Rooms
WHERE RoomID NOT IN (
	SELECT DISTINCT RoomID 
	FROM CrestronFusion.dbo.CRV_RoomPeopleRoleMap 
	WHERE RoomViewRoleID = 'MAINTENANCE' AND UserID = '0BF34A53-3DD3-438D-B88F-BEC77EAB3009' 
	)
AND RoomID NOT IN (
	SELECT RoomID 
	FROM CrestronFusion.dbo.CRV_TreeRoomMap 
	WHERE TreeNodeID = '16f9984a-19bc-4e0b-aece-2cc95a6d1b4d'
	)
AND Type = 'Room' 
ORDER BY RoomName
