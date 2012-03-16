//(C) CarX Technology, 2012, carx-tech.com
#pragma once

#define CARX_VERSION 2.0


//only one edition define must be uncommented

//#define CARX_EDITION_PRO
//#define CARX_EDITION_STD
#define CARX_EDITION_LITE


#ifdef CARX_EDITION_LITE
//define for CarX Lite truck edition
//#define CARX_EDITION_LITE_TRUCK
#endif

#ifndef CARX_EDITION_LITE
#define CARX_EDITION_STD_OR_PRO
#endif

class ICXAutoRef{
public:
	ICXAutoRef();
	virtual int AddRef();
	virtual int Release();
protected:
	virtual ~ICXAutoRef();
private:
	int nRef;
};
