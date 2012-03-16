class Gorod_StartMovingMessages extends Gorod_BaseMessages;
`include(Gorod_Events.uci);

function fillMessages()
{
	local MessageInfo msgi;
	
	msgi.ID = GOROD_STARTMOVING_BELT;
	msgi.Title = "Начало движения";
	msgi.Text = "Пристегните ремень";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_CLUTCH_DOWN;
	msgi.Title = "Начало движения";
	msgi.Text = "Нажмите педаль сцепления";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_IGNITION;
	msgi.Title = "Начало движения";
	msgi.Text = "Запустите двигатель";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_FIRST_GEAR;
	msgi.Title = "Начало движения";
	msgi.Text = "Включите первую передачу";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_LEFT_TURN_SIGNAL;
	msgi.Title = "Начало движения";
	msgi.Text = "Включите левый указатель поворота";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);
	
	msgi.ID = GOROD_STARTMOVING_RIGHT_TURN_SIGNAL;
	msgi.Title = "Начало движения";
	msgi.Text = "Включите правый указатель поворота";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_HAND_BRAKE;
	msgi.Title = "Начало движения";
	msgi.Text = "Снимите машину со стояночного тормоза";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_THROTTLE;
	msgi.Title = "Начало движения";
	msgi.Text = "Нажмите педаль газа";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_CLUTCH_UP;
	msgi.Title = "Начало движения";
	msgi.Text = "Отпустите педаль сцепления";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_STARTMOVING_TURN_ON_MASS;
	msgi.Title = "Начало движения";
	msgi.Text = "Кратковременно нажмите на кнопку выключателя массы, включите аккумуляторные батареи";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 4000;
	MaxMsgID = 4099;
}