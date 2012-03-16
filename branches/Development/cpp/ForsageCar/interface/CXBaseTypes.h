//(C) CarX Technology, 2012, carx-tech.com

#pragma once

//3d vector
struct CX_Vector{
	float x,y,z;
};


//3d plane
struct CX_Plane{
  float d,x,y,z;
};


// 4 x 4 matrix as Direct3D or OpenGL matrices 
struct CX_Matrix{
	float m[16];
};


//inertia of a rigid body
//for cars it is logical to set only diagonal elements
struct CX_Inertia
{
	CX_Inertia(){
		Set(1,1,1);
	}
	void Set(float ixx,float iyy,float izz)
	{
		Ixx = ixx;
		Iyy = iyy;
		Izz = izz;
		Ixy = Ixz = Iyz = 0;
	}

	//inertia factors on different axes
	float Ixx,Ixy,Ixz,Iyy,Iyz,Izz;
};

//quaternion
struct CX_Quaternion{
  float x,y,z,w;
};


//this structure completely describes a rigid body
//it needs to be submitted to the car before each integration

struct CX_RB_DESC
{
  //weight of a body (200kg - 8000 kg)
  float m_mass;

  
  //inertia on each axis in range from 400 to 5000
  CX_Inertia m_local_inertia;

  //a world position of the center of weights
  //range on each of coordinates from-50000 to 50000
  //the matrix contains turn and carrying over
  //the rotary part should be orthonormal
  CX_Matrix m_global_position;

  //position of the center of weights in local coordinates of a body
  //range on each of coordinates of coordinates from-5 to 5
  CX_Vector m_local_center_mass;

  //speed of the center of weights in world c.s.
  //range on each of coordinates from-100 to 100
  CX_Vector m_global_velocity;

  //angular speed in world ñ.ê.
  //range on each of coordinates from-10 to 10
  CX_Vector m_global_angular_velocity;
};


class ICXMaterial;
class ICXRigidBodyHandler;


//structure RayTraceInfo stores in itself the information on beam trace
struct CX_RayTraceInfo {
  //a point of hit of a beam
  //range on each of coordinates from-50000 to 50000
  CX_Vector target;

  //a normal in it
  //range on each of coordinates from-1 to 1
  //the length should equal 1
  CX_Vector n;

  //the pointer to material class
  ICXMaterial *mat;

  //prbh - the information on hit of a beam and the interface of a firm body is filled - if the wheel has driven into dynamic object
  //that wheels "flung away" such subjects
  ICXRigidBodyHandler *prbh;

  //userdata - the data of the user information, for example a pool or not
  char userdata;
};
