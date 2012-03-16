//(C) CarX Technology, 2012, carx-tech.com

#pragma  once
#include "CXAutoRef.h"


//a physical material

class ICXMaterial : public ICXAutoRef{
public:
	enum Type{
		SURF_ASPHALT,
		SURF_GRASS,
		SURF_SAND,
		SURF_EARTH,
		SURF_SNOW,
		SURF_ICE,
		SURF_NUM
	};

	//to establish material type
	//type(Asphalt,Grass,Sand,Earth,Snow,Ice)
    virtual void SetStrType(const char *type)=0;
	virtual const char* GetStrType()const=0; 

	virtual void SetType(Type type)=0;
	virtual Type GetType()const=0; 

	virtual void SetFrictionMultiplier(float mult)=0;
	virtual float GetFrictionMultiplier()const=0;

	

	virtual void SetStatFric(float fric)=0;
	virtual void SetDynFric(float fric)=0;
	virtual void SetRestitution(float rest)=0;
	
	virtual void SetWheelRollFric(float fric)=0;
	
#ifdef CARX_EDITION_STD_OR_PRO
  virtual void SetBumpMin(float min)=0;
	virtual void SetBumpMax(float max)=0;
	virtual void SetBumpScale(float sc)=0;
#endif

	virtual float GetStatFric()const=0;
	virtual float GetDynFric()const=0;
	virtual float GetRestitution()const=0;
	virtual float GetWheelRollFric()const=0;
	virtual float GetBumpMin()const=0;
	virtual float GetBumpMax()const=0;
	virtual float GetBumpScale()const=0;
};
