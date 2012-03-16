import flash.external.ExternalInterface;
class MessageBox extends MovieClip
{
	private var textTitle:TextField;// заголовок сообщения
	private var textBody:TextField;// тело сообщения
	private var buttonSet1:MovieClip;// набор кнопок ОК и Cancel
	private var buttonSet2:MovieClip;// набор из одной кнопки ОК
	private var window:MovieClip;// прямоугольник окна
	private var formatOfTextBody:TextFormat;
	private var formatOfTextTitle:TextFormat;
	private var intervalId:Number;
	private var widthScale:Number;
	private var heightScale:Number;
	var m_id:Number;
	var ParentScene:MovieClip;
	
	public function SetID(id:Number)
	{
		m_id = id;
	}
	
	public function MessageBox()
	{		
		super();
		textBody.text = "textBody";
		textBody.setTextFormat(new TextFormat());
		formatOfTextBody = textBody.getTextFormat();
		
		textTitle.text = "textTitle";
		textTitle.setTextFormat(new TextFormat());
		formatOfTextTitle = textTitle.getTextFormat();
		
		widthScale = 100;
		heightScale = 100;
		/*window.onPress = function() { 
    		this._parent.startDrag();
		};
		window.onRelease = function() {
    		this._parent.stopDrag();
		};*/
	}
	
	
	
	function get notitle():Boolean{return (textTitle._height == 0);}// есть ли заголовок окна
	function set notitle(value:Boolean):Void// убирает или проявляет заголовок
	{
		if (value == true)
		{
			if (textTitle._height <> 0)
			{
				window.Body._y = this._y;
				window.Body._height += 50*heightScale/100;
				textTitle._height = 0;
				textBody._y -= 50*heightScale/100;
				textBody._height += 50*heightScale/100;
			}
		}
		else
		{
			if (textTitle._height == 0)
			{
				window.Body._y = this._y+50*heightScale/100;
				window.Body._height -= 50*heightScale/100;
				textTitle._height = 50*heightScale/100;
				textBody._y += 50*heightScale/100;
				textBody._height -= 50*heightScale/100;
			}
		}
	}
	
	function get buttonsHeight():Number{return (isButton?buttonSet1._height:0);}
	
	
	
	// есть ли кнопки на экране
	function get isButton():Boolean {return ((buttonSet1._visible) || (buttonSet2._visible))}
	
	// запуск окна без кнопок
	private function startWithNoButton(titletext:String, bodytext:String)
	{
		notitle = (titletext == "");
		textTitle.text = titletext;
		if (isButton){textBody._height += 50*heightScale/100;}
		textBody.text = bodytext;
		buttonSet1._visible = false;
		buttonSet2._visible = false;
	}
	
	
	
	// запуск окна с кнопками ОК и Cancel
	public function startWithSet1(titletext:String, bodytext:String)
	{
		notitle = (titletext == "");
		textTitle.text = titletext;
		textBody.text = bodytext;
		buttonSet1._visible = true;
		buttonSet2._visible = false;
	}
	
	
	
	// запуск окна только с кнопкой ОК
	public function startWithSet2(titletext:String, bodytext:String)
	{
		notitle = (titletext == "");
		textTitle.text = titletext;
		textBody.text = bodytext;
		buttonSet1._visible = false;
		buttonSet2._visible = true;
		trace(textTitle._y);
		trace(textTitle._height);
		trace(window.Title._y);
		trace(window.Title._height);
		
	}
	
	
	
	public function get textOfTitle():String{return textTitle.text;}
	public function set textOfTitle(value:String){textTitle.text = value;}
	
	
	
	public function get textOfBody():String{return textBody.text;}
	public function set textOfBody(value:String){textBody.text = value;}
	
	
	
	public function getSizeOfBodyChar ():Number
	{
		return  formatOfTextBody.size;
	}
	public function setSizeOfBodyChar(value:Number)
	{		
		formatOfTextBody.size = value;		
		textBody.setNewTextFormat(formatOfTextBody);
		textBody.text = textBody.text;
		
	}
	
	
	public function getSizeOfTitleChar ():Number
	{
		return  formatOfTextTitle.size;
	}
	public function setSizeOfTitleChar(value:Number)
	{		
		formatOfTextTitle.size = value;		
		textTitle.setNewTextFormat(formatOfTextTitle);
		textTitle.text = textTitle.text;
		
	}
	
