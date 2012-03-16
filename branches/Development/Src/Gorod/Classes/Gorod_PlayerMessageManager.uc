class Gorod_PlayerMessageManager extends Actor;

var int MessageBoxWidth;
var int MessageBoxHeight;
var int MessageBoxX;
var int MessageBoxY;
var int nShowTime;

/** �����, ������������ ���������*/
var Gorod_HUD_MessageBox MsgBoxMovie;

/** ������ ��������������� ��������� */
var array<int> PlayingMessagesIDs;

/** ������� �������� ���������� �������������� */
var int idCounter;

/** ������ ����� ����������� */
var int nMargin;

/** ���� true, ��������� ����� ������������ ������ ���� */
var bool bShowFromTop;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	MsgBoxMovie = new class'Gorod_HUD_MessageBox';
	MsgBoxMovie.SetAlignment(Align_TopLeft);
	MsgBoxMovie.SetViewScaleMode(SM_NoScale);
	MsgBoxMovie.dlgOnFinishHiding = OnFinishedMessage;
}

/** �������� ��������� ������ */
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

	// ������������ ���������� ������
	if(bShowFromTop)
	{
		// ���� ���������� ������ ����
		MsgBoxMovie.OpenMessageBox(idCounter, title, text, timeInMilli, MessageBoxX, MessageBoxY + PlayingMessagesIDs.Length * (MessageBoxHeight + nMargin), MessageBoxWidth, MessageBoxHeight);
		PlayingMessagesIDs.AddItem(idCounter);
		idCounter++;
	}
	else
	{
		// ���� ���������� ����� �����
		MsgBoxMovie.OpenMessageBox(idCounter, title, text, timeInMilli, MessageBoxX, MessageBoxY + PlayingMessagesIDs.Length * -(MessageBoxHeight + nMargin) - MessageBoxHeight, MessageBoxWidth, MessageBoxHeight);
		PlayingMessagesIDs.AddItem(idCounter);
		idCounter++;
	}
}

/** ���������� ��� ������������ ��������� */
function private OnFinishedMessage(int mbID)
{
	local int i, id, c;
	local bool bFind;

	// ���� ����������� ���������
	foreach PlayingMessagesIDs(id)
	{
		if(id == mbID)
		{
			// �����
			bFind = true;
			break;
		}
		i++;
	}

	//`log("MessageFinished " $ mbID $ " no: "$ i);

	if(bFind)
	{
		// ���� �����, �������, �������������� ���������� ������� ����������� ���� ��������� ������ �����
		if(i < PlayingMessagesIDs.Length)
		{
			// ���� ���������� ������ ����
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
				// ���� ���������� ����� �����
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

	// ���� ��������� �� ��������, ��������� �����
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
