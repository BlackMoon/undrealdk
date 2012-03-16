//(C) CarX Technology, 2012, carx-tech.com

#pragma once

#include "../ModuleDef.h"
#include "CXAutoRef.h"

#include "CXBaseTypes.h"
#include "CXMaterial.h"


class ICXWheel{
public:

 
  //emulation torn off or not active wheel
  virtual void Enable(bool)=0;
  virtual bool IsEnabled()const=0;

  //a multiplier for friction change
  //through it it is possible to feign change of a friction from deterioration, or heating
  //mult (0.3. 2)
	virtual void SetFrictionMultiplier(float mult)=0;
	virtual float GetFrictionMultiplier()const=0;

  //installation of additional rolling resistance 
  //will help to make the lowered wheels
  //fric (0. 0.5)
	virtual void SetAddRollFriction(float fric)=0;
	virtual float GetAddRollFriction()const = 0;

                 
#ifdef CARX_EDITION_STD_OR_PRO
  //a descent corner (in degrees, for the left and right wheels it is not necessary to change a sign for a minus)
  //val (-10. +10)
	virtual void SetToeIn(float val)=0;
	virtual float GetToeIn()const=0;
#endif


	
#ifdef CARX_EDITION_STD_OR_PRO
  //a camber angle (in degrees, for the left and right wheels it is not necessary to change a sign for a minus)
  //val (-10. +10)
	virtual void SetCamber(float val)=0;
	virtual float GetCamber()const=0;
#endif
	
  //caster angle (in degrees, for the left and right wheels it is not necessary to change a sign for a minus)
  //val (-10. +10)
	virtual void SetCaster(float val)=0;
	virtual float GetCaster()const=0;

	//steering distortion (in degrees)
	//val(-10..+10)
	virtual void SetAddSteerAngle(float ang)=0;
	virtual float GetAddSteerAngle()const=0;
	
  
#ifdef CARX_EDITION_PRO
  //wheel palpation, in meters
  //(-0.1..0.1)
  virtual void SetDeformOffset(float deform_offset)=0;
  virtual float GetDeformOffset()const=0;

  ///a corner of a curvature of an axis of a wheel, in degrees
  //(-30..30)
  virtual void SetDeformAngle(float deform_angle)=0;
  virtual float GetDeformAngle()const=0;
#endif


  
	
	

	//to establish the wheel middle in the uppermost position of a suspension bracket
  //in local car coordinate system
	virtual void SetTopPos(const CX_Vector &pos)=0;
	virtual void GetTopPos(CX_Vector & )const=0;

	//wheel radius(in meters) 
	//r(0.2..0.9)
	virtual void SetRadius(float r)=0;
  virtual float GetRadius()const=0;

  
  //setting car weights (kg)
  //mass (20. 150)
  virtual void SetMass(float mass)=0;
  virtual float GetMass()const=0;




  
#ifdef CARX_EDITION_STD_OR_PRO
  //pressure of the tire (in newton/(meters*meters))
  virtual void SetTyrePressure(float c)=0;
  virtual float GetTyrePressure()=0;
#endif
  
	//length of a spring (in meters)
	virtual void SetMaxSpringLen(float l)=0;
	virtual float GetMaxSpringLen()const=0;
 //rigidity of a spring (in н/м)
	virtual void SetSpringCoef(float c)=0;
	virtual float GetSpringCoef()const=0;


  //manually setup a roll angle (in radians)
  virtual void SetRollAngle(float ang)=0;
  //get roll angle (in radians)
  virtual float GetRollAngle()const=0;

//#ifdef CARX_EDITION_LITE
  //rigidity of shock absorber (in n*s/m)
	virtual void SetAbsorbCoef(float c)=0;
	virtual float GetAbsorbCoef()const=0;
//#endif	

 	


 
#ifdef CARX_EDITION_STD_OR_PRO
  //rigidity of shock absorber (in n*s/m)
  virtual void SetSlowBump(float c)=0;
  virtual void SetFastBump(float c)=0;
  virtual void SetSlowRebound(float c)=0;
  virtual void SetFastRebound(float c)=0;

  virtual float GetSlowBump()=0;
  virtual float GetFastBump()=0;
  virtual float GetSlowRebound()=0;
  virtual float GetFastRebound()=0;
#endif	
 

	

