#ifndef __GAME_MATH_H__
#define __GAME_MATH_H__

#include <memory.h>
#include <cmath>
#include <math.h>

#ifndef EPS
#define EPS 1e-6
#endif // EPS

#ifndef FEQ
#define FEQ(a,b) (fabs((a)-(b))<EPS)
#define FEQU(a,b) (fabs((a)-(b))<EPS)
#define FNEQ(a,b) (fabs((a)-(b))>EPS)
#define FNEQU(a,b) (fabs((a)-(b))>EPS)
#endif // FEQ

#ifndef SWAP
#define SWAP(a,b,t) {t=a;a=b;b=t;}
#endif // SWAP

#ifndef MIN
#define MIN(a,b) (a<b?a:b)
#define MAX(a,b) (a>b?a:b)
#endif // MIN

#ifndef M_PI
#define M_PI 3.1415926535f
#endif
#define SQRT2 1.4142135623f

template <class T>
T sqr ( T a )
{ return a*a; }

//////////////////////////////////////////////////////////////////////
//                                                                  //
// interface for the Vector2D class.                                //
//                                                                  //
//////////////////////////////////////////////////////////////////////

class Vector2D  // Vector class
{
   float max2 ( float a, float b ) const
   {
      return (a>b?a:b);
   }
public:
   float x, y; // cartesian coordinates

   Vector2D() {} // default constructor
   // construct from 3 coords
   Vector2D ( float px, float py )
      : x ( px )
      , y ( py )
   {
      // intentionally left blank
   }
   // copy constructor
   Vector2D ( Vector2D const& v )
      : x ( v.x )
      , y ( v.y )
   {
      // intentionally left blank
   }

   // assignment operator
   Vector2D& operator = ( Vector2D const v )
   {
      x = v.x;
      y = v.y;
      return *this;
   }

   // positive self ( use like +v )
   Vector2D operator + () const
   {
      return *this; // does nothing
   }
   // negative self ( use like -v )
   Vector2D operator - () const
   {
      return Vector2D ( -x, -y );
   }

   // add to itself
   Vector2D& operator += ( Vector2D const& v )
   {
      x += v.x;
      y += v.y;
      return *this;
   }
   // subtract from itself
   Vector2D& operator -= ( Vector2D const& v )
   {
      x -= v.x;
      y -= v.y;
      return *this;
   }
   // multiply by scalar
   Vector2D& operator *= ( float f )
   {
      x *= f;
      y *= f;
      return *this;
   }
   // divide by scalar
   Vector2D& operator /= ( float f )
   {
      x /= f;
      y /= f;
      return *this;
   }

   // coord number <index> ( after all vector is just another form of an array )
   float& operator [] ( int index )
   {
      return * ( &x + index );
   }

   // conditions
   bool operator == ( Vector2D const& v ) const
   {
      return FEQ ( x, v.x ) && FEQ ( y, v.y );
   }
   bool operator != ( Vector2D const& v ) const
   {
      return FNEQ ( x, v.x ) || FNEQ ( y, v.y );
   }

   // conversion - use like *v = c ( same as v.x = c )
   operator float* ()
   {
      return &x;
   }
   operator float const* () const
   {
      return &x;
   }

   // various functions
   float length () const
   {
      return (float) sqrt ( sqr ( x ) + sqr ( y ) );
   }
   float lengthSq () const // return length^2, works faster than the previous one
                            // because it doesn't retrieve square root
   {
      return sqr ( x ) + sqr ( y );
   }
   float lengthFast () const // return length, uses special formula to retrieve sqrt
                              // works faster, but lower quality ( 8% error )
   {
      int temp;  // used for swaping
      int x1,y1,z1; // used for algorithm

      // make sure values are all positive
      x1 = int ( fabs(x) * 1024 );
      y1 = int ( fabs(y) * 1024 );
      z1 = 0;

      // sort values
      if (y1 < x1) SWAP(x1,y1,temp);
      if (z1 < y1) SWAP(y1,z1,temp);
      if (y1 < x1) SWAP(x1,y1,temp);

      int dist = (z1 + 11 * (y1 >> 5) + (x1 >> 2) );

      // compute distance with 8% error
      return ( (float)(dist) ) * ( 1/1024 );
   }
   float lengthMax () const // HUGE error, but really fast
   {
      return max2 ( (float) fabs (x), (float) fabs (y) );
   }

