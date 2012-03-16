/** Класс, который спавнит ботов-людей. Проект город */
class Gorod_HumanBotSpawner extends Gorod_BaseSpawner
	placeable;
/** Ссылка на заспавненного бота */
var Gorod_HumanBot SpawnHumanBot;

simulated event PostBeginPlay()
{
	BotLength = 100;
	super.PostBeginPlay();
}

/** Функция, которая спавнит бота*/
function SpawnBot(SpawnPoint P/*, Gorod_HumanBotPathNode Target */)
{

	//не забыть поменять  SpawnPathNode.Rotation
	 if(Role == ROLE_Authority)
	 {
	 	SpawnHumanBot = Spawn(class'Gorod_HumanBot', self, 'bot', P.Location, P.Rotation, , false);
	 	if(SpawnHumanBot!=none)
	 	{
			if(SpawnHumanBot.botAiCont !=none)
			{
	 			SpawnHumanBot.botAiCont = Spawn(class'Gorod_HumanBotAiController',self);
			}
			if(SpawnHumanBot.Physics!=PHYS_Walking)
			{
				SpawnHumanBot.SetPhysics(PHYS_Walking);
				SpawnHumanBot.CollisionComponent.WakeRigidBody();
			}
	 		SpawnHumanBot.botAiCont.SetPawn(SpawnHumanBot,self);
	 		SpawnHumanBot.ChangeTarget(Gorod_HumanBotPathNode(P.firstPathNode),P.Location,P.Rotation);
			//SpawnHumanBot.ChangeSkeletalMesh();
	 	}
	 }
}

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'Gorod_HumanBot.Texture.BotSpawner'
		HiddenGame=true
		HiddenEditor=false
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Navigation"
	End Object
	Components.Add(Sprite)

	//RemoteRole = ROLE_SimulatedProxy
}