	public function setMargin(left__:Number, right__:Number, top__:Number, bottom__:Number):Void
	{
		if (!isNaN(left__))
		{
			
			if ((left__ >= 0) && (left__ <this._width  - getSizeOfBodyChar()))
			{
				
				textBody._x = left__;
			}
		}

		if (!isNaN(top__))
		{
			if ((top__ >= 0) && (top__ < this._height - textTitle._height - (isButton?50:0) - getSizeOfBodyChar()))
			{
				textBody._y = top__ + textTitle._height;
			}
		}

		if (!isNaN(right__))
		{
			if ((this._width - textBody._x - right__ > getSizeOfBodyChar()) && (right__ >= 0))
			{
				textBody._width = window._width - textBody._x - right__;
			}
		}

		if (!isNaN(bottom__))
		{
			if ((this._height - textBody._y - bottom__ - buttonsHeight > getSizeOfBodyChar()) && (bottom__ >= 0))
			{
				textBody._height = window._height - textBody._y - buttonsHeight - bottom__;
			}
		}
	}
	
	
	public function setSizes(height_:Number, width_:Number):Void
	{
		/*var scaleFactorX:Number = _width * 1000;
		var scaleFactorY:Number = _height * 1000;
		scaleFactorY /= height_ * 1000;
		scaleFactorX /= width_ * 1000;*/
		
		var scaleFactorX:Number = height_ * 1000;
		var scaleFactorY:Number = width_ * 1000;
		scaleFactorY /= _height * 1000;
		scaleFactorX /= _width * 1000;
		
		setSizeOfBodyChar(getSizeOfBodyChar() * scaleFactorX);
		setSizeOfTitleChar(getSizeOfTitleChar() * scaleFactorX);
	
		
		textTitle._y *= scaleFactorY;
		textTitle._height *= scaleFactorY;
		textTitle._x *= scaleFactorX;
		textTitle._width *= scaleFactorX;
		
		textBody._y *= scaleFactorY;
		textBody._height *= scaleFactorY;
		textBody._x *= scaleFactorX ;
		textBody._width *= scaleFactorX;
		
		window.Title._y *= scaleFactorY;
		window.Title._height *= scaleFactorY;
		window.Body._y *= scaleFactorY;
		window.Body._height *= scaleFactorY;
		window.Title._x *= scaleFactorX;
		window.Title._width *= scaleFactorX;
		window.Body._x *= scaleFactorX;
		window.Body._width *= scaleFactorX;
		
		buttonSet1._y *= scaleFactorY;
		buttonSet1._height *= scaleFactorY;
		buttonSet2._y *= scaleFactorY;
		buttonSet2._height *= scaleFactorY;
		buttonSet1._x *= scaleFactorX;
		buttonSet1._width *= scaleFactorX;
		buttonSet2._x *= scaleFactorX;
		buttonSet2._width *= scaleFactorX;
		
		heightScale=scaleFactorY * 100;
		widthScale=scaleFactorX * 100;
		
		/*
		textTitle._y *= height_ / 100
		textTitle._height *= height_ / 100;
		
		textBody._y *= height_ / 100;
		textBody._height *= height_ / 100;
		
		window.Title._y *= height_ / 100;
		window.Title._height *= height_ / 100;
		window.Body._y *= height_ / 100;
		window.Body._height *= height_ / 100;
		
		buttonSet1._y *= height_ / 100;
		buttonSet1._height *= height_ / 100;
		buttonSet2._y *= height_ / 100;
		buttonSet2._height *= height_ / 100;
		
		
		
		textTitle._x *= width_ / 100
		textTitle._width *= width_ / 100;
		
		textBody._x *= width_ / 100;
		textBody._width *= width_ / 100;
		
		window.Title._x *= width_ / 100;
		window.Title._width *= width_ / 100;
		
		window.Body._x *= width_ / 100;
		window.Body._width *= width_ / 100;
		
		buttonSet1._x *= width_ / 100;
		buttonSet1._width *= width_ / 100;
		buttonSet2._x *= width_ / 100;
		buttonSet2._width *= width_ / 100;*/
		
	}
	
	// уменьшает прозрачность на единицу один раз
	private function trans():Void
	{
		if (this._alpha <= 0)
		{
			clearInterval(intervalId);
			ExternalInterface.call("CloseMyMovie", m_id);
			if(ParentScene)
				ParentScene.OnCloseMovie(this);
			
			//var str:String = this;
			//trace(str);
			
		}		
		this._alpha -= 2;				
		//trace ( this._alpha);
	}
	
	public function Reset()
	{
		this._alpha = 100;
	}
	
	// каждые 10 миллисекунд уменьшает прозрачность на единицу
	private function becomeTransparent():Void
	{
		clearInterval(intervalId);
		intervalId = setInterval(this,"trans", 10);
	}
	
	
	// через время value в миллисекундах начинает исчезать окно
	public function setTimer(titletext:String, bodytext:String, value:Number):Void
	{
		this.startWithNoButton(titletext,bodytext);
		intervalId = setInterval(this,"becomeTransparent", value);
		//trace(123);
	}
	
	
	public function setXY(x_:Number, y_:Number):Void
	{
		_x = x_;
		_y = y_;
	}
	
}