   Vector2D& normalize ()
   {
      return (*this) /= length ();
   }

   float distanceToSq ( Vector2D const& p ) const // distance between vector's endpoints ( squared )
   {
      return sqr ( x - p.x ) + sqr ( y - p.y );
   }
   float distanceTo ( Vector2D const& p ) const // distance between vector's endpoints
   {
      return (float) sqrt ( sqr ( x - p.x ) + sqr ( y - p.y ) );
   }

//   Vector2D& ort () const // return a vector orthogonal to this ( one of them )
//   {
//      return Vector2D ( I DON'T KNOW HOW TO DO THIS );
//   }

   // binary functions
   friend Vector2D operator + ( Vector2D const& a, Vector2D const& b )
   {
      return Vector2D ( a.x + b.x, a.y + b.y );
   }
   friend Vector2D operator - ( Vector2D const& a, Vector2D const& b )
   {
      return Vector2D ( a.x - b.x, a.y - b.y );
   }
   friend float operator * ( Vector2D const& a, Vector2D const& b )
      // dot product
   {
      return a.x*b.x + a.y*b.y;
   }
   friend Vector2D operator * ( Vector2D const& a, float b )
   {
      return Vector2D ( a.x*b, a.y*b );
   }
   friend Vector2D operator * ( float a, Vector2D const& b )
   {
      return Vector2D ( b.x*a, b.y*a );
   }
   friend Vector2D operator / ( Vector2D const& a, float b )
   {
      return Vector2D ( a.x/b, a.y/b );
   }
   friend Vector2D operator / ( float a, Vector2D const& b )
   {
      return Vector2D ( b.x/a, b.y/a );
   }
};

//////////////////////////////////////////////////////////////////////
//                                                                  //
// interface for the Matrix4D class.                                //
//                                                                  //
//////////////////////////////////////////////////////////////////////

class Matrix4D;

class Vector3D  // Vector class
{
   float max3 ( float a, float b, float c ) const
   {
      return (a>b?(a>c?a:c):(b>c?b:c));
   }
public:
   float x, y, z; // cartesian coordinates

   Vector3D() {} // default constructor
   // construct from 3 coords
   Vector3D ( float px, float py, float pz )
      : x ( px )
      , y ( py )
      , z ( pz )
   {
      // intentionally left blank
   }
   // copy constructor
   Vector3D ( Vector3D const& v )
      : x ( v.x )
      , y ( v.y )
      , z ( v.z )
   {
      // intentionally left blank
   }

   // assignment operator
   Vector3D& operator = (Vector3D const& v )
   {
      x = v.x;
      y = v.y;
      z = v.z;
      return *this;
   }

   // positive self ( use like +v )
   Vector3D operator + () const
   {
      return *this; // does nothing
   }
   // negative self ( use like -v )
   Vector3D operator - () const
   {
      return Vector3D ( -x, -y, -z );
   }

   // add to itself
   Vector3D& operator += ( Vector3D const& v )
   {
      x += v.x;
      y += v.y;
      z += v.z;
      return *this;
   }
   // subtract from itself
   Vector3D& operator -= ( Vector3D const& v )
   {
      x -= v.x;
      y -= v.y;
      z -= v.z;
      return *this;
   }
   // multiply by scalar
   Vector3D& operator *= ( Vector3D const& v )
   {
      x *= v.x;
      y *= v.y;
      z *= v.z;
      return *this;
   }
   // multiply by scalar
   Vector3D& operator /= ( Vector3D const& v )
   {
      x *= v.x;
      y *= v.y;
      z *= v.z;
      return *this;
   }
   // multiply by scalar
   Vector3D& operator *= ( float f )
   {
      x *= f;
      y *= f;
      z *= f;
      return *this;
   }
   // divide by scalar
   Vector3D& operator /= ( float f )
   {
      x /= f;
      y /= f;
      z /= f;
      return *this;
   }

