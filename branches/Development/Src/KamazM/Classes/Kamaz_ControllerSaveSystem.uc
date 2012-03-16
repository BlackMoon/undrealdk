/** ����� ��� ������ � �������� � ��� ���������� ��������� */
class Kamaz_ControllerSaveSystem extends Actor;

struct UserDefProfile
{
	var string UserName;
	var string Path;

};

/** 
 *  ��������� ��� �������� ����� ������������ Windows � �� */
var  UserDefProfile winUser;

var Kamaz_PlayerController gpc;

/** 
 *  ������ �� ����� ������� �������� � �������� */
var Kamaz_ProfileMDllBinder dllb;
/** 
 *  ��� ������������ */
var string userName;
/** 
 *  ������� ������� */
var Kamaz_ProfileSettings Profile;
/** 
 *  ������� ������ � ��������� */
var Kamaz_Sapitu sapitu;

/** 
 *  ������ �������� */
var array<Kamaz_ProfileSettings> ProfArray;

/** 
 *  ������ ��������� ������� */
var int ActiveProfile;

simulated event PostBeginPlay()
{
	local array<string> Users;
	/* ������ ������� */
	local int i;
	/* �������� ������ �� ��������� sapitu */
	`log(WorldInfo.Game);

	//������� �������� ������
	dllb = new class'Kamaz_ProfileMDllBinder';
	//�������� ��� �������
	dllb.GetProfileName( winUser );
	sapitu = new class'Kamaz_Sapitu';
	if(sapitu==none)
		`warn("sapitu = none");

	//�������� ������ ���� ��������������, � ������� ���������� ������ ����� � � ��� ���� �������
	Users = sapitu.getProfiles();
	//���� �������� ��� (������ ������)
	if (Users.length == 0)
	{
		 createFirstProfile();
	}
	//��������� �������� ������� ������������
	else
	{
		for (i = 0; i < Users.length; ++i)
		{
			
			if(Users[i] == winUser.UserName)
			{
				Profile = new( none, Users[i]) class'Kamaz_ProfileSettings';
				ActiveProfile = GetActiveProfile();
				//��������� ��� ����� ����� ��������� ������� ������������
				UserName = Profile.sProf[ActiveProfile].ProfileName;
				//��������� ������������
				loadProfile(Profile.ProfileName);
				break;
			}
		}
		//���� �� ���� �����, � ������� ����, ������ � ������� ������������ ��� ���� �������, � � �������� ���
		if(Profile==none)
		{
			createFirstProfile();
		}
	}
	super.PostBeginPlay();
}

/** 
 *  ������� ������� � ���������� ����������� */
function bool createProfile(string pName, optional bool bActivate = false)
{
	//��� ������� �� ������ ���� ������
	if (len(pName) == 0)
	{
		if(gpc!=none)
			gpc.TeamMessage(none, "Profile name length mast be greather than 0 ", 'none');
		return false;
	}
	if (Profile != none)
	{
		if(gpc!=none)
			gpc.TeamMessage(none, "DisProfileding previous Profile: "$Profile.ProfileName$" (id:"$Profile.Name$")", 'none');
	}
	if(bIsProfileExist(pName))
	{
		if(gpc!=none)
			gpc.TeamMessage(none, "Profile alredy exists", 'none');
		return false;
	}
	//��������� 1 ������� � ����� �������
	Profile.sProf.Add(1);
	Profile.sProf[Profile.sProf.Length-1].ProfileName = pName;
	if(bActivate)
	{
		ChangeActiveProfile(Profile.sProf[Profile.sProf.Length-1].ProfileName);
	}
	else
	{
		Profile.sProf[Profile.sProf.Length-1].bIsActive = false;
		saveProfile();
	}
	return true;
}

/** 
 *  ������� ������ ������� ������������ */
