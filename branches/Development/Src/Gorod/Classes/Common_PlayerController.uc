class Common_PlayerController extends UDKPlayerController;

var Gorod_EventDispatcher EventDispatcher;
var Gorod_PlayerMessageManager PlayerMessageManager;
var Gorod_MessagesManager MessagesManager;

/** 
 *  контроллер знаков*/
var Gorod_Znak_Controller ZnakController; 
/**
 * контроллер ПДД*/
var Gorod_PDDController PDDController;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// диспетчер сообщений
	EventDispatcher = Spawn(class'Gorod_EventDispatcher', self);

	// менеджер мессаджбокс
	PlayerMessageManager = spawn(class'Gorod_PlayerMessageManager', self);

	// менеджер сообщений
	MessagesManager = new class'Gorod_MessagesManager';



	/**Создаем экземпляр контроллера знаков*/
	ZnakController= new class'Gorod_Znak_Controller';
	`warn("Gorod_Znak_Controller = none", ZnakController == none);
	ZnakController.Initeliaze(self);
	/**Создаем экземпляр контроллера ПДД*/
	PDDController = Spawn(class 'Gorod_PDDController');
	`warn("Gorod_PDDController = none", PDDController == none);
	PDDController.Initeliaze(self);
}

/** 
 *  функция, показывающая сообщение, взависимости от настроек */
client reliable function ClientShowMsgBox(string Text, optional string Title, optional int TimeInMili)
{
	`warn("PlayerMessageManager=none",PlayerMessageManager==none);

	if(PlayerMessageManager!=none)
	{
		if(TimeInMili<=0)
			PlayerMessageManager.PushMessage(Text, Title);
		else
			PlayerMessageManager.PushMessage(Text, Title, TimeInMili);
	}
}

/** 
 * функция, проигрывающая SoundCue 
 */
client reliable function ClientPlaySoundCue(SoundCue sound)
{
	if(sound!=none)
		PlaySound(sound,true);
}

DefaultProperties
{
}
