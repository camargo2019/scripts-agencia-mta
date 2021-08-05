------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local MarkerTrabalhar_Pescador

local Vehicle_Pescador = {}

local MarkerOnPlayer = {}

local RotaAtual = {}

local BlipsMarker = {}

local Etapa = {}

function CMR_Pescador_Init(res)
	if res == getThisResource() then
		local infJob = EmpregosInformacao["Pescador"]["pos"]
		MarkerTrabalhar_Pescador = createPickup(infJob[1], infJob[2], infJob[3], 3, 1275, 1)
		createBlipAttachedTo(MarkerTrabalhar_Pescador, 42)
		addEventHandler("onPickupHit", MarkerTrabalhar_Pescador, CMR_Pescador_Verificar)
	end
end
addEventHandler("onResourceStart", root, CMR_Pescador_Init)

function CMR_Pescador_Verificar(source)
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not isGuestAccount(acc) then
				if (getElementData(source, "Emprego") or getAccountData(acc, "Emprego") or false) == "Pescador" then
					triggerClientEvent(source, "CMR:Pescador:PainelDX", source)
				end
			end
		end
	end
end

function CMR_Pescador_IniciarJob(source)
	rota = math.random(1,3)
	if isElement(MarkerOnPlayer[source]) then
		destroyElement(MarkerOnPlayer[source])
	end
	if isElement(BlipsMarker[source]) then
		destroyElement(BlipsMarker[source])
	end
	if isElement(RotaAtual[source]) then
		destroyElement(RotaAtual[source])
	end
	local info_Rota = EmpregosInformacao["Pescador"][rota.."_Rota"]
	MarkerOnPlayer[source] = createMarker(info_Rota[1], info_Rota[2], info_Rota[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
	BlipsMarker[source] = createBlip(info_Rota[1], info_Rota[2], info_Rota[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
	RotaAtual[source] = rota
	Etapa[source] = 1
end

function CMR_Pescador_Marker(mark)
	if mark then
		if mark == MarkerOnPlayer[source] then
			local info_Rota = EmpregosInformacao["Pescador"][RotaAtual[source].."_Rota"]
			local info_Rota_Peixe = EmpregosInformacao["Pescador"][RotaAtual[source].."_Rota_Peixe"]
			local info_Fim_Rota = EmpregosInformacao["Pescador"]["Fim_Rota"]
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			if Etapa[source] == 1 then
				exports.cmr_dxmessages:outputDx(source, "Vai até o marker para pegar os peixes!", "info")
				MarkerOnPlayer[source] = createMarker(info_Rota_Peixe[1], info_Rota_Peixe[2], info_Rota_Peixe[3]-1, "cylinder", 1.5, 0, 0, 255, 170, source)
				BlipsMarker[source] = createBlip(info_Rota_Peixe[1], info_Rota_Peixe[2], info_Rota_Peixe[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
				Etapa[source] = Etapa[source] + 1
				setElementFrozen(Vehicle_Pescador[source], true)
				return
			end
			if Etapa[source] == 2 then
				exports.cmr_dxmessages:outputDx(source, "Leve até o barco!", "info")
				local posx, posy, posz = getElementPosition(Vehicle_Pescador[source])
				MarkerOnPlayer[source] = createMarker(posx, posy, posz, "cylinder", 1.5, 0, 0, 255, 170, source)
				BlipsMarker[source] = createBlip(posx, posy, posz, 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
				Etapa[source] = Etapa[source] + 1
				return
			end
			if Etapa[source] == 3 then
				exports.cmr_dxmessages:outputDx(source, "Leve até o porto!", "info")
				MarkerOnPlayer[source] = createMarker(info_Fim_Rota[1], info_Fim_Rota[2], info_Fim_Rota[3],  "checkpoint", 3, 0, 0, 255, 170, source)
				BlipsMarker[source] = createBlip(info_Fim_Rota[1], info_Fim_Rota[2], info_Fim_Rota[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
				Etapa[source] = Etapa[source] + 1
				setElementFrozen(Vehicle_Pescador[source], false)
				return
			end
			if Etapa[source] == 4 then
				local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE NomeEmprego='Pescador'"), -1)
				for a, job in ipairs(ListItems) do
					if job["ValorMin"] and job["ValorMax"] then
						local acc = getPlayerAccount(source)
						valorPlayer = math.random(tonumber(job["ValorMin"]), tonumber(job["ValorMax"]))
						givePlayerMoney(source, valorPlayer)
						exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
						setElementData(source, "CMR:PescadorTrab", nil)
						setAccountData(acc, "CMR:PescadorTrab", nil)
						if isElement(Vehicle_Pescador[source]) then
							destroyElement(Vehicle_Pescador[source])
							Vehicle_Pescador[source] = nil
						end
						setTimer(setElementPosition, 300, 1, source, EmpregosInformacao["Pescador"]["TelePortDesepawn"][1], EmpregosInformacao["Pescador"]["TelePortDesepawn"][2], EmpregosInformacao["Pescador"]["TelePortDesepawn"][3])
						return
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerMarkerHit", root, CMR_Pescador_Marker)


function CMR_Pescador_Finalizar()
	local acc = getPlayerAccount(source)
	if (getElementData(source, "CMR:PescadorTrab") or getAccountData(acc, "CMR:PescadorTrab") or false) then
		exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você morreu !", "error")
		destroyElement(MarkerOnPlayer[source])
		if BlipsMarker[source] then
			destroyElement(BlipsMarker[source])
		end
		setElementData(source, "CMR:PescadorTrab", nil)
		setAccountData(acc, "CMR:PescadorTrab", nil)
		if isElement(Vehicle_Pescador[source]) then
			destroyElement(Vehicle_Pescador[source])
			Vehicle_Pescador[source] = nil
		end
		setElementData(source, "CMR:Aviso", nil)
	end
end
addEventHandler("onPlayerQuit", root, CMR_Pescador_Finalizar)
addEventHandler("onPlayerWasted", root, CMR_Pescador_Finalizar)


function CMR_Pescador_IniciarFinalizar()
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not (getElementData(source, "CMR:PescadorTrab") or getAccountData(acc, "CMR:PescadorTrab") or false) then
				local infJob = EmpregosInformacao["Pescador"]
				exports.cmr_dxmessages:outputDx(source, "Serviço iniciado com sucesso!", "success")
				setElementData(source, "CMR:PescadorTrab", "Y")
				setAccountData(acc, "CMR:PescadorTrab", "Y")
				Vehicle_Pescador[source] = createVehicle(tonumber(infJob["barcoID"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2], infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				setElementData(Vehicle_Pescador[source], "CMR:Dono", getElementData(source, "ID"))
				warpPedIntoVehicle(source, Vehicle_Pescador[source])
				CMR_Pescador_IniciarJob(source)
			else
				exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
				setElementData(source, "CMR:PescadorTrab", nil)
				setAccountData(acc, "CMR:PescadorTrab", nil)
				if isElement(Vehicle_Pescador[source]) then
					destroyElement(Vehicle_Pescador[source])
					Vehicle_Pescador[source] = nil
				end
				if isElement(MarkerOnPlayer[source]) then
					destroyElement(MarkerOnPlayer[source])
				end
				if isElement(BlipsMarker[source]) then
					destroyElement(BlipsMarker[source])
				end
				if isElement(RotaAtual[source]) then
					destroyElement(RotaAtual[source])
				end
			end
			triggerClientEvent(source, "CMR:Pescador:PainelDX", source)
		end
	end
end
addEvent("CMR:Pescador:IniciarFinalizar", true)
addEventHandler("CMR:Pescador:IniciarFinalizar", root, CMR_Pescador_IniciarFinalizar)