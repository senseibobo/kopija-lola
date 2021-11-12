extends Control

func _on_BTCreate_pressed():
	var port = int($CCMain/VBMain/GCMain/VBCreateServer/LECreatePort.text)
	Network.create_server(port)
	Lobby.goto_lobby()

func _on_BTJoin_pressed():
	$CCMain/VBMain/GCMain/VBjoinServer/LEJoinIP.editable = false
	$CCMain/VBMain/GCMain/VBjoinServer/LEJoinPort.editable = false
	
	var ip = $CCMain/VBMain/GCMain/VBjoinServer/LEJoinIP.text
	var port = int($CCMain/VBMain/GCMain/VBjoinServer/LEJoinPort.text)
	Lobby.my_info = {
		Lobby.INFO_NAME : $CCMain/VBMain/GCMain/VBjoinServer/LEPlayerName.text
	}
	Network.join_server(ip,port)