   // coord number <index> ( after all vector is just another form of an array )
   float& operator [] ( int index )
   {
      return * ( &x + index );
   }

   // conditions
   bool operator == ( Vector3D const& v ) const
   {
      return FEQ ( x, v.x ) && FEQ ( y, v.y ) && FEQ ( z, v.z );
   }
   bool operator != ( Vector3D const& v ) const
   {
      return FNEQ ( x, v.x ) || FNEQ ( y, v.y ) || FNEQ ( z, v.z );
   }

   // conversion - use like *v = c ( same as v.x = c )
   operator float* ()
   {
      return &x;
   }
   operator float const* () const
   {
      return &x;
   }

   // various functions
   float length () const
   {
      return (float) sqrt ( sqr ( x ) + sqr ( y ) + sqr ( z ) );
   }
   float lengthSq () const // return length^2, works faster than the previous one
                            // because it doesn't retrieve square root
   {
      return sqr ( x ) + sqr ( y ) + sqr ( z );
   }
   float lengthFast () const // return length, uses special formula to retrieve sqrt
                              // works faster, but lower quality ( 8% error )
   {
      int temp;  // used for swaping
      int x1,y1,z1; // used for algorithm

      // make sure values are all positive
      x1 = int ( fabs(x) * 1024 );
      y1 = int ( fabs(y) * 1024 );
      z1 = int ( fabs(z) * 1024 );

      // sort values
      if (y1 < x1) SWAP(x1,y1,temp);
      if (z1 < y1) SWAP(y1,z1,temp);
      if (y1 < x1) SWAP(x1,y1,temp);

      int dist = (z1 + 11 * (y1 >> 5) + (x1 >> 2) );

      // compute distance with 8% error
      return ( (float)(dist) ) * ( 1/1024 );
   }
   float lengthMax () const // HUGE error, but really fast
   {
	  return max3 ( (float) fabs (x), (float) fabs (y), (float) fabs (z) );
   }

   Vector3D& normalize ()
   {
	  if (length () == 0) {
		return (*this);
	  }
	  return (*this) /= length ();
   }

   float distanceToSq ( Vector3D const& p ) const // distance between vector's endpoints ( squared )
   {
      return sqr ( x - p.x ) + sqr ( y - p.y ) + sqr ( z - p.z );
   }
   float distanceTo ( Vector3D const& p ) const // distance between vector's endpoints
   {
      return (float) sqrt ( sqr ( x - p.x ) + sqr ( y - p.y ) + sqr ( z - p.z ) );
   }

//   Vector3D& ort () const // return a vector orthogonal to this ( one of them )
//   {
//      return Vector3D ( I DON'T KNOW HOW TO DO THIS );
//   }

   // binary functions
   friend Vector3D operator + ( Vector3D const& a, Vector3D const& b )
   {
      return Vector3D ( a.x + b.x, a.y + b.y, a.z + b.z );
   }
   friend Vector3D operator - ( Vector3D const& a, Vector3D const& b )
   {
      return Vector3D ( a.x - b.x, a.y - b.y, a.z - b.z );
   }
   friend float operator & ( Vector3D const& a, Vector3D const& b )
      // dot (scalar) product
   {
      return a.x*b.x + a.y*b.y + a.z*b.z;
   }
   friend Vector3D operator * ( Vector3D const& a, Vector3D const& b )
   {
      return Vector3D ( a.x*b.x, a.y*b.y, a.z*b.z );
   }
   friend Vector3D operator / ( Vector3D const& a, Vector3D const& b )
   {
      return Vector3D ( a.x/b.x, a.y/b.y, a.z/b.z );
   }
   friend Vector3D operator * ( float a, Vector3D const& b )
   {
      return Vector3D ( b.x*a, b.y*a, b.z*a );
   }
   friend Vector3D operator / ( Vector3D const& a, float b )
   {
      return Vector3D ( a.x/b, a.y/b, a.z/b );
   }
   friend Vector3D operator ^ ( Vector3D const& a, Vector3D const& b )
      // cross (vector) product
   {
      return Vector3D ( a.y*b.z - a.z*b.y, a.z*b.x - a.z*b.z, a.x*b.y - a.y*b.x );
   }