  //to mark wheel to be left or right?
	virtual void SetLeftHanded(bool isLeft)=0;
	virtual bool GetLeftHanded()=0;

	virtual void SetSteerLimits(float smin,float smax)=0;

	//to establish a back wheel or forward?
	virtual void SetRearFlag(int rear)=0;
	//to receive a wheel matrix (for the left wheels will give the reflected matrix)
	virtual void GetMatrix(CX_Matrix &m)const=0;

  virtual void GetQuaternionAndPos(CX_Quaternion &q, CX_Vector &pos)=0;


 
	//to return loudness of sliding
	//от 0 до 2
	virtual float GetSkidVolume()const=0;
	//Whether to start up a smoke?
	virtual bool GetSmoke()const=0;
	
	//to receive angular speed (radians per second)
	virtual float GetW()const=0;

	
	
	//speed of a smoke relative the car body
	virtual void GetSmokeVel(CX_Vector & vel)const=0;

	//Whether there is a contact to road
	virtual bool HasPatch()const=0;

	//to receive area of contact to road (will help for smoke traces)
  //return - 1 if is contact 0 - if isn't present
  //if is, functions saves down 
  //left - patch left-hand side
  //right - the right party of a patch
  //cnt - the patch middle
  //n - a contact normal
	virtual bool GetPatch(CX_Vector &left,CX_Vector &right,CX_Vector &cnt,CX_Vector &n)=0;
  virtual bool GetMarkPatch(CX_Vector &left,CX_Vector &right,CX_Vector &cnt,CX_Vector &n)=0;
  

	//to receive a material of a surface of contact
	virtual ICXMaterial *GetPatchMaterial()=0;


#ifdef CARX_EDITION_STD_OR_PRO
	//the moment on a wheel
	virtual float GetAlignMom()const=0;
#endif

	//longitudinal force
	virtual void GetLongForce(CX_Vector &)const=0;
	//lateral force
	virtual void GetLatForce(CX_Vector &)const=0;
	//vertical force
	virtual void GetVertForce(CX_Vector &)const=0;

  //to obtain the data which were filled from ray tracer
  //true - if the wheel contact a surface
  virtual bool GetUserData(int &userdata)const=0;

  

	virtual float GetSAVol()const=0;
	virtual float GetSRVol()const=0;

	virtual float GetSA()const=0;
	virtual float GetSR()const=0;
	
	virtual float GetW0()const=0;

	    
	virtual float GetBestSlipAngle()const=0;
	virtual float GetBestSlipRatio()const=0;
	
       
	virtual float GetCurCamber()const=0;
	virtual int IsStaticMode()const=0;

#ifdef CARX_EDITION_PRO
  virtual bool GetDeform(CX_Vector &cnt,CX_Vector &lat_deform_vec,CX_Vector &long_deform_vec,CX_Plane &vert_deform_plane)=0;
#endif


 
  //You must call these 2 functions GetRay and SetRayRes for  each active wheel of each active car 
  //before  calling  ICarXManager->Update()

  //returns a ray on which it is necessary to make trace
  //can return false, if  wheel is not  active
  //!!! DO NOT FORGET to exclude from object list this car and it ` s wheels while raytracing
  virtual bool GetRayTracePoints (CX_Vector &p1, CX_Vector &p2) =0;
       
  //You must call this function to establish result of external ray tracing, 
  //Ray traced from start to end point of ray that was read fron  GetRayTracePoints function
  //res = true - if the beam has reached without hindrances
  //res = false - if the beam hit scene (then  other parameters are filled)
  //userdata - the data of the user, for example a pool or not
  virtual void SetRayTraceRes(bool res,const CX_RayTraceInfo &rti)=0;
};




class ICXCar :public ICXAutoRef
{
	
public:
  //calculate car inertia based on mass and car dimensions
  //car_width (0.5..20) car_height (0.5..20)  car_length (0.5..20) 
  virtual void CalcInertia(float mass,float car_width,float car_height,float car_length,CX_Inertia &car_inertia)=0;

