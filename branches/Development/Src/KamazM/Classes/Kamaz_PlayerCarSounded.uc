/** ����� ������ ��������� */
class Kamaz_PlayerCarSounded extends Kamaz_PlayerCar;

/** ����, ������������� ��� ������� �������� */
var(Sounds) AudioComponent StarterVehicleSound;
/** ����, ������������� ��� ��������� ������������ ��� �������� */
var(Sounds) AudioComponent TurnAndEmergencySignalSound;
/** ����, ������������ ��� ���������� ����������� */
var(Sounds) SoundCue TurnAndEmergencySignalSoundOff;
//=========================================================================
// ����� ���������
/** ���� �� ����������� �������� */
var(Sounds) AudioComponent NeutralRPMSound;
/** ���� �� ������ �������� */
var(Sounds) AudioComponent LowRPMSound;
/** ���� �� ������ ������� �������� */
var(Sounds) AudioComponent AverageRPMSound;
/** ���� �� ������� ������� �������� */
var(Sounds) AudioComponent HighRPMSound;
/** ���� ��������� ��������� */
var(Sounds) AudioComponent EngineStopSound;
/** ���� ������ */
var(Sounds) AudioComponent SirenaSound;

var int neutralRPMRangeMin;
var int neutralRPMRangeMax;

var int lowRPMRangeMin;
var int lowRPMRangeMax;

var int averageRPMRangeMin;
var int RPMRangeMax;

/** ������� ������������ �������� ��������� � ����� */
struct EngineSoundsTable
{
	var AudioComponent EngineSound;
	var float RPM;
};

var array<EngineSoundsTable> EngineSounds;

simulated event PostBeginPlay()
{
	local EngineSoundsTable est;
	super.PostBeginPlay();
	SetAlarmSignal(AlarmSignal);
	est.EngineSound = NeutralRPMSound;
	est.RPM = 846;
	EngineSounds.AddItem(est);
	est.EngineSound = LowRPMSound;
	est.RPM = 1202;
	EngineSounds.AddItem(est);
	est.EngineSound = AverageRPMSound;
	est.RPM = 1943;
	EngineSounds.AddItem(est);
	est.EngineSound = HighRPMSound;
	est.RPM = 2684;
	EngineSounds.AddItem(est);

	//EngineSounds.AddItem(NeutralRPMSound);
	//EngineSounds.AddItem(LowRPMSound);
	//EngineSounds.AddItem(AverageRPMSound);
	//EngineSounds.AddItem(HighRPMSound);

	//neutralRPMRangeMin = 600;
	//neutralRPMRangeMax = 900;


}
simulated event Tick(float deltaSeconds)
{
	super.Tick(deltaSeconds);
	PlayEngineSound();
}
/** ������ �������� � ��������*/
exec simulated function Car_SetStarter(bool value)
{
	super.setStarter(value);
	//���� ������� ��������
	if (value && !StarterVehicleSound.IsPlaying())
	{
		//���� ���� ��� �� �������������, �����������
		StarterVehicleSound.Play();
	}
	//������� ���������
	else 
	{
		//���� ���� ��� �������������, ������������� ����
		if (StarterVehicleSound.IsPlaying())
			StarterVehicleSound.Stop();
	}
}
/** ����� ���������� */
exec simulated function Car_SwitchLeftTurn() 
{ 
	super.Car_SwitchLeftTurn();
	PlayTurnOrEmergencySound();
}
/** ������ ���������� */
exec simulated function Car_SwitchRightTurn()
{
	super.Car_SwitchRightTurn();
	PlayTurnOrEmergencySound();
}
/** ��������*/
exec simulated function Car_SwitchAlarmSignal()
{
	super.Car_SwitchAlarmSignal();
	PlayTurnOrEmergencySound();
}
simulated function Car_SetAlarmSignal(bool value)
{
	super.Car_SetAlarmSignal(value);
	PlayTurnOrEmergencySound();
}