   // apply transformation
   Vector3D& operator *= ( Matrix4D const& m );
};

class Vector4D  // Vector class
{
   float max3 ( float a, float b, float c ) const
   {
      return (a>b?(a>c?a:c):(b>c?b:c));
   }
public:
   float x, y, z, w; // cartesian coordinates

   Vector4D() {} // default constructor
   // construct from 3 coords
   Vector4D ( float px, float py, float pz, float pw = 1.0f )
      : x ( px )
      , y ( py )
      , z ( pz )
      , w ( pw )
   {
      // intentionally left blank
   }
   // copy constructor
   Vector4D ( Vector4D const& v )
      : x ( v.x )
      , y ( v.y )
      , z ( v.z )
      , w ( v.w )
   {
      // intentionally left blank
   }
   Vector4D ( Vector3D const& v )
      : x ( v.x )
      , y ( v.y )
      , z ( v.z )
      , w ( 1.0f )
   {
      // intentionally left blank
   }

   // assignment operator
   Vector4D& operator = ( Vector4D const v )
   {
      x = v.x;
      y = v.y;
      z = v.z;
      w = v.w;
      return *this;
   }
   Vector4D& operator = ( Vector3D const v )
   {
      x = v.x;
      y = v.y;
      z = v.z;
      w = 1.0f;
      return *this;
   }

   // very important:
   operator Vector3D ()
   {
      return Vector3D ( x, y, z );
   }

   // positive self ( use like +v )
   Vector4D operator + () const
   {
      return *this; // does nothing
   }
   // negative self ( use like -v )
   Vector4D operator - () const
   {
      return Vector4D ( -x, -y, -z, w );
   }

   // add to itself
   Vector4D& operator += ( Vector4D const& v )
   {
      x += v.x;
      y += v.y;
      z += v.z;
      return *this;
   }
   // subtract from itself
   Vector4D& operator -= ( Vector4D const& v )
   {
      x -= v.x;
      y -= v.y;
      z -= v.z;
      return *this;
   }
   // multiply by scalar
   Vector4D& operator *= ( Vector4D const& v )
   {
      x *= v.x;
      y *= v.y;
      z *= v.z;
      return *this;
   }
   // multiply by scalar
   Vector4D& operator *= ( float f )
   {
      x *= f;
      y *= f;
      z *= f;
      return *this;
   }
   // multiply by scalar
   Vector4D& operator /= ( Vector4D const& v )
   {
      x *= v.x;
      y *= v.y;
      z *= v.z;
      return *this;
   }
   // divide by scalar
   Vector4D& operator /= ( float f )
   {
      x /= f;
      y /= f;
      z /= f;
      return *this;
   }

   // coord number <index> ( after all vector is just another form of an array )
   float& operator [] ( int index )
   {
      return * ( &x + index );
   }

   // conditions
   bool operator == ( Vector4D const& v ) const
   {
      return FEQ ( x, v.x ) && FEQ ( y, v.y ) && FEQ ( z, v.z );
   }
   bool operator != ( Vector4D const& v ) const
   {
      return FNEQ ( x, v.x ) || FNEQ ( y, v.y ) || FNEQ ( z, v.z );
   }

   // conversion - use like *v = c ( same as v.x = c )
   operator float* ()
   {
      return &x;
   }
   operator float const* () const
   {
      return &x;
   }

