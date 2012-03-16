class Gorod_PDDMessages extends Gorod_BaseMessages;
`include(Gorod_Events.uci);

function fillMessages()
{
	local MessageInfo msgi;
	
	msgi.ID = 3005;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы проехали на красный свет светофора";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

/*	msgi.ID = 3006;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы находитесь за пределами дороги";
	msgi.type =  MESSAGE_WARNING;
	Messages.AddItem(msgi);*/

	msgi.ID = 3007;
	msgi.Title = "Оповещение";
	msgi.Text = "Вы находитесь за пределами дороги";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3008;
	msgi.Title = "Оповещение";
	msgi.Text = "Вы выехали на проезжую часть";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 3009;
	msgi.Title = "Оповещение";
	msgi.Text = "Вы выехали на встречную полосу";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3011;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы вьехали в пределы перекрестка";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 3012;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы вьехали в пределы перекрестка";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 3013;
	msgi.Title = "Оповещение";
	msgi.Text = "Вы двигаетесь по встречной полосе";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3014;
	msgi.Title = "Оповещение";
	msgi.Text = "Вы выезжаете на встречную полосу";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3015;
	msgi.Title = "Оповещение";
	msgi.Text = "Начало перестроения влево";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 3016;
	msgi.Title = "Оповещение";
	msgi.Text = "Начало перестроения вправо";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 3017;
	msgi.Title = "Оповещение";
	msgi.Text = "Перестроение влево закончено";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 3018;
	msgi.Title = "Оповещение";
	msgi.Text = "Перестроение вправо закончено";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 3019;
	msgi.Title = "ВНИМАНИЕ!";
	msgi.Text = "Вы cбили пешехода!";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);
// CROSSROAD AUTO
	msgi.ID = 3020;
	msgi.Title = "ВНИМАНИЕ!";
	msgi.Text = "Вы вьехали на перекресток с неправильной стороны!";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3021;
	msgi.Title = "ВНИМАНИЕ!";
	msgi.Text = "Вы выехали из перекрестка с неправильной стороны";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3022;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы проехали прямо";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3023;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы проехали прямо по встречному направлению";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3024;
	msgi.Title = "Перекресток";
	msgi.Text = "Проезд перекреска прямо запрещен";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3025;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы проехали налево";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3026;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы проехали налево по встречной полосе";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3027;
	msgi.Title = "Перекресток";
	msgi.Text = "Проезд налево запрещен";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3028;
	msgi.Title = "Перекресток";
	msgi.Text = "Проезд налево запрещен из средней полосы";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3029;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы проехали направо";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3030;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы проехали направо по встречной полосе";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3031;
	msgi.Title = "Перекресток";
	msgi.Text = "Проезд направо запрещен";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3032;
	msgi.Title = "Перекресток";
	msgi.Text = "Проезд направо запрещен из средней полосы";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3033;
	msgi.Title = "Перекресток";
	msgi.Text = "Вы развернулись на перекрестке";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3034;
	msgi.Title = "Перекресток";
	msgi.Text = "Неправильное движение на перекрестке";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3035;
	msgi.Title = "Перекресток";
	msgi.Text = "Разворот запрещен";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = 3036;
	msgi.Title = "Перекресток";
	msgi.Text = "Разворот из средней полосы запрещен";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);
//PDD
	msgi.ID = GOROD_PDD_VIOLATION_BRICK;    // 3010
	msgi.Title = "Нарушение ПДД";
	msgi.Text = "Вы выехали под знак \'Въезд запрещен\'";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_10_20;
	msgi.Title = "Нарушение ПДД";
	msgi.Text = "Вы нарушили ограничение максимальной скорости, зафиксировано превышение 10-20 км/ч";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_20_40;
	msgi.Title = "Нарушение ПДД";
	msgi.Text = "Вы нарушили ограничение максимальной скорости, зафиксировано превышение 20-40 км/ч";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_40_60;
	msgi.Title = "Нарушение ПДД";
	msgi.Text = "Вы нарушили ограничение максимальной скорости, зафиксировано превышение 40-60 км/ч";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_PDD_OUT_OF_SPEED_MAX_LIMIT_RESULT_60;
	msgi.Title = "Нарушение ПДД";
	msgi.Text = "Вы нарушили ограничение максимальной скорости, зафиксировано превышение более 60 км/ч";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_PDD_OUT_OF_SPEED_MIN_LIMIT_RESULT;
	msgi.Title = "Нарушение ПДД";
	msgi.Text = "Вы нарушили знак STOP";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_PDD_CROSSROAD_DRIVE_WHILE_LEFT_SECTION_DISABLED;
	msgi.Title = "Нарушение ПДД";
	msgi.Text = "Вы проехали на запрещающий сигнал левой секции";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_PDD_CROSSROAD_DRIVE_WHILE_RIGHT_SECTION_DISABLED;
	msgi.Title = "Нарушение ПДД";
	msgi.Text = "Вы проехали на запрещающий сигнал правой секции";
	msgi.type = MESSAGE_WARNING;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 3000;
	MaxMsgID = 3999;
}
