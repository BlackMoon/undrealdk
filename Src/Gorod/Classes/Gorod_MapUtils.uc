class Gorod_MapUtils extends Actor config (MapUtils);

struct LevelSize
{
	var Vector Origin;
	var Float Width;
	var Float Hight;
	var string PackageName;
};


var config array <LevelSize> AllLevels;

event PostBeginPlay()
{
	super.PostBeginPlay();

	if(AllLevels.Length == 0)
	{
		InitLevels();
		SaveConfig();
	}
}

function InitLevels()
{
	local int i, j;
	local LevelStreaming lsd;
	local LevelSize level, level2;
	local Vector /*TestPoint0, TestPoint1,*/ TestPoint2/*, TestPoint3*/;
	//local float Width;

	AllLevels.Remove(0, AllLevels.Length);

	//Width = `SIZE_LEVEL;
	foreach WorldInfo.StreamingLevels(lsd, i)
	{
		if (LevelStreamingDistance(lsd) != none )
		{
			level.PackageName = string(lsd.PackageName);
			if (level.Origin.X == LevelStreamingDistance(lsd).Origin.X)
			{
				/*if (level.Origin.Y > 0)
					level.Hight = Abs (LevelStreamingDistance(lsd).Origin.Y - level.Origin.Y);
				else*/
					level.Hight = `SIZE_LEVEL;
				level.Width = `SIZE_LEVEL;
			}
			else
			{
				level.Hight = `SIZE_LEVEL;
				/*if (level.Origin.X > 0)
					level.Width = Abs (LevelStreamingDistance(lsd).Origin.X - level.Origin.X);
				else*/
					 level.Width = `SIZE_LEVEL; 
			}				
			
			//level.Width = Width;
			level.Origin = LevelStreamingDistance(lsd).Origin;
			
			AllLevels.AddItem(level);
		}
	}

	foreach AllLevels(level, i)
	{
		//TestPoint0 = level.Origin;

		//TestPoint1.X = level.Origin.X;
		//TestPoint1.Y = level.Origin.Y + level.Hight;

		TestPoint2.X = AllLevels[i].Origin.X + AllLevels[i].Width;
		TestPoint2.Y = AllLevels[i].Origin.Y + AllLevels[i].Hight;

		//TestPoint3.X = AllLevels[i].Origin.X + AllLevels[i].Width;
		//TestPoint3.Y = AllLevels[i].Origin.Y;

		foreach AllLevels(level2, j)
		{
			if (i != j)
			{
				if ((TestPoint2.X >= level2.Origin.X && TestPoint2.X <= level2.Origin.X + level2.Width) &&
					(TestPoint2.Y >= level2.Origin.Y && TestPoint2.Y <= level2.Origin.Y + level2.Hight))
				{
					if (AllLevels[i].Origin.X != level2.Origin.X)
					{
						AllLevels[i].Width = Abs(AllLevels[i].Origin.X - level2.Origin.X) -1;
						TestPoint2.X = AllLevels[i].Origin.X + AllLevels[i].Width;
					}
					if (AllLevels[i].Origin.Y != level2.Origin.Y)
					{
						AllLevels[i].Hight = Abs(AllLevels[i].Origin.Y - level2.Origin.Y) -1;
						TestPoint2.Y = AllLevels[i].Origin.Y + AllLevels[i].Hight;
					}
				}

			}
			
		}	
	}
}

DefaultProperties
{
}
