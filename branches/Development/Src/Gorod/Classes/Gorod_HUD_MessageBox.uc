class Gorod_HUD_MessageBox extends GFxMoviePlayer;

var private int mWidth;
var private int mHeight;
var private int m_x;
var private int m_y;
var private bool bIsFinished;
var private bool bIsPlaying;

delegate dlgOnFinishHiding(int mbID);

function int GetHeight() { return mHeight; }
function int GetWidth() { return mWidth; }
function int GetX() { return m_x; }
function int GetY() { return m_y; }
function bool IsFinished() { return bIsFinished; }

function bool IsPlaying() { return bIsPlaying; }

event OnClose()
{
	bIsPlaying = false;
}

function bool Start(optional bool startPaused = false)
{
	local bool result;
	result = super.Start(startPaused);

	if(result == true)
	{
		Advance(0.f);
		bIsPlaying = true;
	}

	return result;
}

function SetXYFor(int id, int x, int y)
{
	ActionScriptVoid("SetXYFor");
}

function SetTimer(string title, string message, int num)//setTimer(titletext:String, bodytext:String, value:Number):Void
{
	ActionScriptVoid("messagebox.setTimer");
}

function OpenMessageBox(int id, string title, string message, int num, int x, int y, int sizeX, int sizeY)
{
	ActionScriptVoid("OpenMessageBox");
}

function StartWithNoButton()
{
	ActionScriptVoid("messagebox.startWithNoButton");
}

function SetSize(int width, int height)//setSizes
{
	mWidth = width;
	mHeight = height;

	ActionScriptVoid("messagebox.setSizes");
}

function SetXY(int x, int y)
{
	x += 550 - mWidth;
	y += 400 - mHeight;

	m_x = x;
	m_y = y;

	ActionScriptVoid("messagebox.setXY");
}

function SetMargin(int left, int right, int top, int bottom)
{
	ActionScriptVoid("messagebox.setMargin");
}

function SetSizeOfTitleChar(int val)
{
	ActionScriptVoid("messagebox.setSizeOfTitleChar");
}

function SetSizeOfBodyChar(int val)
{
	ActionScriptVoid("messagebox.setSizeOfBodyChar");
}

function SetTextOfTitle(string txt) { ActionScriptVoid("messagebox.textOfTitle"); }
function SetTextOfBody(string txt) { ActionScriptVoid("messagebox.textOfBody"); }
function SetNoTitle(bool notitle) { ActionScriptVoid("messagebox.notitle"); }
function Reset() { ActionScriptVoid("messagebox.Reset"); }


function CloseMyMovie(int mbID)
{
	//Close(false);
	//Reset();
	//bIsFinished = true;
	dlgOnFinishHiding(mbID);
}

DefaultProperties
{
	bCaptureInput = false
	MovieInfo=SwfMovie'GorodHUD.MessageBox.MessageBox'
	mHeight = 400
	mWidth = 550
	m_x = 0
	m_y = 0

	//RenderTexture = TextureRenderTarget2D'Gorod_Effects.PostProcess.FlashRenderTarget';
	RenderTextureMode = RTM_AlphaComposite
}