function createFirstProfile()
{
	//���������� ��� ������� � ��������� ����������
	userName = winUser.UserName;

	Profile = sapitu.createProfile(userName);
	Profile.ProfileName = userName;
	//����� ������� �������. ��� ������ �������, ������� �� �.� ��������
	
	//��������� ��� ��������� �������
	ActiveProfile = 0;
	createProfile(userName, true);

	//����� ��������� �������
	saveProfile();

}

/**
 * ���������� ������� */
function saveProfile()
{
	if (Profile != none)
	{
		Profile.save();
	}
}

/** 
 *  �������� ������� */
function loadProfile(String ProfileId)
{
	if (len(ProfileId) == 0)
	{
			gpc.TeamMessage(none, "No Profile id given", 'none');
		return;
	}
	if (Profile != none)
	{
		if(gpc!=none)
			gpc.TeamMessage(none, "DisProfileding previous Profile: "$Profile.ProfileName$" (id:"$Profile.Name$")", 'none');
	}
	Profile = sapitu.loadProfile(ProfileId);
	if (Profile == none)
	{
		if(gpc!=none)
			gpc.TeamMessage(none, "No Profile found with id: "$ProfileId, 'none');
	}
	else {
		if(gpc!=none)
		{
			gpc.TeamMessage(none, "Profile loaded", 'none');
			showProfile();
		}
	}
}


/**
 * ���������� ��������. ������� ��� ��������
 */
exec function printProfiles()
{
	local array<string> Profiles;
	local int i;
	Profiles = sapitu.getProfiles();
	if (Profiles.length == 0)
	{
		if(gpc!=none)
			gpc.TeamMessage(none, "There are no saved Profiles", 'none');
		return;
	}
	gpc.TeamMessage(none, "The following Profile ids exist", 'none');
	for (i = 0; i < Profiles.length; ++i)
	{
		if(gpc!=none)
			gpc.TeamMessage(none, "    "$Profiles[i], 'none');
	}
}

/**
 * ������������ ��������� �������. 
 *  ���� ���������� ��� �������,
 *  ����������� ������ ��������� ������������� ������ ���� ������� �������.
 *  ����� ���������� � ���� ������� ����� ��������� �������
 *  */
function deactivateProfile()
{
	//������� �� �������
	Profile.sProf[GetActiveProfile()].bIsActive =false;
	SaveConfig();
}

/** 
 *  ���������� ������ ������� (� �������������) ��������� ������� */
function int GetActiveProfile()
{
	local int i;
	
	for (i = 0; i < Profile.sProf.length; ++i)
	{
		if(Profile.sProf[i].bIsActive)
		{
			return i;
		}
	}
	return i;
}

/** 
 *  ���������� ��� ��������� ������������*/
function string GetActiveProfileName()
{
	return Profile.sProf[GetActiveProfile()].ProfileName;
}

/** 
 *  ������ �������� ������� �� ���, ��� �������� ������� � ��������� */
function bool ChangeActiveProfile(string ProfileName)
{

	local int i;
	for(i=0; i<Profile.sProf.Length;++i)
	{
		//���� ������� �������
		if(Profile.sProf[i].ProfileName == ProfileName)
		{
			deactivateProfile();
			ActiveProfile = i;
			Profile.sProf[i].bIsActive = true;
			saveProfile();
			return true;
		}
	}
	return false;
}

/** 
 *  ������� �������, ��� �������� ������� � ��������� */
function bool DeleteProfile(string ProfileName)
{
	local int i;
	for(i=0; i<Profile.sProf.Length;++i)
	{
		//���� ������� �������
		if(Profile.sProf[i].ProfileName == ProfileName)
		{
			if(Profile.sProf[i].bIsActive!=true)
			{
				Profile.sProf.RemoveItem(Profile.sProf[i]);
				saveProfile();
				return true;
			}
			else
			{
				if(gpc!=none)
					gpc.TeamMessage(none, "Cant delete active profile", 'none');
				return false;
			}
		}
	}
	return false;
}

/** 
 *  ��������������� �������, ��� �������� ������� � ��������� */
