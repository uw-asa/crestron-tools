
/*
 * Create a fake local user, that is for receiving notifications, non-domain login
 */



INSERT INTO CrestronFusion.dbo.aspnet_Users
VALUES('application-id-guid', NEWID(), 'tech_panopto', 'tech_panopto', NULL, 0, GETUTCDATE() )


INSERT INTO CrestronFusion.dbo.aspnet_Membership
VALUES (
	'application-id-guid',
	'new-guid-for-user',  
	'2abcdefghijklmnopqrstuvwxyz0123456789asbcef=', /*password hash*/
	2,
	'123456789abcdefgghijkl==', /*password salt*/
	NULL,
	'none@none.none',
	'none@none.none',
	NULL,
	NULL,
	1,
	0,
	GETUTCDATE(),
	GETUTCDATE(),
	GETUTCDATE(),
	GETUTCDATE(),
	0,
	GETUTCDATE(),
	0,
	GETUTCDATE(),
	NULL
	)

/*
 * Add user to the rooms, subscribe to alerts
 * change and enable their email
 */