   // various functions
   float length () const
   {
      return (float) sqrt ( sqr ( x ) + sqr ( y ) + sqr ( z ) );
   }
   float lengthSq () const // return length^2, works faster than the previous one
                            // because it doesn't retrieve square root
   {
      return sqr ( x ) + sqr ( y ) + sqr ( z );
   }
   float lengthFast () const // return length, uses special formula to retrieve sqrt
                              // works faster, but lower quality ( 8% error )
   {
      int temp;  // used for swaping
      int x1,y1,z1; // used for algorithm

      // make sure values are all positive
      x1 = int ( fabs(x) * 1024 );
      y1 = int ( fabs(y) * 1024 );
      z1 = int ( fabs(z) * 1024 );

      // sort values
      if (y1 < x1) SWAP(x1,y1,temp);
      if (z1 < y1) SWAP(y1,z1,temp);
      if (y1 < x1) SWAP(x1,y1,temp);

      int dist = (z1 + 11 * (y1 >> 5) + (x1 >> 2) );

      // compute distance with 8% error
      return ( (float)(dist) ) * ( 1/1024 );
   }
   float lengthMax () const // HUGE error, but really fast
   {
      return max3 ( (float) fabs (x), (float) fabs (y), (float) fabs (z) );
   }

   Vector4D& normalize ()
   {
      (*this) /= length () * w;
      w = 1;
      return *this;
   }

   float distanceToSq ( Vector4D const& p ) const // distance between vector's endpoints ( squared )
   {
      return sqr ( x - p.x ) + sqr ( y - p.y ) + sqr ( z - p.z );
   }
   float distanceTo ( Vector4D const& p ) const // distance between vector's endpoints
   {
      return (float) sqrt ( sqr ( x - p.x ) + sqr ( y - p.y ) + sqr ( z - p.z ) );
   }

//   Vector3D& ort () const // return a vector orthogonal to this ( one of them )
//   {
//      return Vector3D ( I DON'T KNOW HOW TO DO THIS );
//   }

   // binary functions
   friend Vector4D operator + ( Vector4D const& a, Vector4D const& b )
   {
      return Vector3D ( a.x + b.x, a.y + b.y, a.z + b.z );
   }
   friend Vector4D operator - ( Vector4D const& a, Vector4D const& b )
   {
      return Vector4D ( a.x - b.x, a.y - b.y, a.z - b.z );
   }
   friend float operator & ( Vector4D const& a, Vector4D const& b )
      // dot product
   {
      return a.x*b.x + a.y*b.y + a.z*b.z;
   }
   friend Vector4D operator * ( Vector4D const& a, Vector4D const& b )
   {
      return Vector4D ( a.x*b.x, a.y*b.y, a.z*b.z );
   }
   friend Vector4D operator / ( Vector4D const& a, Vector4D const& b )
   {
      return Vector4D ( a.x/b.x, a.y/b.y, a.z/b.z );
   }
   friend Vector4D operator * ( Vector4D const& a, float b )
   {
      return Vector4D ( a.x*b, a.y*b, a.z*b );
   }
   friend Vector4D operator * ( float a, Vector4D const& b )
   {
      return Vector4D ( b.x*a, b.y*a, b.z*a );
   }
   friend Vector4D operator / ( Vector4D const& a, float b )
   {
      return Vector4D ( a.x/b, a.y/b, a.z/b );
   }
   friend Vector4D operator ^ ( Vector4D const& a, Vector4D const& b )
      // cross product
   {
      return Vector4D ( a.y*b.z - a.z*b.y, a.z*b.x - a.z*b.z, a.x*b.y - a.y*b.x );
   }

   // apply transformation
   Vector4D& operator *= ( Matrix4D const& m );

   Vector4D& Factorize ()
   {
      x /= w;
      y /= w;
      z /= w;
      w = 1.0f;
      return *this;
   }
};

//////////////////////////////////////////////////////////////////////
//                                                                  //
// interface for the Matrix4D class.                                //
//                                                                  //
//////////////////////////////////////////////////////////////////////

class Matrix4D  
{
public:
   // multi-address:
   // 1. M [2][3];
   // 2. m [11]; // 11 = 2 * 4 + 3;
   // 3. M23;
   union
   {
      float M [4][4];
      float m [16];
      struct
      {
         float M00, M01, M02, M03;
         float M10, M11, M12, M13;
         float M20, M21, M22, M23;
         float M30, M31, M32, M33;
      };
   };

