class Forsage_PlayerCarSounded extends Forsage_PlayerCar;

/** Звук, проигрываемый при включении поворотников или аварийки */
var AudioComponent TurnAndEmergencySignalSound;
/** Звук, проигрвыемый при отключении повортников */
var SoundCue TurnAndEmergencySignalSoundOff;
//=========================================================================
// звуки двигателя
/** Звук на нейтральной передаче */
var AudioComponent NeutralRPMSound;
/** Звук на низких оборотах */
var AudioComponent LowRPMSound;
/** Звук на низких средних оборотах */
var AudioComponent AverageRPMSound;
/** Звук на высоких средних оборотах */
var AudioComponent HighRPMSound;
/** Звук остановки двигателя */
var AudioComponent EngineStopSound;


/** Звук сирены */
var AudioComponent SirenaSound;
/** Звук бибиклки */
var AudioComponent HooterSound;
/** Звук стартера */
var AudioComponent StarterSound;

var Forsage_Signals FS;
//var bool bTurLeft,bTurRight,bAlarmSignal;

var int neutralRPMRangeMin;
var int neutralRPMRangeMax;

var int lowRPMRangeMin;
var int lowRPMRangeMax;

var int averageRPMRangeMin;
var int RPMRangeMax;

/** Таблица соответствий оборотов двигателя и звука */
struct EngineSoundsTable
{
	var AudioComponent EngineSound;
	var float RPM;
};

var array<EngineSoundsTable> EngineSounds;

var bool bIsStarterOn;

simulated event PostBeginPlay()
{
	local EngineSoundsTable est;
	super.PostBeginPlay();
	est.EngineSound = NeutralRPMSound;
	//est.RPM = 0.1;
	//est.RPM = 846;
	est.RPM = 1000;
	EngineSounds.AddItem(est);
	est.EngineSound = LowRPMSound;
	//est.RPM = 0.3;
	//est.RPM = 1202;
	est.RPM = 2500;
	EngineSounds.AddItem(est);
	est.EngineSound = AverageRPMSound;
	//est.RPM = 0.5;
	est.RPM = 4000;
	EngineSounds.AddItem(est);
	est.EngineSound = HighRPMSound;
	//est.RPM = 1;
	est.RPM = 5500;
	EngineSounds.AddItem(est);

	TurnAndEmergencySignalSoundOff.VolumeMultiplier = 0.1;
	TurnAndEmergencySignalSound.VolumeMultiplier = 0.1;
	//EngineSounds.AddItem(NeutralRPMSound);
	//EngineSounds.AddItem(LowRPMSound);
	//EngineSounds.AddItem(AverageRPMSound);
	//EngineSounds.AddItem(HighRPMSound);

	//neutralRPMRangeMin = 600;
	//neutralRPMRangeMax = 900;

	//FC = Forsage_Controller(GetALocalPlayerController());
	
}

simulated event Tick(float deltaSeconds)
{
	//local InterpCurveFloat RPMCurve;

	super.Tick(deltaSeconds);
	
	PlayEngineSound();

	if(CS != none && ForsageSignals != none)
	{
		bTurnLeft = CS.GetLeftTurn();
		bTurnRight = CS.GetRightTurn();
		bAlarmSignal = CS.GetAlarmSignal();		

		/////////////////////////////////////////
		if (bSirenaSignal != ForsageSignals.GetSirenaSignal())
			PlaySirenaSignal(!bSirenaSignal);

		if(bHooterSignal!= ForsageSignals.GetHooterSignal())
			PlayHooterSignal(!bHooterSignal);
		
		PlayTurnOrEmergencySound();
	}
}

/** Запуск стартера с озвучкой*/
/*
exec simulated function Car_SetStarter(bool value)
{
}
*/

//========================================================
// Поворотники
/** Левый повототник */
exec simulated function Car_SwitchLeftTurn() 
{ 
	Super.Car_SwitchLeftTurn();
	PlayTurnOrEmergencySound();
}
/** Правый повототник */
exec simulated function Car_SwitchRightTurn()
{
	super.Car_SwitchRightTurn();
	PlayTurnOrEmergencySound();
}
/** Аварийка*/
exec simulated function Car_SwitchAlarmSignal()
{
	super.Car_SwitchAlarmSignal();
	PlayTurnOrEmergencySound();
}

