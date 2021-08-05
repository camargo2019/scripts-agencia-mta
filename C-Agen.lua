------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------
local painel = false
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

local ListEmpregos = {}
local IdItem = 0
local Imagem
local ValorMin
local ValorMax
local Level

function CMR_AgenciaAbrirPainel_DX()
	exports.Blur:dxDrawBluredRectangle(x*0, y*0, x*1366, y*768, tocolor(0, 0, 0, 170))
	dxDrawImage(x*340, y*180, x*650, y*400, "img/fundoAgencia.png", 0, 0, 0)
	if Imagem then
		dxDrawImage(x*657, y*218, x*300, y*175, "img/"..tostring(Imagem)..".png", 0, 0, 0)
	end
	if ValorMin and ValorMax and Level then
		dxDrawText("Salário: R$ "..tostring(ValorMin).." á "..tostring(ValorMax).." | Level Necessário: "..tostring(Level), x*740*2, y*370, x*125, y*40, tocolor(255, 255, 255, 255), 1.00, CMR_Font_10_impact, "center", "top", false, false, false, false, false)
	end
	dxDrawText("Fechar", x*427*2, y*498, x*125, y*40, tocolor(0, 0, 0, 255), 1.00, CMR_Font_11, "center", "top", false, false, false, false, false)
	dxDrawText("Demissão", x*660*2, y*465, x*125, y*40, tocolor(0, 0, 0, 255), 1.00, CMR_Font_10, "center", "top", false, false, false, false, false)
	dxDrawText("Trabalhar", x*820*2, y*465, x*125, y*40, tocolor(0, 0, 0, 255), 1.00, CMR_Font_10, "center", "top", false, false, false, false, false)
	dxDrawText("Proximo", x*820*2, y*515, x*125, y*40, tocolor(0, 0, 0, 255), 1.00, CMR_Font_10, "center", "top", false, false, false, false, false)
	dxDrawText("Voltar", x*660*2, y*515, x*125, y*40, tocolor(0, 0, 0, 255), 1.00, CMR_Font_10, "center", "top", false, false, false, false, false)
	
end

function CMR_AgenciaAbrirPainel()
	if not painel then
		addEventHandler("onClientRender", root, CMR_AgenciaAbrirPainel_DX)
		painel = true
		CMR_AgenciaCarregarEmpregos()
		showCursor(true)
	else
		removeEventHandler("onClientRender", root, CMR_AgenciaAbrirPainel_DX)
		painel = false
		showCursor(false)
	end
end
addEvent("CMR:AgenciaAbrirPainel", true)
addEventHandler("CMR:AgenciaAbrirPainel", root, CMR_AgenciaAbrirPainel)

function CMR_AgenciaCarregarEmpregos()
	triggerServerEvent("CMR:AgenciaCarregarEmpregos", localPlayer, localPlayer)
end

function CMR_AgenciaListCarregarEmpregos(List)
	ListEmpregos = List
	for i, job in ipairs(ListEmpregos) do
		if i == 1 then
			IdItem = i
			Imagem = job["Imagem"]
			ValorMin = job["ValorMin"]
			ValorMax = job["ValorMax"]
			Level = job["Level"]
		end
	end
end
addEvent("CMR:AgenciaListCarregarEmpregos", true)
addEventHandler("CMR:AgenciaListCarregarEmpregos", root, CMR_AgenciaListCarregarEmpregos)

function CMR_AgenciaClickPainel(_, state)
	if state == "down" then
		if painel then
			-- Fechar
			if isCursor(x*430, y*490, x*125, y*40) then
				playSoundFrontEnd(43)
				CMR_AgenciaAbrirPainel()
			end

			-- Se Demitir
			if isCursor(x*660, y*453, x*125, y*40) then
				playSoundFrontEnd(43)
				triggerServerEvent("CMR:AgenciaSeDemitir", localPlayer, localPlayer)
			end

			-- Trabalhar
			if isCursor(x*820, y*453, x*125, y*40) then
				playSoundFrontEnd(43)
				triggerServerEvent("CMR:AgenciaTrabalhar", localPlayer, IdItem)
			end

			-- Proximo
			if isCursor(x*825, y*503, x*125, y*40) then
				playSoundFrontEnd(43)
				for i, job in ipairs(ListEmpregos) do
					if (IdItem+1) > #ListEmpregos then
						if i == 1 then
							IdItem = i
							Imagem = job["Imagem"]
							ValorMin = job["ValorMin"]
							ValorMax = job["ValorMax"]
							Level = job["Level"]
							return
						end
					else
						if i == (IdItem+1) then
							IdItem = i
							Imagem = job["Imagem"]
							ValorMin = job["ValorMin"]
							ValorMax = job["ValorMax"]
							Level = job["Level"]
							return
						end
					end
				end
			end

			-- Voltar
			if isCursor(x*660, y*503, x*125, y*40) then
				playSoundFrontEnd(43)
				for i, job in ipairs(ListEmpregos) do
					if (IdItem-1) < 1 then
						if i == #ListEmpregos then
							IdItem = i
							Imagem = job["Imagem"]
							ValorMin = job["ValorMin"]
							ValorMax = job["ValorMax"]
							Level = job["Level"]
							return
						end
					else
						if i == (IdItem-1) then
							IdItem = i
							Imagem = job["Imagem"]
							ValorMin = job["ValorMin"]
							ValorMax = job["ValorMax"]
							Level = job["Level"]
							return
						end
					end
				end
			end
		end
	end
end
addEventHandler("onClientClick", root, CMR_AgenciaClickPainel)

function isCursor(x,y,w,h)
	local mx,my = getCursorPosition()
	if mx and my then
		local fullx,fully = guiGetScreenSize()
		
		cursorx, cursory = mx*fullx,my*fully
		
		if cursorx > x and cursorx < x + w and cursory > y and cursory < y + h then
			return true
		else
			return false
		end
	end
end
