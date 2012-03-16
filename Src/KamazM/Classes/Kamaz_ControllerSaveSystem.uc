/** Класс для работы с профилем и для сохранения прогресса */
class Kamaz_ControllerSaveSystem extends Actor;

struct UserDefProfile
{
	var string UserName;
	var string Path;

};

/** 
 *  Структура для хранения имени пользователя Windows и др */
var  UserDefProfile winUser;

var Kamaz_PlayerController gpc;

/** 
 *  Ссылка на класс который работает с профилем */
var Kamaz_ProfileMDllBinder dllb;
/** 
 *  Имя пользователя */
var string userName;
/** 
 *  Текущий профиль */
var Kamaz_ProfileSettings Profile;
/** 
 *  Система работы с профилями */
var Kamaz_Sapitu sapitu;

/** 
 *  Массив профилей */
var array<Kamaz_ProfileSettings> ProfArray;

/** 
 *  индекс активного профиля */
var int ActiveProfile;

simulated event PostBeginPlay()
{
	local array<string> Users;
	/* Просто счетчик */
	local int i;
	/* Получаем ссылку на экземпляр sapitu */
	`log(WorldInfo.Game);

	//создаем экземляр класса
	dllb = new class'Kamaz_ProfileMDllBinder';
	//получаем имя профиля
	dllb.GetProfileName( winUser );
	sapitu = new class'Kamaz_Sapitu';
	if(sapitu==none)
		`warn("sapitu = none");

	//получаем массив всех полльзователей, у которых установлен проект город и у них есть профили
	Users = sapitu.getProfiles();
	//если профилей нет (первый запуск)
	if (Users.length == 0)
	{
		 createFirstProfile();
	}
	//загружаем активный профиль пользователя
	else
	{
		for (i = 0; i < Users.length; ++i)
		{
			
			if(Users[i] == winUser.UserName)
			{
				Profile = new( none, Users[i]) class'Kamaz_ProfileSettings';
				ActiveProfile = GetActiveProfile();
				//выводимое имя равно имени активного профиля пользователя
				UserName = Profile.sProf[ActiveProfile].ProfileName;
				//загружаем пользователя
				loadProfile(Profile.ProfileName);
				break;
			}
		}
		//если мы сюда дошли, и профиль пуст, значит у другого пользователя уже есть профиль, а у текущего нет
		if(Profile==none)
		{
			createFirstProfile();
		}
	}
	super.PostBeginPlay();
}

/** 
 *  Создает профиль с дефолтными настройками */
