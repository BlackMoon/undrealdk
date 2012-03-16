class Library_Msg extends Object;

const prefix = "++ ";

// If debugging is enabled, write the message to the log and try to write it to the screen.
public static function DebugMessage(Object sender, string message)
{
    LogMessage(message);
	GenericClientMessage(sender, message);    
}

// Try to somehow write the message to the screen.
private static function GenericClientMessage(Object sender, coerce string message)
{
    if (Actor(sender) != none)
    {
        ScreenMessage(Actor(sender), message);
    }
    else if (ActorComponent(sender) != none)
    {
        ScreenMessage(ActorComponent(sender).Owner, message);
    }
    else
    {
        WorldInfoClientMessage(message);
    }
}

// Write the message to the log.
public static function LogMessage(coerce string message)
{
    `log(prefix $ message);
}

// Write the message to the screen.
public static function ScreenMessage(Actor sender, coerce string message)
{
    local PlayerController PC;

    foreach sender.LocalPlayerControllers(class'PlayerController', PC)
    {
        PC.ClientMessage(message,, 5.0f);
    }
}

// Try to grab the WorldInfo and use that to write the message to the screen.
public static function WorldInfoClientMessage(coerce string message)
{
    local WorldInfo wi;
    wi = GetWorldInfo();

    if (wi != none) ScreenMessage(wi, message);    
    else
    {
        LogMessage(message);
        LogMessage("Could not send the previous message to clients because WorldInfo0 was not found.");
    }
}

// Try to grab the WorldInfo.
private static function WorldInfo GetWorldInfo()
{
    return WorldInfo(FindObject("WorldInfo_0", class'WorldInfo'));
}