function bool RenameProfile(string ProfileName, string newProfileName)
{
	local int i;
	if(newProfileName=="")
	{
		return false;
	}
	for(i=0; i<Profile.sProf.Length;++i)
	{
		//���� ������� �������
		if(Profile.sProf[i].ProfileName == ProfileName)
		{
			if(bIsProfileExist(newProfileName))
			{
				return false;
			}
			Profile.sProf[i].ProfileName = newProfileName;
			saveProfile();
			return true;
		}
	}
	return false;
}

////function 
///** ������������� ����� ������ */
//exec function SetProfileClass(string ProfileName, string CarClass)
//{
//	local int i;
//	for(i=0; i<Profile.sProf.Length;++i)
//	{
//		//���� ������� �������
//		if(Profile.sProf[i].ProfileName == ProfileName)
//		{
//			Profile.sProf[i].ProfileClass = CarClass;
//			saveProfile();
//			break;
//		}
//	}
//}

///** ������������� ��������� ������� ������� (���� ��� ���) */
//function bool SetProfileTransmision(string ProfileName, bool autoTransmision)
//{
//	local int i;
//	for(i=0; i<Profile.sProf.Length;++i)
//	{
//		//���� ������� �������
//		if(Profile.sProf[i].ProfileName == ProfileName)
//		{
//			Profile.sProf[i].autoTransmision = autoTransmision;
//			saveProfile();
//			return true;
//		}
//	}
//	return false;
//}

///** ���������� ��������� ������� ������� (���� ��� ���) */
//function bool GetProfileTransmision(string ProfileName)
//{
//	local int i;
//	for(i=0; i<Profile.sProf.Length;++i)
//	{
//		//���� ������� �������
//		if(Profile.sProf[i].ProfileName == ProfileName)
//		{
//			return Profile.sProf[i].autoTransmision;
//		}
//	}
//}

/** 
 *  ���������� true, ���� ������� � ������, ��������� � ��������� ����������. ����� false */
function bool bIsProfileExist(string pName)
{
	local int i;
	for(i=0; i<Profile.sProf.Length;++i)
	{
		//���� ������� �������
		if(Profile.sProf[i].ProfileName == pName)
		{
			//����� ������� ��� ����������
			return true;
		}
	}
	return false;
}

/** 
 *  ������� ����� ������� ��� �������� ������� � ���������� ��� ID */
function string CreateQuest(string type)
{
	local int i;
	local int q;

	i = GetActiveProfile();
	q =	Profile.sProf[i].quests.Length;
	
	Profile.sProf[i].quests.Add(1);
	Profile.sProf[i].quests[q].bCompleted=false;
	Profile.sProf[i].quests[q].points=0;
	Profile.sProf[i].quests[q].questType = type;
	Profile.sProf[i].quests[q].questId ="quest_"$Profile.sProf[i].quests.Length-1;
	return Profile.sProf[i].quests[q].questId;
}

/** 
 *  ��������� ������� ������� */
function StartQuest(optional string ID="")
{
	local int i;
	local int q;
	local int Year,Month,DayOfWeek,Day,Hour,Min,Sec,MSec;
	
	i = GetActiveProfile();
	if(ID!="")
	{
		q = Profile.sProf[i].quests.Find('questId',ID);
	}
	else
	{
		q =	Profile.sProf[i].quests.Length-1;

	}
	GetSystemTime(Year,Month,DayOfWeek,Day,Hour,Min,Sec,MSec);
	Profile.sProf[i].quests[q].startTime.hour = Hour;
	Profile.sProf[i].quests[q].startTime.min = Min;
	Profile.sProf[i].quests[q].startTime.Sec = Sec;
}

/** 
 *  ��������� ������� ������� */