  //calculate car center of mass in local space based on Car AABB (Axis aligned bounding box in local space)
  //and right_percent(0..100) , front_percent(0..100) , top_percent(0..100)  
  virtual void CalcCenterMassLocalSpace(float right_percent,float front_percent, float top_percent, 
    const CX_Vector &box_min_loc,const CX_Vector &box_max_loc, CX_Vector &cm_local)=0;

  virtual void GetVelocity(CX_Vector &vel)const=0;
  virtual void GetAngularVelocity(CX_Vector &w)const=0;
  
#ifdef CARX_EDITION_STD_OR_PRO
  //стартер
  virtual void SetStarter(float vol)=0;
  virtual float GetStarter()const=0;
  virtual bool IsEngineWorks()const=0;
  
  virtual void SetEngineCutRPM(float rpm)=0;
  virtual float GetEngineCutRPM()const=0;
#endif

  virtual void SetEngineIdleRPM(float rpm)=0;
  virtual float GetEngineIdleRPM()const=0;

  virtual void SetActive(bool active)=0;
  virtual bool GetActive()const=0;

  //speed in kilometers per hour
  virtual float GetSpeedKMH()const=0;
  
  //speed in miles per hour
  virtual float GetSpeedMPH()const=0;

  //speed in meters per second
  virtual float GetSpeedMPS()const=0;

  
	//get wheel by id
	virtual ICXWheel* GetWheel(UINT id)=0;

  //set rigid body parameters before integration
	virtual void SetRigidBody(CX_RB_DESC &rb)=0;
 
	//call to receive impulses after integration, then put them to a rigid body object in your engine
	virtual void GetTotals(CX_Vector &Fdt,CX_Vector &MFdt)const=0;
	


	//Quantity of integration steps of the car
	//steps(5..20)
	virtual void SetIntegrationSteps(int steps)=0;
	virtual int GetIntegrationSteps()const=0;


#ifdef CARX_EDITION_STD_OR_PRO
  //quality of physics at car integration
  //true/false
  virtual void SetSimModeSimple(bool simple)=0; 
  virtual bool GetSimModeSimple()const=0; 
#endif

  //to establish an angle of rotation of forward wheels
  //ang (-pi/4. +pi/4)
	virtual void SetSteerAngle(float ang)=0;
	virtual float GetSteerAngle()const=0;

  //pressing on accelerate pedal
  //val (0. 1)
	virtual void SetAccel(float val)=0;
	virtual float GetAccel()const=0;

	//pressing on clutch
	//val(0..1)
	virtual void SetClutch(float val)=0;
	virtual float GetClutch()const=0;

	//shift gears
	//n(-1..6)   -lite
  //n(-1..25)   -std and pro
	virtual void SetGear(int n)=0;
	virtual int GetGear()const=0;

	//pressing brake pedal
	//val(0..1)
	virtual void SetBrake(float val)=0;
	virtual float GetBrake()const=0;

	//handbrake pressing level
	//val(0..1)
	virtual void SetHandBrake(float val)=0;
	virtual float GetHandBrake()const=0;

	//manually set car engine RPMs   (revolutions per minute)
	//val(0..10000)
	virtual void SetRPM(float rpm)=0;
 	virtual float GetRPM()const =0;

  //stops rotation of differentials and wheels
  //it is useful to dump a scene condition in the initial
  virtual void ResetTransmission()=0;
	
	//shift down and up gear
 	virtual void GearUp()=0;
	virtual void GearDown()=0;
  virtual bool IsShifting()const=0;

	//gear ratious 
	//num(0..6)   -lite 
  //num(0..25) - std and pro
	//val(0.1,5)
	virtual void SetGearRatio(int num,float val)=0;
	virtual float GetGearRatio(int num)const=0;

	//the main pair
	//val(1..10)
	virtual void SetFinaldrive(float val)=0;
	virtual float GetFinaldrive()const=0;

	//quantity of gears
	//val(4..6)   - lite
  //val(4..25)   -std and pro
	virtual void SetNumGears(int val)=0;
	virtual int GetNumGears()const=0;



	

	//RPM at which the auto gear box switches upward
	//rpm(4500..8000)
	virtual void SetGearBoxUpLimitRPM(float rpm)=0;
	virtual float GetGearBoxUpLimitRPM()const=0;
  //RPM at which the auto gear box switches down
	//rpm(3000..4000)
	virtual void SetGearBoxDownLimitRPM(float rpm)=0;
	virtual float GetGearBoxDownLimitRPM()const=0;
  
