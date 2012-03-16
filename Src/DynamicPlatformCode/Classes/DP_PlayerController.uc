class DP_PlayerController extends UDKPlayerController;

var DP_GameType objGI;

exec function StartWriteSignals(string strFileName)
{
	local DP_GameType refGI;
	if (strFileName != "")
	{
		refGI = DP_GameType(WorldInfo.Game);
		if (refGI != none)
			refGI.objDPSignals.objWA.AddFile(strFileName);
	}
}

exec function StopWriteSignals(string strFileName)
{
	local DP_GameType refGI;
	if (strFileName != "")
	{
		refGI = DP_GameType(WorldInfo.Game);
		if (refGI != none)
		{
			refGI.objDPSignals.objWA.RemoveFile(strFileName);
			refGI.objDPSignals.objWA.FlushData(strFileName);
		}
	}
}

DefaultProperties
{
}
