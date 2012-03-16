class Gorod_DataStore_SearchSC extends UDKDataStore_GameSearchBase;

DefaultProperties
{
	Tag=Gorod_GameSearch

	GameSearchCfgList.Empty
	GameSearchCfgList.Add((GameSearchClass=class'gorod.Gorod_GameSearchSC',DefaultGameSettingsClass=class'gorod.Gorod_GameSettingsSC',SearchResultsProviderClass=class'gorod.Gorod_UIDataProvider_SearchResult',SearchName="Gorod_GameSearchSC"))
}