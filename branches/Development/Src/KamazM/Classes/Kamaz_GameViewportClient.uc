class Kamaz_GameViewportClient extends UDKGameViewportClient;

/**
 * Notifies the player that an attempt to connect to a remote server failed, or an existing connection was dropped.
 *
 * @param MessageType EProgressMessageType of current connection error
 * @param	Message		a description of why the connection was lost
 * @param	Title		the title to use in the connection failure message.
 */
function NotifyConnectionError(EProgressMessageType MessageType, optional string Message=Localize("Errors", "ConnectionFailed", "Engine"), optional string Title=Localize("Errors", "ConnectionFailed_Title", "Engine") )
{
	local LocalPlayer lp;

	super.NotifyConnectionError(MessageType, Message, Title);

	// вызываем функцию, отключающую нас от сервера
	lp = GetPlayerOwner(0);
	Kamaz_PlayerController(lp.Actor).ClientQuit();
}

/** Функция пустая, что-бы не выводились надписи LoadingMessage SavingMessage ConnectingMessage PrecachingMessage PausedMessage */
function DrawTransition(Canvas Canvas)
{
}


DefaultProperties
{
	UIControllerClass=class'UDKBase.UDKGameInteraction'
	
}
