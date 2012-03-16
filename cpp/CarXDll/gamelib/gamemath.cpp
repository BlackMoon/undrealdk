#include "gamemath.h"

Vector3D& Vector3D::operator *= ( Matrix4D const& m )
{
   Vector3D r;

   for ( int i = 0; i < 3; i++ )
   {
      r [i] = 0;
      for ( int j = 0; j < 3; j++ )
         r [i] += (*this) [j] * m.M [j][i];
      r [i] += m.M [3][i];
   }

   return (*this) = r;
}

Vector4D& Vector4D::operator *= ( Matrix4D const& m )
{
   Vector4D r;

   for ( int i = 0; i < 4; i++ )
   {
      r [i] = 0;
      for ( int j = 0; j < 4; j++ )
         r [i] += (*this) [j] * m.M [j][i];
   }

   return (*this) = r;
}
