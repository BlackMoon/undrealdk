class DP_WriteAngles extends Actor DllBind(DP_WriteAngles);

var array<string> arrFileNames;

dllimport final function FlushData(string strFileName);
dllimport final function WriteData(string strFileName, int iRoll, int iPitch);

function AddFile(string strFileName)
{
	if (arrFileNames.Find(strFileName) == -1)
		arrFileNames.AddItem(strFileName);
}

function RemoveFile(string strFileName)
{
	arrFileNames.RemoveItem(strFileName);
}

function WriteDataForFiles(int iRoll, int iPitch)
{
	local string strFileName;
	foreach arrFileNames(strFileName)
		WriteData(strFileName, iRoll, iPitch);
}

DefaultProperties
{
}