  //numbering of wheels
  //CarX should know, under what numbers you identify
  //forward and back wheels
  //1-rd wheel axis (up to 2 wheels)
  virtual void SetFront(int id_left,int id_right)=0;
	virtual void GetFront(int &id_left,int &id_right)const=0;
  //2-rd wheel axis (up to 4 wheels)
	virtual void SetRear(int id_left,int id_right)=0;
	virtual void GetRear(int &id_left,int &id_right)const=0;

#ifdef CARX_EDITION_STD_OR_PRO
  //3-rd wheel axis (up to 6 wheels)
  virtual void SetRear1(int id_left,int id_right)=0;
  virtual void GetRear1(int &id_left,int &id_right)const=0;

  //4-rd wheel axis (up to 8 wheels)
  virtual void SetRear2(int id_left,int id_right)=0;
  virtual void GetRear2(int &id_left,int &id_right)const=0;
#endif

	//to receive load (0. 1)
  //will help for a engine sound simulation
 	virtual float GetLoad()const=0;

  //body acceleration
	virtual float GetLongAccel()const=0;
	virtual float GetSideAccel()const=0;
	virtual float GetVertAccel()const=0;
	virtual float GetAngAccel()const=0;

#ifdef CARX_EDITION_STD_OR_PRO
	virtual float GetSteerAlignMom()const=0;
#endif

  //rigidity of stabilizers
  //coef (0. 50000)
   	virtual void SetFrontStabSpringCoef(float coef)=0;
	virtual float GetFrontStabSpringCoef()const=0;

	virtual void SetRearStabSpringCoef(float coef)=0;
	virtual float GetRearStabSpringCoef()const=0;


  
	//drive type
	//type(fwd,rwd,4wd)
	enum GearType{
    GEAR_0WD,
		GEAR_FWD,
		GEAR_RWD,
		GEAR_4WD,

#ifdef CARX_EDITION_STD_OR_PRO
    GEAR_AWD,
    GEAR_4WDR1,
    GEAR_4WDR2,
#endif
#ifdef CARX_EDITION_LITE_TRUCK
    GEAR_4WDR1,
    GEAR_4WDR2,
#endif
#ifdef CARX_EDITION_PRO
    GEAR_6WD,
    GEAR_6WDR2,
    GEAR_8WD,
#endif
  	//and total number of gear types
		GEAR_NUM
	};

  enum{
    
  };

	virtual void SetGearType(GearType)=0;
	virtual GearType GetGearType()const=0;


  //gearbox type
	//type(auto,manual)
	enum GearShiftType{
		SHIFT_AUTO,
		SHIFT_MANUAL,
		//and total number of gearbox types
		SHIFT_NUM
	};
	virtual void SetGearShifting(GearShiftType type)=0;
	virtual GearShiftType GetGearShifting()const=0;

  //type of tires
		
	enum TyreType{
    TYRE_SPORT,
    TYRE_RACING,
#ifdef CARX_EDITION_STD_OR_PRO
    TYRE_ALLSEASON,
		TYRE_DRAG,
		TYRE_SNOW,
#endif
		//and total number
		TYRE_NUM
	};   

 	//tyre width(160..345 sm)
	virtual void SetFrontTyreType(TyreType type,float width,float prof)=0;
	virtual TyreType GetFrontTyreType()const=0;
  
	virtual void SetRearTyreType(TyreType type,float width,float prof)=0;
	virtual TyreType GetRearTyreType()const=0;


#ifdef CARX_EDITION_STD_OR_PRO
  //3rd axis 
  virtual void SetRear1TyreType(TyreType type,float width,float prof)=0;
  virtual TyreType GetRear1TyreType()const=0;
  //4rd axis 
  virtual void SetRear2TyreType(TyreType type,float width,float prof)=0;
  virtual TyreType GetRear2TyreType()const=0;
#endif

  //reception of width and a profile
  //(0-100%)
  virtual float GetFrontTyreProfile()const=0;
  virtual float GetRearTyreProfile()const=0;
  //(165-355sm)          
  virtual float GetFrontTyreWidth()const=0;
  virtual float GetRearTyreWidth()const=0;


