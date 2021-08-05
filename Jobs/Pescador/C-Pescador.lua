------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------
local painel_Pescador = false
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

function CMR_Pescador_PainelDX()
	dxDrawImage(x*950, y*230, x*200, y*250, "img/TelaFundo.png", 0, 0, 0)
	dxDrawText("Pescador", x*990*2, y*250, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_14, "center", "top", false, false, false, false, false)
	dxDrawImage(x*975, y*300, x*150, y*50, "img/Button.png", 0, 0, 0)
	if not (getElementData(localPlayer, "CMR:PescadorTrab") or false) then
		dxDrawText("Iniciar Serviço", x*990*2, y*315, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_11, "center", "top", false, false, false, false, false)
	else
		dxDrawText("Finalizar Serviço", x*990*2, y*315, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_11, "center", "top", false, false, false, false, false)
	end
	dxDrawImage(x*975, y*380, x*150, y*50, "img/Button.png", 0, 0, 0)
	dxDrawText("Fechar", x*985*2, y*395, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_11, "center", "top", false, false, false, false, false)
end

function CMR_Pescador_Click(_, state)
	if state == "down" then
		if painel_Pescador then
			-- Fechar
			if isCursor(x*975, y*380, x*150, y*50) then
				playSoundFrontEnd(43)
				CMR_Pescador_Painel()
			end

			-- Iniciar/Finalizar
			if isCursor(x*975, y*300, x*150, y*50) then
				playSoundFrontEnd(43)
				triggerServerEvent("CMR:Pescador:IniciarFinalizar", localPlayer, localPlayer)
			end

		end
	end
end
addEventHandler("onClientClick", root, CMR_Pescador_Click)

function CMR_Pescador_Painel()
	if not painel_Pescador then
		addEventHandler("onClientRender", root, CMR_Pescador_PainelDX)
		painel_Pescador = true
		showCursor(true)
	else
		removeEventHandler("onClientRender", root, CMR_Pescador_PainelDX)
		painel_Pescador = false
		showCursor(false)
	end
end
addEvent("CMR:Pescador:PainelDX", true)
addEventHandler("CMR:Pescador:PainelDX", root, CMR_Pescador_Painel)