exec simulated function Car_SwitchSirenaSignal()
{
	bSirenaSignal=!bSirenaSignal;
}
simulated function Car_SetAlarmSignal(bool value)
{
	super.Car_SetAlarmSignal(value);
	PlayTurnOrEmergencySound();
}

/** Проигрывает сигнал поворотников или аварийки */
simulated function PlayTurnOrEmergencySound()
{
	/** Если что то врубили - начинаем проигрывать*/
	if(bTurnLeft||bTurnRight|| bAlarmSignal)
	{
		//еслине проигрывается - проигрываем
		if(!TurnAndEmergencySignalSound.IsPlaying()) 
			TurnAndEmergencySignalSound.Play();
	}
	/** Вырубили*/
	else
	{
		//если проигрывали звук, останавливаем и проигрываем звук выключения
		if (TurnAndEmergencySignalSound.IsPlaying())
		{
			TurnAndEmergencySignalSound.Stop();
			// Звук выключения поворотников 
			PlaySound(TurnAndEmergencySignalSoundOff);
		}
	}
}
/** Останавливает все звуки двигателя. Если какой то из них проигрывался - возвращает true */
function bool StopEngineSoundsPlaying()
{
	local EngineSoundsTable AudioComp;
	//какой то звук проигрывался
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
	//если двигатель работал , значит надо проигратьзвук остановки двигателя
	return bIsPlayingSomeone;
}
//=========================================================================
/** Проигрывает звук двигателя */
simulated function PlayEngineSound()
{
	/** Итератор */
	local int i;
	/** индекс звука, который надо проиграть */
	local int playableFirstSound;
	local int playableSecondSound;
	/** Разница между ближайшими RPM */
	local float RPMDifference;
	/** ХЗ пока что */
	local float diffMax;
	local float diffMin;

	//двигатель не работает (мб заглох)
	if(EngineRPM == 0)
//	if(FCarX.car.rpm==0)
	{
		//все звуки двигателя глушим
		//если до этого двигатель работал, проигрываем звук осановки двигателя
		if(StopEngineSoundsPlaying())
			EngineStopSound.Play();
	}
	if(EngineRPM>0 || EngineRPM<0)
	//if(FCarX.car.rpm!=0)
	{
		if( EngineRPM > EngineSounds[0].RPM && EngineRPM < EngineSounds[EngineSounds.Length-1].RPM)
		//if( FCarX.car.rpm > EngineSounds[0].RPM && FCarX.car.rpm < EngineSounds[EngineSounds.Length-1].RPM)
		{
			//вычисляем 2 ближаших по значению к текущему RPM звука
			for(i = 0;i<EngineSounds.Length;i++)
			{
				if(EngineSounds[i].RPM > EngineRPM)
				//if(EngineSounds[i].RPM > FCarX.car.rpm)
				{
					playableFirstSound = i-1;
					playableSecondSound = i;
					break;
				}
			}
			RPMDifference = EngineSounds[playableSecondSound].RPM - EngineSounds[playableFirstSound].RPM;

			//diffMax = EngineSounds[playableSecondSound].RPM - FCarX.car.rpm;
			diffMax = EngineSounds[playableSecondSound].RPM - EngineRPM;
			//diffMin = FCarX.car.rpm - EngineSounds[playableFirstSound].RPM;
			diffMin = EngineRPM - EngineSounds[playableFirstSound].RPM;
			//???	
			EngineSounds[playableSecondSound].EngineSound.VolumeMultiplier = RPMDifference/diffMax;
			EngineSounds[playableFirstSound].EngineSound.VolumeMultiplier = RPMDifference/diffMin;

			//EngineSounds[playableSecondSound].EngineSound.PitchMultiplier = FCarX.car.rpm/EngineSounds[playableSecondSound].RPM;
			//EngineSounds[playableFirstSound].EngineSound.PitchMultiplier = FCarX.car.rpm/EngineSounds[playableFirstSound].RPM;
			EngineSounds[playableSecondSound].EngineSound.PitchMultiplier = EngineRPM/EngineSounds[playableSecondSound].RPM;
			EngineSounds[playableFirstSound].EngineSound.PitchMultiplier = EngineRPM/EngineSounds[playableFirstSound].RPM;



			if(!EngineSounds[playableFirstSound].EngineSound.IsPlaying())
				EngineSounds[playableFirstSound].EngineSound.Play();
			if(!EngineSounds[playableSecondSound].EngineSound.IsPlaying())
				EngineSounds[playableSecondSound].EngineSound.Play();
		}
		else
		{

			//if(FCarX.car.rpm < EngineSounds[0].RPM)
			if(EngineRPM < EngineSounds[0].RPM)
			{
				playableFirstSound = 0;
				playableSecondSound=0;
				EngineSounds[playableFirstSound].EngineSound.VolumeMultiplier = 3.0;
			}
			else
			{
				playableFirstSound = EngineSounds.Length-1;
				playableSecondSound = playableFirstSound;
				EngineSounds[playableFirstSound].EngineSound.VolumeMultiplier = 5.0;
			}

			//EngineSounds[playableFirstSound].EngineSound.PitchMultiplier = FCarX.car.rpm / EngineSounds[playableFirstSound].RPM ;
			//?????? ????? ???????? RPM
			if(EngineRPM <0)
				EngineSounds[playableFirstSound].EngineSound.PitchMultiplier = - EngineRPM / EngineSounds[playableFirstSound].RPM ;
			else
				EngineSounds[playableFirstSound].EngineSound.PitchMultiplier = EngineRPM / EngineSounds[playableFirstSound].RPM ;
	
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

//from keyboard
exec simulated function ChangeSirenaSignal(bool value)
{
	//super.setSirenaSignal(value);
	bSirenaSignal = !bSirenaSignal;
	//PlaySirenaSignal();
}
function PlaySirenaSignal(bool value)
{
	/*if (bSirenaSignal && !SirenaSound.IsPlaying())
		SirenaSound.Play();
	else
	{
		if(SirenaSound.IsPlaying())
			SirenaSound.Stop();
	}*/
	bSirenaSignal = value;
	if (value)
		SirenaSound.Play();
	else 
		SirenaSound.Stop();
}
//from keyboard
exec simulated function ChangeHooterSignal(bool value)
{
	//super.setHooterSignal(value);
	bHooterSignal = !bHooterSignal;
	PlayHooterSignal(bHooterSignal);
}
function PlayHooterSignal(bool value)
{
	bHooterSignal = value;
	if (value)
		HooterSound.Play();
	else 
		HooterSound.Stop();
}

function PlayStarterSignal(bool value)
{
	bIsStarterOn= value;
	if (value)
		StarterSound.Play();
	else 
		StarterSound.Stop();

}

simulated function ToggleEngine(bool value)
{
	super.ToggleEngine(value);
	if (value)
		StarterSound.Play();
}

DefaultProperties
{
	// Звук стартера

	Begin Object Class=AudioComponent Name=StarterSoundComp
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_Start_CUE'
	End Object
	StarterSound=StarterSoundComp
	Components.Add(StarterSoundComp);


	// Звук работающих поворотников
	Begin Object Class=AudioComponent Name=TurnAndEmergencySignalSoundClass
		SoundCue=SoundCue'Kamaz.Sounds.Povorotnik_Cue'
		
	End Object
	TurnAndEmergencySignalSound=TurnAndEmergencySignalSoundClass
	Components.Add(TurnAndEmergencySignalSoundClass);

	TurnAndEmergencySignalSoundOff=SoundCue'Kamaz.Sounds.Povorotnik_Off_Cue'

	// Звук cирены
	Begin Object Class=AudioComponent Name=SirenaOnSound
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Sirena_2_CUE'
	End Object
	SirenaSound=SirenaOnSound
	Components.Add(SirenaOnSound);

	//=========================================================================
	// звуки двигателя
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
	//остановка двигателя
	Begin Object Class=AudioComponent Name=EngineStop
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.SND_Priora_Engine_Stop_CUE'
	End Object
	EngineStopSound=EngineStop
	Components.Add(EngineStop);


	//========================================================================
	//
	Begin Object Class=AudioComponent Name=HooterSoundComp
		SoundCue=SoundCue'Car_Sounds_1.Sound_cues.Signal'
	End Object
	HooterSound=HooterSoundComp
	Components.Add(HooterSoundComp);



	//Begin Object Class=AudioComponent Name=StarterSoundComp
	//	SoundCue=SoundCue'Car_Sounds_1.Sound_cues.Sgnal'
	//End Object
	//StarterSound=StarterSoundComp
	//Components.Add(StarterSoundComp);

	//=========================================================================
	// 
	bSirenaSignal = false;	
	bTurnLeft = false;
	bTurnRight = false;
	bAlarmSignal = false;
	bHooterSignal = false;
}