   // default constructor
   Matrix4D() {}
   // construct from a float
   Matrix4D ( float f )
   {
      for ( int i = 0; i < 16; i++ )
         m [i] = f;
   }
   // copy constructor
   Matrix4D ( Matrix4D const& mat )
   {
      memcpy ( m, mat.m, sizeof m );
   }
   // huge constructor
   Matrix4D ( float _11, float _12, float _13, float _14,
              float _21, float _22, float _23, float _24,
              float _31, float _32, float _33, float _34, 
              float _41, float _42, float _43, float _44 )
      : M00 ( _11 ), M01 ( _12 ), M02 ( _13 ), M03 ( _14 )
      , M10 ( _21 ), M11 ( _22 ), M12 ( _23 ), M13 ( _24 )
      , M20 ( _31 ), M21 ( _32 ), M22 ( _33 ), M23 ( _34 )
      , M30 ( _41 ), M31 ( _42 ), M32 ( _43 ), M33 ( _44 )
   {}


   // assignment operator
   Matrix4D& operator = ( Matrix4D const& mat )
   {
      memcpy ( m, mat.m, sizeof m );
      return *this;
   }

   // matrix addition ( store in self )
   Matrix4D& operator += ( Matrix4D const& mat )
   {
      for ( int i = 0; i < 16; i++ )
         m [i] += mat.m [i];
      return *this;
   }
   // matrix subtraction ( store in self )
   Matrix4D& operator -= ( Matrix4D const& mat )
   {
      for ( int i = 0; i < 16; i++ )
         m [i] -= mat.m [i];
      return *this;
   }
   // scalar multiplication ( store in self )
   Matrix4D& operator *= ( float f )
   {
      for ( int i = 0; i < 16; i++ )
         m [i] *= f;
      return *this;
   }
   // scalar division ( store in self )
   Matrix4D& operator /= ( float f )
   {
      for ( int i = 0; i < 16; i++ )
         m [i] /= f;
      return *this;
   }
   // matrix multiplication ( store in self )
   // used to combine transformations
   Matrix4D& operator *= ( Matrix4D const& mat )
   {
      Matrix4D mt ( 0 );

      for ( int i = 0; i < 4; i++ )
         for ( int j = 0; j < 4; j++ )
            for ( int x = 0; x < 4; x++ )
               mt.M [i][j] += M [i][x] * mat.M [x][j];

      return (*this) = mt;
   }

   // address as an array
   float& operator [] ( int i )
   {
      return m [i];
   }
   float const& operator [] ( int i ) const
   {
      return m [i];
   }

   // transpose ( swap Mij and Mji )
   Matrix4D& transpose ()
   {
      float t;
      for ( int i = 0; i < 3; i++ )
         for ( int j = i+1; j < 4; j++ )
            SWAP ( M [i][j], M [j][i], t );
      return *this;
   }

   // conditions
   bool operator == ( Matrix4D const& mat ) const
   {
      for ( int i = 0; i < 16; i++ )
         if ( FNEQ ( m [i], mat.m [i] ) )
            return false;
      return true;
   }
   bool operator != ( Matrix4D const& mat ) const
   {
      for ( int i = 0; i < 16; i++ )
         if ( FNEQ ( m [i], mat.m [i] ) )
            return true;
      return false;
   }

   // binary functions
   friend Matrix4D operator + ( Matrix4D const& a, Matrix4D const& b )
   {
      Matrix4D mt;
      for ( int i = 0; i < 16; i++ )
         mt.m [i] = a.m [i] + b.m [i];
      return mt;
   }
   friend Matrix4D operator - ( Matrix4D const& a, Matrix4D const& b )
   {
      Matrix4D mt;
      for ( int i = 0; i < 16; i++ )
         mt.m [i] = a.m [i] - b.m [i];
      return mt;
   }
   friend Matrix4D operator * ( Matrix4D const& a, float b )
   {
      Matrix4D mt;
      for ( int i = 0; i < 16; i++ )
         mt.m [i] = a.m [i] * b;
      return mt;
   }
   friend Matrix4D operator * ( float a, Matrix4D const& b )
   {
      Matrix4D mt;
      for ( int i = 0; i < 16; i++ )
         mt.m [i] = a * b.m [i];
      return mt;
   }
   friend Matrix4D operator * ( Matrix4D const& a, Matrix4D const& b )
   {
      Matrix4D mt ( 0 );

      for ( int i = 0; i < 4; i++ )
         for ( int j = 0; j < 4; j++ )
            for ( int x = 0; x < 4; x++ )
               mt.M [i][j] += a.M [i][x] * b.M [x][j];

      return mt;
   }
   friend Matrix4D operator / ( Matrix4D const& a, float b )
   {
      Matrix4D mt;
      for ( int i = 0; i < 16; i++ )
         mt.m [i] = a.m [i] / b;
      return mt;
   }