  //suspension bracket type
  enum SuspensionType{
    SUSP_MCFERSON,
   #ifdef CARX_EDITION_STD_OR_PRO
    SUSP_DEPENDENT,
    SUSP_DOUBLEWISHBONE,
   #endif
    SUSP_NUM
  };
  virtual void SetFrontSuspensionType(SuspensionType type)=0;
  virtual SuspensionType GetFrontSuspensionType()const=0;

  virtual void SetRearSuspensionType(SuspensionType type)=0;
  virtual SuspensionType GetRearSuspensionType()const=0;

 
	

	//use ABS
	//use(0..1)
	virtual void SetABS(int use)=0;
	virtual int GetABS()const=0;
	
	//setup Traction Control
	//use(0..1)
	virtual void SetTC(int use)=0;
	virtual int GetTC()const=0;


	


  //to Establish the rev limiter
  //rev(4000..15000)
  virtual void SetEngineRevLimiter(float rev)=0;
  virtual float GetEngineRevLimiter()const=0;
  
#ifndef  CARX_EDITION_LITE
  virtual void SetEngineTurboParams(float max_turbo_pressure)=0;
  virtual void GetEngineTurboParams(float &max_turbo_pressure,float &cur_turbo_pressure,float &blowoff)=0;
#endif

	


  //!!!Dont use this function if you want to set engine torque curve with samples 
  //Max engine torque on rpm
  //tor(10..900)   rpm(4000..7000)
  virtual void SetEngineMaxTorque(float tor, float rpm)=0;
	

  //!!!Use those 3 functions if you want to set engine torque curve with samples 
  //Setup Engine Torque Curve
  //CarX Lite - 4 samples max
  //CarX Std - 16 samples max
  //CarX Pro - 32 samples max
  virtual void SetEngineTorqueCurveNumSamples(int nsamples)=0;
  //i(0..nsamples-1)
  virtual void SetEngineTorqueCurveSample(int i, float rpm, float tor)=0;
  //call it after all samples are set
  virtual void SetEngineTorqueCurveFinalize()=0;
  

  virtual float GetEngineMaxTorque()const=0;
  virtual float GetEngineMaxTorqueRPM()const=0;


  //the current rotary moment of the engine (N*m)
  virtual float GetEngineCurTorque()const=0;
  //current power of the engine (h.p)
  virtual float GetEngineCurPower()const=0;

  //current power on wheels (w.h.p)
  virtual float GetEngineCurWHP()const=0;

	//the total moment of brakes
	//tor(0..3000) 
	virtual void SetBrakeTorque(float tor)=0;
	virtual float GetBrakeTorque()const=0;


	//balance of brakes
 //fr_perc (0. 1)
 //0 - back wheels brake only
 //1 - forward wheels brake only
	virtual void SetBrakeFrontBalance(float fr_perc)=0;
	virtual float GetBrakeFrontBalance()const=0;

	//blocking diff
	//coef(0..100)
  virtual void SetViscoDiffCoef(float coef)=0;
	virtual float GetViscoDiffCoef()const=0;
  	
     

#ifndef  CARX_EDITION_LITE
	//effect of Akkerman
  //val (0. 1)
  //at value 1 forward wheels are parallel each other
  //at value 0 forward wheels turn as at the usual car
	virtual void SetAckerman(float val)=0;
	virtual float GetAckerman()const=0;
#endif

	//front resistance Cx coef
	//val(0..1)
	virtual void SetAeroCx(float val)=0;
	virtual float GetAeroCx()const=0;

	//the area of front resistance
	//s(0..5) m^2
	virtual void SetAeroSx(float s)=0;
	virtual float GetAeroSx()const=0;





#ifndef  CARX_EDITION_LITE
	//vertical force on front (in kg) for the speed in 100 km/h
	virtual void SetAeroFrontDownforce(float)=0;
	virtual float GetAeroFrontDownforce()const=0;

	//vertical force on back (in kg) for the speed in 100 km/h
	virtual void SetAeroRearDownforce(float)=0;
	virtual float GetAeroRearDownforce()const=0;
#endif