function bool createProfile(string pName, optional bool bActivate = false)
{
	//имя профиля не должно быть пустым
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
	//Добавляем 1 элемент в конец массива
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
 *  Создает первый профиль пользователя */
function createFirstProfile()
{
	//записываем имя профиля в глобальну переменную
	userName = winUser.UserName;

	Profile = sapitu.createProfile(userName);
	Profile.ProfileName = userName;
	//сразу создаем профиль. Это первый плофиль, поэтому он д.б активным
	
	//Указываем имя активного профиля
	ActiveProfile = 0;
	createProfile(userName, true);

	//сразу сохраняем профиль
	saveProfile();

}

/**
 * Сохранение профиля */
function saveProfile()
{
	if (Profile != none)
	{
		Profile.save();
	}
}

/** 
 *  Загрузка профиля */
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
 * Распечатка профилей. Функция для удобства
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
 * Деактивирует выбранный профиль. 
 *  Если вызывается эта функция,
 *  обязательно должно следовать активирование какого либо другого профиля.
 *  Можно обьединить в одну функцию смену активного профиля
 *  */
function deactivateProfile()
{
	//профиль не активен
	Profile.sProf[GetActiveProfile()].bIsActive =false;
	SaveConfig();
}

/** 
 *  Возвращает индекс первого (и едниственного) активного профиля */
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
 *  Возвращает имя активного пользователя*/
function string GetActiveProfileName()
{
	return Profile.sProf[GetActiveProfile()].ProfileName;
}

/** 
 *  меняет активный профиль на тот, имя которого указано в параметре */
function bool ChangeActiveProfile(string ProfileName)
{

	local int i;
	for(i=0; i<Profile.sProf.Length;++i)
	{
		//если профиль нашелся
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
 *  Удаляет профиль, имя которого указано в параметре */
function bool DeleteProfile(string ProfileName)
{
	local int i;
	for(i=0; i<Profile.sProf.Length;++i)
	{
		//если профиль нашелся
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
 *  Переименовывает профиль, имя которого указано в параметре */
function bool RenameProfile(string ProfileName, string newProfileName)
{
	local int i;
	if(newProfileName=="")
	{
		return false;
	}
	for(i=0; i<Profile.sProf.Length;++i)
	{
		//если профиль нашелся
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
///** Устанавливает класс машины */
//exec function SetProfileClass(string ProfileName, string CarClass)
//{
//	local int i;
//	for(i=0; i<Profile.sProf.Length;++i)
//	{
//		//если профиль нашелся
//		if(Profile.sProf[i].ProfileName == ProfileName)
//		{
//			Profile.sProf[i].ProfileClass = CarClass;
//			saveProfile();
//			break;
//		}
//	}
//}

///** Устанавливает настройку коробки передач (авто или нет) */
//function bool SetProfileTransmision(string ProfileName, bool autoTransmision)
//{
//	local int i;
//	for(i=0; i<Profile.sProf.Length;++i)
//	{
//		//если профиль нашелся
//		if(Profile.sProf[i].ProfileName == ProfileName)
//		{
//			Profile.sProf[i].autoTransmision = autoTransmision;
//			saveProfile();
//			return true;
//		}
//	}
//	return false;
//}

///** Возвращает настройку коробки передач (авто или нет) */
//function bool GetProfileTransmision(string ProfileName)
//{
//	local int i;
//	for(i=0; i<Profile.sProf.Length;++i)
//	{
//		//если профиль нашелся
//		if(Profile.sProf[i].ProfileName == ProfileName)
//		{
//			return Profile.sProf[i].autoTransmision;
//		}
//	}
//}

/** 
 *  Возвращает true, если профиль с именем, указанным в параметре существует. Иначе false */
function bool bIsProfileExist(string pName)
{
	local int i;
	for(i=0; i<Profile.sProf.Length;++i)
	{
		//если профиль нашелся
		if(Profile.sProf[i].ProfileName == pName)
		{
			//Такой профиль уже существует
			return true;
		}
	}
	return false;
}

/** 
 *  Создает новое задание для текущего профиля и возвращает его ID */
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
 *  Запускает текущее задание */
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
 *  Завершает текущее задание */
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
		//не сохраняем
		Profile.sProf[i].quests.Remove(q,1);

	}
}

function CheckTimePassing(out int sec, out int min, optional byte count = 60)
{
	if(sec < 0 )
	{
		//добавляем 60 секунд, вычитаем 1 минуту
		sec += count;
		min--;
	}
}

/** 
 *  Добавляет в текущий квест штрафные баллы и сообщение о предупреждении
 *  @count - количество баллов за сообщение
 *  @messageText - тест сообщкния */
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
 *  Возвращает количество баллов квеста по ID или у последнего */
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
 *  Добавляет количество баллов квеста по ID или у последнего */
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
 *  Возвращает время начала квеста по ID или у последнего */
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
 *  Возвращает время окончания квеста по ID или у последнего */
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
 *  Возвращает количество пройденых квестов */
function int GetQuestsCount(optional string profileName)
{

	local int i;
	i = GetIdx(profileName);
	return Profile.sProf[i].quests.Length;
}

/** 
 *  Возвращает ID пройденых квестов, можно задать фильтрацию по типу */
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
 *  Возвращает тип квеста по его ID или последний */
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

/* Возвращает массив квестов у текущего пользователя */
//function array<quest> GetQuests()
//{
//	local int i;
//	i = GetActiveProfile();
//	return Profile.sProf[i].quests;
//}

/** 
 *  Возвращает индекс профиля по его имени или индекс активного 
 */
function int GetIdx(optional string profileName)
{
	if(profileName!="")
		return Profile.sProf.Find('ProfileName',profileName);
	else
		return GetActiveProfile();
}

/**
 * Распечатывает текущий профиль. Функция для удобства
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
