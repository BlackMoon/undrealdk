/** вывод и озвучивание сообщения для игрока 
 *  
 *  ДОБАВИТЬ:
 *  - элементы в массивы сообщений
 *  - несколько звуков для одного сообщения (разный инструктор) */

class Gorod_ClientMessageBroadcaster extends Actor config(MessageConfig) dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);

/** Показывать подсказки */
var bool bShowTips;
/** Показывать предупреждения */
var bool bShowWarn;
/** Показывать ошибки */
var bool bShowError;
/** показывать информацию */
var bool bShowInform;
/** Показывать мессаджбокс */
var config bool bShowMsgBox;
/** Проигрывать звук */
var config bool bPlaySound;
/** Проигрывать звук голоса */
var config bool bPlayVoiceSound;
/** Индекс голоса */
var config byte voice_index;

/** Показывает MessageBox*/
var Gorod_PlayerMessageManager msgM;

/** Контроллер игрока */
var Common_PlayerController gorodPC;

// ЗВУКОВОЕ СОПРОВОЖДЕНИЕ
var SoundCue InformSound;
var SoundCue WarnSound;
var SoundCue ErrorSound;
var SoundCue TipSound;

var  array<MessageInfo> msgInfos;

function Initialize(Common_PlayerController objPC)
{
	local Gorod_Event ge;
	gorodPC = objPC;
	`warn("gorodPC=none", gorodPC==none);
	if(gorodPC!=none)
	{
		gorodPC.EventDispatcher.RegisterListener(self,GOROD_EVENT_HUD);
		ge = new class'Gorod_Event';
		ge.messageID=0;
		ge.sender = self;
		gorodPC.EventDispatcher.SendEvent(ge);
	}

	msgM = spawn(class'Gorod_PlayerMessageManager');
	/** очищаем сообщения каждые 5 сек*/
	SetTimer(5,true,'ClearMessage');

}

function HandleEvent(Gorod_Event evt)
{
	local MessageInfo msgInfo;

	msgInfo = gorodPC.MessagesManager.getMessageContent(evt.messageID);
	msgInfo.ShowTime = evt.ShowTime;
	if(!CheckLatestMessageExist(msgInfo.ID))
	{
		CheckMsgSettingsAndSend(msgInfo);
		msgInfos.AddItem(msgInfo);
	}
}
/** Проверяет, есть ли сообщение  c заданном ID в недавних. */
function bool CheckLatestMessageExist(int ID)
{
	if(msgInfos.Find('ID',ID)!=INDEX_NONE)
		return true;
	else 
		return false;
}
/** Удаляем первое пришедшее сообщение из очереди */
function ClearMessage()
{
	if(msgInfos.Length>0)
		msgInfos.Remove(0,1);
}
function CheckMsgSettingsAndSend(MessageInfo msgInfo)
{
	// если сообщение информационное, т.е нет штрафа и нет баллов и в настройках указано показывать иноформацию
	switch (msgInfo.type)
	{
	case MESSAGE_NONE:
		GorodPC.ClientMessage(msgInfo.Text);
	break;
	
	case MESSAGE_TIP:

		show_and_play_msg_tip(msgInfo);
		
	break;

	case MESSAGE_WARNING:

		show_and_play_msg_warn(msgInfo);

	break;

	case MESSAGE_ERROR:
		
		show_and_play_msg_error(msgInfo);
	break;

	case MESSAGE_INFORM:

		show_and_play_msg_inform(msgInfo);

	break;
	}
}


/** вывести сообщение подсказки 
 *  
 *  @param IN msg_index индекс сообщения в массиве msg_tip */
simulated function show_and_play_msg_tip(MessageInfo msgInfo)
{
	if(bShowTips)
	{
		GorodPC.ClientShowMsgBox(msgInfo.Text, msgInfo.Title, msgInfo.ShowTime);
		if(bPlaySound)
			GorodPC.ClientPlaySoundCue(TipSound);
		if(bPlayVoiceSound)
			GorodPC.ClientPlaySoundCue(msgInfo.Cue);

	}
}

/** вывести сообщение предупреждения 
 *  
 *  @param IN msg_index индекс сообщения в массиве msg_warning */
simulated function show_and_play_msg_warn(MessageInfo msgInfo)
{
	if(bShowWarn)
	{
		GorodPC.ClientShowMsgBox(msgInfo.Text, msgInfo.Title, msgInfo.ShowTime);
		if(bPlaySound)
			GorodPC.ClientPlaySoundCue(WarnSound);
		if(bPlayVoiceSound)
			GorodPC.ClientPlaySoundCue(msgInfo.Cue);

	}
}

/** вывести сообщение ошибки
 *  
 *  @param IN msg_index индекс сообщения в массиве msg_error */
simulated function show_and_play_msg_error(MessageInfo msgInfo)
{
	if(bShowError)
	{
		GorodPC.ClientShowMsgBox(msgInfo.Text, msgInfo.Title, msgInfo.ShowTime);
		if(bPlaySound)
			GorodPC.ClientPlaySoundCue(ErrorSound);
		if(bPlayVoiceSound)
			GorodPC.ClientPlaySoundCue(msgInfo.Cue);

	}
}

/** вывести информацию
 *  
 *  @param IN msg_index индекс сообщения в массиве msg_inform */
simulated function show_and_play_msg_inform(MessageInfo msgInfo)
{
	if(bShowInform)
	{
		GorodPC.ClientShowMsgBox(msgInfo.Text, msgInfo.Title, msgInfo.ShowTime);
		if(bPlaySound)
			GorodPC.ClientPlaySoundCue(InformSound);
		if(bPlayVoiceSound)
			GorodPC.ClientPlaySoundCue(msgInfo.Cue);
	}
}


DefaultProperties
{
	bShowTips = true
	bShowWarn = true
	bShowError = true
	bShowInform = true

	InformSound = SoundCue'menu.Gameplay.MessageBeepCue'
	TipSound = SoundCue'menu.Gameplay.MessageBeepCue'
	WarnSound = SoundCue'menu.Gameplay.MessageBeepCue'
	ErrorSound = SoundCue'menu.Gameplay.MessageBeepCue'
}