function EndQuest( bool bSuccessfull, optional string ID="")
{
	local int i;
	local int q;
	local int Year,Month,DayOfWeek,Day,Hour,Min,Sec,MSec;
	local int allHour,allMin,allSec,allDay;
	
	i = GetActiveProfile();
	if(ID!="")
	{
		q = Profile.sProf[i].quests.Find('questId',ID);
		if(q==INDEX_NONE)
		{
			`warn("Cant find quest with ID = "$ID);
			return;
		}
	}
	else
	{
		q =	Profile.sProf[i].quests.Length-1;
		if(q<0)
		{
			`warn("Cant find latest quest");
			return;
		}
	}
	if(bSuccessfull)
	{
		GetSystemTime(Year,Month,DayOfWeek,Day,Hour,Min,Sec,MSec);
		Profile.sProf[i].quests[q].endTime.hour = Hour;
		Profile.sProf[i].quests[q].endTime.min = Min;
		Profile.sProf[i].quests[q].endTime.sec = Sec;


		allSec = sec - Profile.sProf[i].quests[q].startTime.sec;
		allMin =  min - Profile.sProf[i].quests[q].startTime.min;
		allHour = hour - Profile.sProf[i].quests[q].startTime.Hour;

		CheckTimePassing(allSec,allMin);
		CheckTimePassing(allMin,allHour);
		CheckTimePassing(allHour,allDay,12);

		Profile.sProf[i].quests[q].allTime.sec = allSec;
		Profile.sProf[i].quests[q].allTime.min = allMin;
		Profile.sProf[i].quests[q].allTime.hour = allHour;


		Profile.sProf[i].quests[q].endTime.hour = Hour;
		Profile.sProf[i].quests[q].endTime.min = Min;
		Profile.sProf[i].quests[q].endTime.Sec = Sec;

		Profile.sProf[i].quests[q].bCompleted = true;

		saveProfile();
	}
	else
	{
		//�� ���������
		Profile.sProf[i].quests.Remove(q,1);

	}
}

function CheckTimePassing(out int sec, out int min, optional byte count = 60)
{
	if(sec < 0 )
	{
		//��������� 60 ������, �������� 1 ������
		sec += count;
		min--;
	}
}

/** 
 *  ��������� � ������� ����� �������� ����� � ��������� � ��������������
 *  @count - ���������� ������ �� ���������
 *  @messageText - ���� ��������� */
function addQuestMessage(string messageText, optional byte pointsCount, optional byte importance ,optional string ID="")
{
	local int i;
	local int q;
	local int m;
	i = GetActiveProfile();

	if(ID!="")
	{
		q = Profile.sProf[i].quests.Find('questId',ID);
	}
	else
	{
		q =	Profile.sProf[i].quests.Length-1;
	}
	m =Profile.sProf[i].quests[q].msgs.Length;

	Profile.sProf[i].quests[q].msgs.Add(1);
	Profile.sProf[i].quests[q].msgs[m].msgText = messageText;
	Profile.sProf[i].quests[q].msgs[m].points = pointsCount;
	Profile.sProf[i].quests[q].msgs[m].importance = importance;
	
}

/** 
 *  ���������� ���������� ������ ������ �� ID ��� � ���������� */
function byte GetQuestPoints(optional string ID = "")
{
	local int i;
	local int q;

	i = GetActiveProfile();

	if(ID!="")
	{
		q = Profile.sProf[i].quests.Find('questId',ID);
	}
	else
	{
		q =	Profile.sProf[i].quests.Length-1;
	}
	return Profile.sProf[i].quests[q].points;
}

/** 
 *  ��������� ���������� ������ ������ �� ID ��� � ���������� */
function AddQuestPoints(byte points, optional string ID = "")
{
	local int i;
	local int q;

	i = GetActiveProfile();

	if(ID!="")
	{
		q = Profile.sProf[i].quests.Find('questId',ID);
	}
	else
	{
		q =	Profile.sProf[i].quests.Length-1;
	}
	Profile.sProf[i].quests[q].points+=points;
}

/** 
 *  ���������� ����� ������ ������ �� ID ��� � ���������� */
