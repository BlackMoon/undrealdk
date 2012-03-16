/**
 */
class Gorod_ProfileSettings extends Object config(Gorod_PlayerSettings) perobjectconfig;

/** ����� ����������� */
struct passageTime
{
	var int hour;
	var int min;
	var int sec;
};

/** ��������� ��������� */
struct questMsgs
{
	//������� �������� ��������� (���������/��������������/������)
	var byte importance;
	//���������� ������
	var byte points;
	//����� ���������
	var string msgText;
};

/** ������� �� ����� */
struct Point
{
	var Vector Location;
	var Rotator Rotation;
};

/** ��������� ������� */
struct StartPoint
{
	// ������� ������
	var Point CarPosition;
	// ������� ������
	var Point PlayerStart;
	// ����� ���������� ������ ������
	var bool StartInDrive;
};

/** ��������� ������� */
struct pQuest
{
	/** ��� ������ */
	var string questType;
	
	/** ID ������ */
	var string questId;
	
	/** ���������� ������ */
	var byte points;
	
	/** ��������� �� ������� */
	var bool bCompleted;
	
	/** ������ ��������� */
	var array<questMsgs> msgs;

	/** ����� ��� ������ ������� */
	var StartPoint StartPoint;

	/** ����� ������ ������� */
	var passageTime startTime;
	
	/** ����� ����������� ������� */
	var passageTime allTime;
	
	/** ����� ��������� ������� */
	var passageTime endTime;
};

/** ��������� ������� */
struct structProf
{
	/** The name of the Profile	*/
	var config string ProfileName;
	
	/** ������ ������� */
	var config array<pQuest> quests;

	/** Is profile active? */
	var config bool bIsActive;	
};

/** ������ ��������*/
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