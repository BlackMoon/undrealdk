class Kamaz_AutodromMessages extends Gorod_BaseMessages;
`include(Gorod/Gorod_Events.uci);

function fillMessages()
{
	local MessageInfo msgi; 

	msgi.ID = 1000;
	msgi.Title = "Автодром";
	msgi.Text = "Вы въехали на автодром. Проследуйте к первому упражнению";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1001;
	msgi.Title = "Автодром";
	msgi.Text = "Вы выехали с автодрома";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1002;
	msgi.Title = "Автодром";
	msgi.Text = "Вы начали упражнение Остановка и начало движения на подъеме";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1003;
	msgi.Title = "Автодром";
	msgi.Text = "Вы завершили упражнение Остановка и начало движения на подъеме. Проследуйте к следующему упражнению";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1004;
	msgi.Title = "Автодром";
	msgi.Text = "Вы начали упражнение Разворот и парковка";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1005;
	msgi.Title = "Автодром";
	msgi.Text = "Вы завершили упражнение Разворот и парковка. Проследуйте к следующему упражнению";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1006;
	msgi.Title = "Автодром";
	msgi.Text = "Вы начали упражнение Параллельная парковка задним ходом";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1007;
	msgi.Title = "Автодром";
	msgi.Text = "Вы завершили упражнение Параллельная парковка задним ходом. Проследуйте к следующему упражнению";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = 1008;
	msgi.Title = "Автодром";
	msgi.Text = "Вы выехали за пределы проезжей части";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1009;
	msgi.Title = "Автодром";
	msgi.Text = "Вы не соблюдаете маршрут движения по автодрому";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);	

	msgi.ID = 1011;
	msgi.Title = "Автодром";
	msgi.Text = "Вы превысили ограничение скорости на автодроме";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1012;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы пересекли линию фиксации выполнения упражнения или линию СТОП";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1013;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы начали движение ранее, чем через 3 с после остановки";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 25;
	Messages.AddItem(msgi);

	msgi.ID = 1014;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы не начали движение в течение 30 с после остановки";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 25;
	Messages.AddItem(msgi);

	msgi.ID = 1015;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы допустили откат ТС на величину более чем 0,3 м при остановке или начале движения";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 10;
	Messages.AddItem(msgi);

	msgi.ID = 1016;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы не коснулись задними колёсами ТС линии фиксации выполнения упражнения";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1017;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы пересекли контрольную линию";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1018;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы затратили более 2 минут на выполнение упражнения";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1019;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы не коснулись правыми колёсами линии фиксации выполнения упражнения";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 10;
	Messages.AddItem(msgi);

	msgi.ID = 1020;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы пересекли контрольную линию";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1021;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы затратили более 2 минут на выполнение упражнения";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 5;
	Messages.AddItem(msgi);

	msgi.ID = 1022;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы не совершали действий по упражнению в течение 5 минут. Выполнение прекращено. Проследуйте к следующему упражнению";
	msgi.type = MESSAGE_ERROR;
	msgi.Points = 0;
	Messages.AddItem(msgi);

	msgi.ID = 1023;
	msgi.Title = "Автодром";
	msgi.Text = "Вы слишком отклонились от маршрута. Выполнение заданий на автодроме прекращено.";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1024;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы нарушили порядок действий при выполнении упражнения. Выполнение прекращено. Проследуйте к следующему упражнению";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = 1025;
	msgi.Title = "Упражнение";
	msgi.Text = "Вы слишком далеко отъехали от зоны выполнения упражнения";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_OFF_ROAD;
	msgi.Title = "Автодром";
	msgi.Text = "Вы выехали с проезжей части. Выполнение упражнения будет прекращено.";
	msgi.type = MESSAGE_ERROR;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_GO_TO_ASCENT;
	msgi.Title = "Упражнение";
	msgi.Text = "Остановите ТС на участке подъёма между линией фиксации выполнения упражнения и линией СТОП";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_STOP;
	msgi.Title = "Упражнение";
	msgi.Text = "Зафиксируйте ТС в неподвижном состоянии с помощью ручного тормоза, включите нейтральную передачу";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_GO;
	msgi.Title = "Упражнение";
	msgi.Text = "Продолжите движение в прямом направлении, не допуская отката ТС назад.(время для выполнения 3 - 30сек)";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_MOVE_FORWARDS;
	msgi.Title = "Упражнение";
	msgi.Text = "Двигайтесь прямо. Остановитесь перед линией";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_PARK_BACK;
	msgi.Title = "Упражнение";
	msgi.Text = "Установите ТС на место парковки задним ходом так, чтобы задние колёса находились на линии фиксации выполнения упражнения";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_OUT_BACK;
	msgi.Title = "Упражнение";
	msgi.Text = "Выезжайте в обратном напралении.";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_PARK_RIGHT;
	msgi.Title = "Упражнение";
	msgi.Text = "Установите ТС на место парковки задним ходом так, чтобы переднее и заднее правые колёса находились на линии фиксации выполнения упражнения";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_OUT_FROM_PARKING;
	msgi.Title = "Упражнение";
	msgi.Text = "Выезжайте с места парковки.";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_LEFT;
	msgi.Title = "Автодром";
	msgi.Text = "Поверните налево";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_RIGHT;
	msgi.Title = "Автодром";
	msgi.Text = "Поверните направо";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);

	msgi.ID = GOROD_EVENT_DRIVE_FORWARD;
	msgi.Title = "Автодром";
	msgi.Text = "Двигайтесь прямо";
	msgi.type = MESSAGE_INFORM;
	Messages.AddItem(msgi);
}

DefaultProperties
{
	MinMsgID = 1000;
	MaxMsgID = 1999;
}