function string GetQuestStartTime(optional string ID = "")
{
	local int i;
	local int q;
	local string time;
	i = GetActiveProfile();

	if(ID!="")
	{
		q = Profile.sProf[i].quests.Find('questId',ID);
	}
	else
	{
		q =	Profile.sProf[i].quests.Length-1;
	}
	if(Profile.sProf[i].quests[q].startTime.hour<10)
		time$="0";
	time $= ""$Profile.sProf[i].quests[q].startTime.hour;
	if(Profile.sProf[i].quests[q].startTime.min<10)
		time$=":0";
	else 
		time $= ":";
	time $= ""$Profile.sProf[i].quests[q].startTime.Min;
	if(Profile.sProf[i].quests[q].startTime.Sec<10)
		time$=":0";
	else time $= ":";
	time $= ""$Profile.sProf[i].quests[q].startTime.Sec;
	return time;
}

/** 
 *  ���������� ����� ��������� ������ �� ID ��� � ���������� */
function string GetQuestPassTime(optional string profileName, optional string ID = "")
{
	local int i;
	local int q;
	local string time;
	i = GetIdx(profileName);

	if(ID!="")
	{
		q = Profile.sProf[i].quests.Find('questId',ID);
	}
	else
	{
		q =	Profile.sProf[i].quests.Length-1;
	}
	if(Profile.sProf[i].quests[q].allTime.hour<10)
		time$="0";
	time $= ""$Profile.sProf[i].quests[q].allTime.hour;
	if(Profile.sProf[i].quests[q].allTime.min<10)
		time$=":0";
	else 
		time $= ":";
	time $= ""$Profile.sProf[i].quests[q].allTime.Min;
	if(Profile.sProf[i].quests[q].allTime.Sec<10)
		time$=":0";
	else time $= ":";
	time $= ""$Profile.sProf[i].quests[q].allTime.Sec;
	return time;
}

/** 
 *  ���������� ���������� ��������� ������� */
function int GetQuestsCount(optional string profileName)
{

	local int i;
	i = GetIdx(profileName);
	return Profile.sProf[i].quests.Length;
}

/** 
 *  ���������� ID ��������� �������, ����� ������ ���������� �� ���� */
function array<string> GetQuestsID(optional string type, optional string profileName)
{
	local int i;
	local int j;
	local array<string> questId;
	i = GetIdx(profileName);
	for(j =0;j<Profile.sProf[i].quests.Length;j++)
	{
		if(type =="" || type ==Profile.sProf[i].quests[j].questType)
			questId.AddItem(Profile.sProf[i].quests[j].questId);
	}
	return questId;

}

/** 
 *  ���������� ��� ������ �� ��� ID ��� ��������� */
function string GetQuestType(optional string ID="")
{
	local int i;
	local int q;
	i = GetActiveProfile();
	if(ID!="")
	{
		q = Profile.sProf[i].quests.Find('questId',ID);
	}
	else
	{
		q =	Profile.sProf[i].quests.Length-1;
	}
	return Profile.sProf[i].quests[q].questType;
}

/* ���������� ������ ������� � �������� ������������ */
//function array<quest> GetQuests()
//{
//	local int i;
//	i = GetActiveProfile();
//	return Profile.sProf[i].quests;
//}

/** 
 *  ���������� ������ ������� �� ��� ����� ��� ������ ��������� 
 */
function int GetIdx(optional string profileName)
{
	if(profileName!="")
		return Profile.sProf.Find('ProfileName',profileName);
	else
		return GetActiveProfile();
}

/**
 * ������������� ������� �������. ������� ��� ��������
 */
exec function showProfile()
{
	if (Profile == none)
	{
		gpc.TeamMessage(none, "There is no Profile", 'none');
	}
	gpc.TeamMessage(none, "ID:        "$Profile.name, 'none');
	gpc.TeamMessage(none, "Name:      "$Profile.ProfileName, 'none');
	gpc.TeamMessage(none, "Active:     "$Profile.sProf[ActiveProfile].bIsActive, 'none');
}


DefaultProperties
{
}
