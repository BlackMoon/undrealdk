/** ����� � ����������� ��������� ��� ������ 
 *  
 *  ��������:
 *  - �������� � ������� ���������
 *  - ��������� ������ ��� ������ ��������� (������ ����������) */

class Kamaz_ClientMessageBroadcaster extends Actor config(MessageConfig) dependson (Gorod_EventDispatcher,Gorod_BaseMessages) implements(Gorod_EventListener);

/** ���������� ��������� */
var bool bShowTips;
/** ���������� �������������� */
var bool bShowWarn;
/** ���������� ������ */
var bool bShowError;
/** ���������� ���������� */
var bool bShowInform;
/** ���������� ����������� */
var config bool bShowMsgBox;
/** ����������� ���� */
var config bool bPlaySound;
/** ����������� ���� ������ */
var config bool bPlayVoiceSound;
/** ������ ������ */
var config byte voice_index;

/** ���������� MessageBox*/
var Gorod_PlayerMessageManager msgM;

/** ���������� ������ */
var Kamaz_PlayerController kamazPC;

// �������� �������������
var SoundCue InformSound;
var SoundCue WarnSound;
var SoundCue ErrorSound;
var SoundCue TipSound;

var  array<MessageInfo> msgInfos;

function Initialize(Kamaz_PlayerController objPC)
{
	local Gorod_Event ge;
	kamazPC = objPC;
	`warn("kamazPC=none", kamazPC==none);
	if(kamazPC!=none)
	{
		kamazPC.EventDispatcher.RegisterListener(self,GOROD_EVENT_HUD);
		ge = new class'Gorod_Event';
		ge.messageID=0;
		ge.sender = self;
		kamazPC.EventDispatcher.SendEvent(ge);
	}

	msgM = spawn(class'Gorod_PlayerMessageManager');
	/** ������� ��������� ������ 5 ���*/
	SetTimer(5,true,'ClearMessage');

}

function HandleEvent(Gorod_Event evt)
{
	local MessageInfo msgInfo;

	msgInfo = kamazPC.MessagesManager.getMessageContent(evt.messageID);
	msgInfo.ShowTime = evt.ShowTime;
	if(!CheckLatestMessageExist(msgInfo.ID))
	{
		CheckMsgSettingsAndSend(msgInfo);
		msgInfos.AddItem(msgInfo);
	}
}
/** ���������, ���� �� ���������  c �������� ID � ��������. */
function bool CheckLatestMessageExist(int ID)
{
	if(msgInfos.Find('ID',ID)!=INDEX_NONE)
		return true;
	else 
		return false;
}
/** ������� ������ ��������� ��������� �� ������� */
function ClearMessage()
{
	if(msgInfos.Length>0)
		msgInfos.Remove(0,1);
}
function CheckMsgSettingsAndSend(MessageInfo msgInfo)
{
	// ���� ��������� ��������������, �.� ��� ������ � ��� ������ � � ���������� ������� ���������� �����������
	switch (msgInfo.type)
	{
	case MESSAGE_NONE:
		kamazPC.ClientMessage(msgInfo.Text);
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


/** ������� ��������� ��������� 
 *  
 *  @param IN msg_index ������ ��������� � ������� msg_tip */
simulated function show_and_play_msg_tip(MessageInfo msgInfo)
{
	if(bShowTips)
	{
		kamazPC.ClientShowMsgBox(msgInfo.Text, msgInfo.Title, msgInfo.ShowTime);
		if(bPlaySound)
			kamazPC.ClientPlaySoundCue(TipSound);
		if(bPlayVoiceSound)
			kamazPC.ClientPlaySoundCue(msgInfo.Cue);

	}
}

/** ������� ��������� �������������� 
 *  
 *  @param IN msg_index ������ ��������� � ������� msg_warning */
simulated function show_and_play_msg_warn(MessageInfo msgInfo)
{
	if(bShowWarn)
	{
		kamazPC.ClientShowMsgBox(msgInfo.Text, msgInfo.Title, msgInfo.ShowTime);
		if(bPlaySound)
			kamazPC.ClientPlaySoundCue(WarnSound);
		if(bPlayVoiceSound)
			kamazPC.ClientPlaySoundCue(msgInfo.Cue);

	}
}

/** ������� ��������� ������
 *  
 *  @param IN msg_index ������ ��������� � ������� msg_error */
simulated function show_and_play_msg_error(MessageInfo msgInfo)
{
	if(bShowError)
	{
		kamazPC.ClientShowMsgBox(msgInfo.Text, msgInfo.Title, msgInfo.ShowTime);
		if(bPlaySound)
			kamazPC.ClientPlaySoundCue(ErrorSound);
		if(bPlayVoiceSound)
			kamazPC.ClientPlaySoundCue(msgInfo.Cue);

	}
}

/** ������� ����������
 *  
 *  @param IN msg_index ������ ��������� � ������� msg_inform */
simulated function show_and_play_msg_inform(MessageInfo msgInfo)
{
	if(bShowInform)
	{
		kamazPC.ClientShowMsgBox(msgInfo.Text, msgInfo.Title, msgInfo.ShowTime);
		if(bPlaySound)
			kamazPC.ClientPlaySoundCue(InformSound);
		if(bPlayVoiceSound)
			kamazPC.ClientPlaySoundCue(msgInfo.Cue);
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
