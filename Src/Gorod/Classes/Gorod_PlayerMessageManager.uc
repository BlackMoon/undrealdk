class Gorod_PlayerMessageManager extends Actor;

var int MessageBoxWidth;
var int MessageBoxHeight;
var int MessageBoxX;
var int MessageBoxY;
var int nShowTime;

/** мувик, показывающий сообщени€*/
var Gorod_HUD_MessageBox MsgBoxMovie;

/** массив идентификаторов сообщений */
var array<int> PlayingMessagesIDs;

/** —тетчик текущего свободного идентификатора */
var int idCounter;

/** ќтступ между сообщени€ми */
var int nMargin;

/** если true, сообщени€ будут показыватьс€ сверху вниз */
var bool bShowFromTop;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	MsgBoxMovie = new class'Gorod_HUD_MessageBox';
	MsgBoxMovie.SetAlignment(Align_TopLeft);
	MsgBoxMovie.SetViewScaleMode(SM_NoScale);
	MsgBoxMovie.dlgOnFinishHiding = OnFinishedMessage;
}

/** ѕоказать сообщение игроку */
reliable client event PushMessage(string text, optional string title="Message", optional int timeInMilli = nShowTime)
{
	if(MsgBoxMovie == none)
	{
		`warn("Empty message box player");
	}

	if(!MsgBoxMovie.bMovieIsOpen)
	{
		//`log("starting messageboxplayer");
		MsgBoxMovie.Start(false);
	}

	if(idCounter >= 9999999)
	{
		idCounter = 0;
	}

	//`log("Opening messagebox with id: " $ idCounter);

	// рассчитываем координаты показа
	if(bShowFromTop)
	{
		// если показываем сверху вниз
		MsgBoxMovie.OpenMessageBox(idCounter, title, text, timeInMilli, MessageBoxX, MessageBoxY + PlayingMessagesIDs.Length * (MessageBoxHeight + nMargin), MessageBoxWidth, MessageBoxHeight);
		PlayingMessagesIDs.AddItem(idCounter);
		idCounter++;
	}
	else
	{
		// если показываем снизу вверх
		MsgBoxMovie.OpenMessageBox(idCounter, title, text, timeInMilli, MessageBoxX, MessageBoxY + PlayingMessagesIDs.Length * -(MessageBoxHeight + nMargin) - MessageBoxHeight, MessageBoxWidth, MessageBoxHeight);
		PlayingMessagesIDs.AddItem(idCounter);
		idCounter++;
	}
}

/** ¬ызываетс€ при исчезновении сообщени€ */
function private OnFinishedMessage(int mbID)
{
	local int i, id, c;
	local bool bFind;

	// ищем закрывшеес€ сообщение
	foreach PlayingMessagesIDs(id)
	{
		if(id == mbID)
		{
			// нашли
			bFind = true;
			break;
		}
		i++;
	}

	//`log("MessageFinished " $ mbID $ " no: "$ i);

	if(bFind)
	{
		// если нашли, удал€ем, предварительно переместив очередь последующих окон сообщений вместо этого
		if(i < PlayingMessagesIDs.Length)
		{
			// если показываем сверху вниз
			if(bShowFromTop)
			{
				for(c = i+1; c < PlayingMessagesIDs.Length; c++)
				{
					//`log("set length for " $ PlayingMessagesIDs[c] $ "  " $  MessageBoxHeight * (c-1));
					MsgBoxMovie.SetXYFor(PlayingMessagesIDs[c], MessageBoxX, MessageBoxY + (MessageBoxHeight + nMargin) * (c-1)); 
				}
			}
			else
			{
				// если показываем снизу вверх
				for(c = i+1; c < PlayingMessagesIDs.Length; c++)
				{
					//`log("set length for " $ PlayingMessagesIDs[c] $ "  " $  MessageBoxHeight * (c-1));
					MsgBoxMovie.SetXYFor(PlayingMessagesIDs[c], MessageBoxX, MessageBoxY + -(MessageBoxHeight + nMargin) * (c-1) - MessageBoxHeight); 
				}
			}
		}

		//`log("removeItem" @ i);
		PlayingMessagesIDs.RemoveItem(id);

		/*foreach PlayingMessagesIDs(id)
		{
			`log("item: " $ id);
		}*/
	}

	// если сообщений не осталось, закрываем мувик
	if(PlayingMessagesIDs.Length < 1)
	{
		MsgBoxMovie.Close(false);
	}
}

DefaultProperties
{
	MessageBoxWidth = 320
	MessageBoxHeight = 140
	MessageBoxX = 1575
	MessageBoxY = 25
	nShowTime = 5000
	nMargin = 25
	bShowFromTop = true
}
