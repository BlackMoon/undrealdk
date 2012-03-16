/** �����, ������� ���������� ������� � ���������*/
class Kamaz_Sapitu extends Object;


simulated function Kamaz_ProfileSettings createProfile(optional string ProfileId = "Profile_"$TimeStamp()$rand(100)$"_")
{
   	local Kamaz_ProfileSettings Profile;
	// ������� �� ������ ��������� ��������� �������:
	ProfileId -= " ";
	ProfileId -= ":";
	ProfileId -= "/";
	ProfileId -= "-";
	Profile = new(none, ProfileId) class'Kamaz_ProfileSettings';
	return Profile;
}

/** 
 *  ��������� ������� �� ��� ProfileId*/
simulated function Kamaz_ProfileSettings loadProfile(string ProfileId)
{
	local Kamaz_ProfileSettings Profile;
	local array<string> Profiles;
	
	Profiles = getProfiles();
	if (Profiles.find(ProfileId) == INDEX_NONE) return none;
	
	//������� ��������� �������
	Profile = new(none, ProfileId) class'Kamaz_ProfileSettings';
	if (Profile == none) return none;
	return Profile;
}

/** 
 *  �������� ��������� ������ ���� �������� */
simulated function array<string> getProfiles()
{
	local array<string> res;
	local int i, idx;
	GetPerObjectConfigSections(class'Kamaz_ProfileSettings', res);
	for (i = 0; i < res.length; ++i)
	{
		idx = InStr(res[i], " ");
		if (idx != INDEX_NONE)
		{
			res[i] = left(res[i], idx);
		}
	}
	return res;
}

DefaultProperties
{
}
