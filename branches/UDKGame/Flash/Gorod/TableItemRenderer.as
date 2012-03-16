import gfx.controls.ListItemRenderer;

class TableItemRenderer extends ListItemRenderer {
	
	public var field1:TextField;	// NAME
	public var field2:TextField;	// IP

	private function TableItemRenderer() { super(); }
	
	public function setData(data:Object):Void 
	{
		super.setData(data);

		if(data.name != undefined)
			field1.text = data.name;
		else
			field1.text = "";
		
		if(data.ip != undefined) 
			field2.text = data.ip;
		else
			field2.text = "";
		invalidate();
		this._visible = true;
	}
	
}