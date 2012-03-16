class Gorod_GameSettingsSC extends UDKGameSettingsCommon;

`include(Gorod_OnlineConstants.uci)

/**
 * Название сервера
 */
var databinding string ServerName;



DefaultProperties
{
	NumPublicConnections=16
	NumPrivateConnections=0
	

	Properties(0)=(PropertyId=GOROD_PROPERTY_SERVERNAME,Data=(Type=SDT_String),AdvertisementType=ODAT_OnlineService)
	PropertyMappings(0)=(Id=GOROD_PROPERTY_SERVERNAME,Name="Gorod_ServerNameTestDinar")
}