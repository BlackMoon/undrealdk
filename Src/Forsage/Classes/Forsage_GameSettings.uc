class Forsage_GameSettings extends UDKGameSettingsCommon;
`include(Forsage_OnlineConstants.uci)

/**
 * Название сервера
 */
var databinding string ServerName;



DefaultProperties
{
	NumPublicConnections=4
	NumPrivateConnections=0
	
	Properties(0)=(PropertyId=FORSAGE_PROPERTY_SERVERNAME,Data=(Type=SDT_String),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(0)=(Id=FORSAGE_PROPERTY_SERVERNAME,Name="Forsage_ServerName")

	Properties(1)=(PropertyId=FORSAGE_PROPERTY_MAPNAME,Data=(Type=SDT_String),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(1)=(Id=FORSAGE_PROPERTY_MAPNAME,Name="Forsage_MapName")
}