  //if you use preservation a game condition, or 
  //integration with the fixed step, that is possibility to keep
  //a condition of cars and to do interpolation
  //the size of the buffer won't exceed 4096 byte
  virtual void GetDynState(void **pbuff,int *size)=0;
  virtual void SetDynState(void *buff,int size)=0;
  virtual void StoreToPrevState()=0;
	virtual void BackUpFromPrevState()=0;
  virtual void StoreToLastState()=0;
  virtual void BackUpFromLastState()=0;
  virtual void LerpPrevLastState(float t,float total_step)=0;

};


//the interface of management car by buttons
class ICXCarController{
public:
	//to attach the car to the assistant
 //max_ang (0. pi/4) the maximum angle of rotation of wheels
 //cur_ang (-pi/4. pi/4) a current angle of rotation of wheels
	virtual void AttachCar(ICXCar *,float max_ang,float cur_ang)=0;
	
  //calculate action of the assistant
  //par (-1. 1) where to steer the wheel - to the right or to the left
  //dt (0. 0.02sec) time step
	virtual void Steer(float par,float dt)=0;

	//steer a wheel on parameter
  //par (-1. 1)
  //here the assistant doesn't helps, and simply turns wheels
	virtual void SteerAbsoluteParam(float par)=0;

	//after call Steer or SteerAbsoluteParam
  //it is possible to get an angle of rotation of wheels in radians
	virtual float GetSteerAng()const =0;
};


//the interface of cameras
class ICXCarCamera {
public:
  //to attach the camera to the car
  virtual void AttachCar (ICXCar *) =0;
  //receive a camera matrix 
  virtual void GetMatrix (CX_Matrix &m) const=0;
  //the camera behind the car (by default)
  virtual void SetTypeRear () =0; 

#ifdef CARX_EDITION_STD_OR_PRO
  //the camera autodirecting
  virtual void SetTypeAuto () =0; 
  //an eye for it
  virtual void SetAutoEye (const CX_Vector &eye) =0;
  //to receive the vertical field of view (autocamera), degrees 
  virtual float GetAutoFOVy () const=0;
  //to receive a near plane of a projective matrix (autocamera)
  virtual float GetAutoZNear () const=0;
#endif



  //update the camera
  //for prevention of discrete movements camera, it is possible to submit an external matrix of the car
  //if mat = 0 the matrix will undertake from physics
  virtual void Update (float dt, const CX_Matrix *mat, const CX_Vector *vel) =0;



};

class ICXRigidBodyHandler{
public:
	virtual void AddImpulse(const CX_Vector &Fdt,const CX_Vector &MFdt)=0;
};




//car manager - stores all cars and calculates them with Update function
class ICXManager{
public:   
	//get controller (for key steering)
	virtual ICXCarController *GetCarController() = 0 ;
  
	//get camera interface
	virtual ICXCarCamera *GetCarCamera() = 0 ;

	//create car object, reference stored in manager and in returned pointer
  //so you need to call ICXManager->DeleteCar and ICXCAR->Release when you destroy a car
	virtual ICXCar* CreateCar()=0;

	//add car to simulation
	virtual void AddCar(ICXCar *c)=0;
	//remove car from simulation
	virtual void DeleteCar(ICXCar *c)=0;

	//create material
	virtual ICXMaterial* CreateMaterial()=0; 


 
	//update all carx - call it in game loop
	virtual void Update(float dt)=0;
	
	//recalc only wheel matrices
	virtual void UpdateWheels(float dt)=0;
	//set gravity for all cars
  //!! you need to turn off gravity from cars objects in your engine
  //otherwise there will be doudbe gravity
	virtual void SetGravity(const CX_Vector &grav)=0;

	
	//set coordinate system
	//right - vector from left to right car side
	//front  - vector from rear to front car side
  //top  - vector from var bottom to car top(roof)
	virtual void SetCoordSys(const CX_Vector &right,const CX_Vector &front,const CX_Vector &top)=0; 
  
  //switch between CarX Standard and CarX Extended for sample
  virtual void SetExtendedMode(bool ext)=0; 
  virtual bool GetExtendedMode()=0; 

};



//the global function, giving car manager 
CARX_API ICXManager * CXGetManager();


