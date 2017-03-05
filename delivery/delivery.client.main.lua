
function remotePlayerJoin()
	outputChatBox("* " .. getPlayerName(source) .. " has joined the server")
	outputConsole("Testar");
end
addEventHandler("onClientPlayerJoin", getRootElement(), remotePlayerJoin)