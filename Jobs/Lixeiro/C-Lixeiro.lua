------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------
local painel_Lixeiro = false
local screenW, screenH = guiGetScreenSize()
local resW, resH = 1366, 768
local x, y = (screenW/resW), (screenH/resH)

local CMR_Font_14 = dxCreateFont("font/font.ttf", x*14)
local CMR_Font_12 = dxCreateFont("font/font.ttf", x*12)
local CMR_Font_11 = dxCreateFont("font/font.ttf", x*11)
local CMR_Font_10 = dxCreateFont("font/font.ttf", x*10)
local CMR_Font_8 = dxCreateFont("font/font.ttf", x*8)
local CMR_Font_6 = dxCreateFont("font/font.ttf", x*6)

local CMR_Font_10_impact = dxCreateFont("font/impact.ttf", x*10)

function CMR_Lixeiro_PainelDX()
	dxDrawImage(x*950, y*230, x*200, y*250, "img/TelaFundo.png", 0, 0, 0)
	dxDrawText("Lixeiro", x*990*2, y*250, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_14, "center", "top", false, false, false, false, false)
	dxDrawImage(x*975, y*300, x*150, y*50, "img/Button.png", 0, 0, 0)
	if not (getElementData(localPlayer, "CMR:LixeiroTrab") or false) then
		dxDrawText("Iniciar Serviço", x*990*2, y*315, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_11, "center", "top", false, false, false, false, false)
	else
		dxDrawText("Finalizar Serviço", x*990*2, y*315, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_11, "center", "top", false, false, false, false, false)
	end
	dxDrawImage(x*975, y*380, x*150, y*50, "img/Button.png", 0, 0, 0)
	dxDrawText("Fechar", x*985*2, y*395, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_11, "center", "top", false, false, false, false, false)
end

function CMR_Lixeiro_Click(_, state)
	if state == "down" then
		if painel_Lixeiro then
			-- Fechar
			if isCursor(x*975, y*380, x*150, y*50) then
				playSoundFrontEnd(43)
				CMR_Lixeiro_Painel()
			end

			-- Iniciar/Finalizar
			if isCursor(x*975, y*300, x*150, y*50) then
				playSoundFrontEnd(43)
				triggerServerEvent("CMR:Lixeiro:IniciarFinalizar", localPlayer, localPlayer)
			end

		end
	end
end
addEventHandler("onClientClick", root, CMR_Lixeiro_Click)

function CMR_Lixeiro_Painel()
	if not painel_Lixeiro then
		addEventHandler("onClientRender", root, CMR_Lixeiro_PainelDX)
		painel_Lixeiro = true
		showCursor(true)
	else
		removeEventHandler("onClientRender", root, CMR_Lixeiro_PainelDX)
		painel_Lixeiro = false
		showCursor(false)
	end
end
addEvent("CMR:Lixeiro:PainelDX", true)
addEventHandler("CMR:Lixeiro:PainelDX", root, CMR_Lixeiro_Painel)

function CMR_Lixeiro_Sound()
	setSoundVolume(playSound("Aud/EfeitoLixo.mp3"), 0.3)
end
addEvent("CMR:Lixeiro:Sound", true)
addEventHandler("CMR:Lixeiro:Sound", root, CMR_Lixeiro_Sound)

function CMR_Lixeiro_Anti_Colisao(vehiclePlayer)
	local v = vehiclePlayer
	for index,vehicle in ipairs(getElementsByType("vehicle")) do
		setElementCollidableWith(vehicle, v, false)
	end
end
addEvent("CMR:Lixeiro:AntiColisao", true)
addEventHandler("CMR:Lixeiro:AntiColisao", root, CMR_Lixeiro_Anti_Colisao)
