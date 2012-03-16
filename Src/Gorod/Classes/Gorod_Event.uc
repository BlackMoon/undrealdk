class Gorod_Event extends Object;

enum Gorod_EventType
{
	GOROD_EVENT_NONE,
	GOROD_EVENT_PDD,
	GOROD_EVENT_AUTODROM,
	GOROD_EVENT_ZNAK,
	GOROD_EVENT_ROAD,
	GOROD_EVENT_QUEST,
	GOROD_EVENT_HUD,
	GOROD_EVENT_REGISTER_MESSAGES,
	GOROD_EVENT_GAME
};

var Gorod_EventType eventType;
var float fireTime;
var int messageID;
var name senderName;
var Object sender;

/** Время показа сообщения в миллисекундах */
var int ShowTime;

DefaultProperties
{
	eventType = GOROD_EVENT_NONE;
	messageID = -1;
	ShowTime = 5000;
}