   // vector-matrix multiplication ( apply transformation )
   friend Vector3D operator * ( Vector3D const& v, Matrix4D const& m )
   {
      Vector3D r;
      for ( int i = 0; i < 3; i++ )
      {
         r [i] = 0;
         for ( int j = 0; j < 3; j++ )
            r [i] += v [j] * m.M [j][i];
         r [i] += m.M [3][i];
      }
      return r;
   }
   // vector-matrix multiplication ( apply transformation )
   friend Vector4D operator * ( Vector4D const& v, Matrix4D const& m )
   {
      Vector4D r;
      for ( int i = 0; i < 4; i++ )
      {
         r [i] = 0;
         for ( int j = 0; j < 4; j++ )
            r [i] += v [j] * m.M [j][i];
      }
      return r;
   }

   static Matrix4D GetIdentity ()
   {
      return Matrix4D ( 1, 0, 0, 0,
                        0, 1, 0, 0,
                        0, 0, 1, 0,
                        0, 0, 0, 1 );
   }
   static Matrix4D GetTranslate ( float tx, float ty, float tz )
   {
      return Matrix4D (  1,  0,  0,  0,
                         0,  1,  0,  0,
                         0,  0,  1,  0,
                        tx, ty, tz,  1 );
   }
   static Matrix4D GetTranslate ( Vector3D const& v )
   {
      return Matrix4D (   1,   0,   0,   0,
                          0,   1,   0,   0,
                          0,   0,   1,   0,
                        v.x, v.y, v.z,   1 );
   }
   static Matrix4D GetScale ( float sx, float sy, float sz )
   {
      return Matrix4D ( sx,  0,  0,  0,
                         0, sy,  0,  0,
                         0,  0, sz,  0,
                         0,  0,  0,  1 );
   }
   static Matrix4D GetScale ( Vector3D const& v )
   {
      return Matrix4D ( v.x,   0,   0,   0,
                          0, v.y,   0,   0,
                          0,   0, v.z,   0,
                          0,   0,   0,   1 );
   }
   static Matrix4D GetRotateX ( float a )
   {
	  float cs = cos ( a );
      float sn = sin ( a );
      return Matrix4D (  1,  0,  0,  0,
                         0, cs,-sn,  0,
                         0, sn, cs,  0,
                         0,  0,  0,  1 );
   }
   static Matrix4D GetRotateY ( float a )
   {
      float cs = cos ( a );
      float sn = sin ( a );
      return Matrix4D ( cs,  0, sn,  0,
                         0,  1,  0,  0,
                       -sn,  0, cs,  0,
                         0,  0,  0,  1 );
   }
   static Matrix4D GetRotateZ ( float a )
   {
      float cs = cos ( a );
      float sn = sin ( a );
      return Matrix4D ( cs,-sn,  0,  0,
                        sn, cs,  0,  0,
                         0,  0,  1,  0,
                         0,  0,  0,  1 );
   }
   static Matrix4D GetRotate ( Vector3D const& l, float a )
   {
      Matrix4D S (   0, l.z,-l.y, 0,
                  -l.z,   0, l.x, 0,
                   l.y,-l.x,   0, 0,
                     0,   0,   0, 1 );
	  return GetIdentity () + S * sin ( a ) + S * S * ( 1 - cos ( a ) );
   }
};

const Vector3D Vector0 ( 0, 0, 0 ),
               VectorX ( 1, 0, 0 ),
               VectorY ( 0, 1, 0 ),
               VectorZ ( 0, 0, 1 );

#endif // __GAME_MATH_H__