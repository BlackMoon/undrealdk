interface ICompass;

/** возвращающей значение, преобразованное радиан в градусы */
function float GetDegreeHeading();
/** возвращая разматывается заголовок объекта */
function float GetRadianHeading();

/** возвращая Yaw нашего вращения объектов */
function int GetYaw();
/** возвращая значение ротатора объекта */
function Rotator GetRotator();
/** возвращая ротатор, преобразованный в вектор. */
function vector GetVectorizedRotator();