/** ����������� ������ ������������ ��� �������� */
simulated function PlayTurnOrEmergencySound()
{
	/** ���� ��� �� ������� - �������� �����������*/
	if(LeftTurn || RightTurn || AlarmSignal)
	{
		//������ ������������� - �����������
		if(!TurnAndEmergencySignalSound.IsPlaying()) 
			TurnAndEmergencySignalSound.Play();
	}
	/** ��������*/
	else
	{
		//���� ����������� ����, ������������� � ����������� ���� ����������
		if (TurnAndEmergencySignalSound.IsPlaying())
		{
			TurnAndEmergencySignalSound.Stop();
			// ���� ���������� ������������ 
			PlaySound(TurnAndEmergencySignalSoundOff);
		}
	}
}
/** ������������� ��� ����� ���������. ���� ����� �� �� ��� ������������ - ���������� true */
function bool StopEngineSoundsPlaying()
{
	local EngineSoundsTable AudioComp;
	//����� �� ���� ������������
	local bool bIsPlayingSomeone;
	bIsPlayingSomeone = false;
	foreach EngineSounds(AudioComp)
	{
		if(AudioComp.EngineSound.IsPlaying())
		{
			AudioComp.EngineSound.Stop();
			bIsPlayingSomeone = true;
		}
	}
	//���� ��������� ������� , ������ ���� ������������� ��������� ���������
	return bIsPlayingSomeone;
}
//=========================================================================
// ����� �� ��� ������� ������ ����������� � ������ ����� ��������
/** ����������� ���� ��������� */
simulated function PlayEngineSound()
{
	/** �������� */
	local int i;
	/** ������ �����, ������� ���� ��������� */
	local int playableFirstSound;
	local int playableSecondSound;
	/** ������� ����� ���������� RPM */
	local float RPMDifference;
	/** �� ���� ��� */
	local float diffMax;
	local float diffMin;

	//��������� �� �������� (�� ������)
	if(FCarX.car.rpm==0)
	{
		//��� ����� ��������� ������
		//���� �� ����� ��������� �������, ����������� ���� �������� ���������
		if(StopEngineSoundsPlaying())
			EngineStopSound.Play();
	}

	if(FCarX.car.rpm!=0)
	{
		if( FCarX.car.rpm > EngineSounds[0].RPM && FCarX.car.rpm < EngineSounds[EngineSounds.Length-1].RPM)
		{
			//��������� 2 �������� �� �������� � �������� RPM �����
			for(i = 0;i<EngineSounds.Length;i++)
			{
				if(EngineSounds[i].RPM > FCarX.car.rpm)
				{
					playableFirstSound = i-1;
					playableSecondSound = i;
					break;
				}
			}
			RPMDifference = EngineSounds[playableSecondSound].RPM - EngineSounds[playableFirstSound].RPM;

			diffMax = EngineSounds[playableSecondSound].RPM - FCarX.car.rpm;
			diffMin = FCarX.car.rpm - EngineSounds[playableFirstSound].RPM;
			//???	
			EngineSounds[playableSecondSound].EngineSound.VolumeMultiplier = RPMDifference/diffMax;
			EngineSounds[playableFirstSound].EngineSound.VolumeMultiplier = RPMDifference/diffMin;

			EngineSounds[playableSecondSound].EngineSound.PitchMultiplier = FCarX.car.rpm/EngineSounds[playableSecondSound].RPM;
			EngineSounds[playableFirstSound].EngineSound.PitchMultiplier = FCarX.car.rpm/EngineSounds[playableFirstSound].RPM;

			if(!EngineSounds[playableFirstSound].EngineSound.IsPlaying())
				EngineSounds[playableFirstSound].EngineSound.Play();
			if(!EngineSounds[playableSecondSound].EngineSound.IsPlaying())
				EngineSounds[playableSecondSound].EngineSound.Play();
		}
		else
		{
			if(FCarX.car.rpm < EngineSounds[0].RPM)
			{
				playableFirstSound = 0;
				playableSecondSound=0;
				EngineSounds[playableFirstSound].EngineSound.VolumeMultiplier = 1.0;
			}
			else
			{
				playableFirstSound = EngineSounds.Length-1;
				playableSecondSound = playableFirstSound;
				EngineSounds[playableFirstSound].EngineSound.VolumeMultiplier = 5.0;
			}

			EngineSounds[playableFirstSound].EngineSound.PitchMultiplier = FCarX.car.rpm / EngineSounds[playableFirstSound].RPM ;

			if(!EngineSounds[playableFirstSound].EngineSound.IsPlaying())
				EngineSounds[playableFirstSound].EngineSound.Play();
		}

		for(i=0;i<EngineSounds.Length;i++)
		{
			if(i!=playableFirstSound && i!=playableSecondSound)
			{
				if(EngineSounds[i].EngineSound.IsPlaying())
					EngineSounds[i].EngineSound.Stop();
			}
		}
	
	}
}


function SetSirenaSignal(bool value)
{
	super.SetSirenaSignal(value);
	if (bSirenaSignal && !SirenaSound.IsPlaying())
		SirenaSound.Play();
	else
	{
		if(SirenaSound.IsPlaying())
			SirenaSound.Stop();
	}
}

DefaultProperties
{
	// ���� ��������
	Begin Object Class=AudioComponent Name=StarterVehicleOnSound
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_Starter_CUE'
	End Object
	StarterVehicleSound=StarterVehicleOnSound
	Components.Add(StarterVehicleOnSound);

	// ���� ���������� ������������
	Begin Object Class=AudioComponent Name=TurnAndEmergencySignalSoundClass
		SoundCue=SoundCue'Kamaz.Sounds.Povorotnik_Cue'
	End Object
	TurnAndEmergencySignalSound=TurnAndEmergencySignalSoundClass
	Components.Add(TurnAndEmergencySignalSoundClass);

	TurnAndEmergencySignalSoundOff=SoundCue'Kamaz.Sounds.Povorotnik_Off_Cue'

	// ���� c�����
	Begin Object Class=AudioComponent Name=SirenaOnSound
		SoundCue=SoundCue'Kamaz.Sounds.Sirena_Cue'
	End Object
	SirenaSound=SirenaOnSound
	Components.Add(SirenaOnSound);

	//=========================================================================
	// ����� ���������
	Begin Object Class=AudioComponent Name=NeutralRPM
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_1000RPM_CUE'
	End Object
	NeutralRPMSound=NeutralRPM
	Components.Add(NeutralRPM);

	Begin Object Class=AudioComponent Name=LowRPM
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_2500RPM_CUE'
	End Object
	LowRPMSound=LowRPM
	Components.Add(LowRPM);

	Begin Object Class=AudioComponent Name=AverageRPM
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_4000RPM_CUE'
	End Object
	AverageRPMSound=AverageRPM
	Components.Add(AverageRPM);

	Begin Object Class=AudioComponent Name=HighRPM
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_5500RPM_CUE'
	End Object
	HighRPMSound=HighRPM
	Components.Add(HighRPM);
	//��������� ���������
	Begin Object Class=AudioComponent Name=EngineStop
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_Stop_CUE'
	End Object
	EngineStopSound=EngineStop
	Components.Add(EngineStop);

	//=========================================================================
	// 
	

}
