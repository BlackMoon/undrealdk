class Forsage_DataStore_GameSearch extends UDKDataStore_GameSearchBase;

DefaultProperties
{
	Tag=ForsageGameSearch

	GameSearchCfgList.Empty
	GameSearchCfgList.Add((GameSearchClass=class'Forsage.Forsage_GameSearch',DefaultGameSettingsClass=class'Forsage.Forsage_GameSettings',SearchResultsProviderClass=class'UDKBase.UDKUIDataProvider_SearchResult',SearchName="ForsageGameSearch"))
}
