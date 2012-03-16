/**
 */
class Gorod_ProfileSettings extends Object config(Gorod_PlayerSettings) perobjectconfig;

/** время прохождения */
struct passageTime
{
	var int hour;
	var int min;
	var int sec;
};

/** Структура сообщений */
struct questMsgs
{
	//степень важности сообщений (выполнено/предупреждение/ошибка)
	var byte importance;
	//Количество баллов
	var byte points;
	//текст сообщения
	var string msgText;
};

/** Позиция на карте */
struct Point
{
	var Vector Location;
	var Rotator Rotation;
};

/** Стартовые позиции */
struct StartPoint
{
	// Позиция машины
	var Point CarPosition;
	// Позиция Игрока
	var Point PlayerStart;
	// Игрок находиться внутри машины
	var bool StartInDrive;
};

/** структура задания */
struct pQuest
{
	/** тип квеста */
	var string questType;
	
	/** ID квеста */
	var string questId;
	
	/** количество баллов */
	var byte points;
	
	/** завершено ли задание */
	var bool bCompleted;
	
	/** массив сообщений */
	var array<questMsgs> msgs;

	/** Место для начала задания */
	var StartPoint StartPoint;

	/** время начала задания */
	var passageTime startTime;
	
	/** время прохождения задания */
	var passageTime allTime;
	
	/** время окончания задания */
	var passageTime endTime;
};

/** Струкутра профиля */
struct structProf
{
	/** The name of the Profile	*/
	var config string ProfileName;
	
	/** массив заданий */
	var config array<pQuest> quests;

	/** Is profile active? */
	var config bool bIsActive;	
};

/** Массив профилей*/
var config array<structProf> sProf;
/**
 * The name of the Profile
 */
var config string ProfileName;
var config Name questType;
var config string QuestId;

/**
 * Save this Profile.
 */
function save()
{
	SaveConfig();
}