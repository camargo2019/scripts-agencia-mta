------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local MarkerTrabalhar_Caminhoneiro

local Vehicle_Caminhoneiro = {}

local Vehicle_Caminhoneiro2 = {}

local MarkerOnPlayer = {}

local RotaAtual = {}

local BlipsMarker = {}

local Etapa = {}

local Timer = {}

function CMR_Caminhoneiro_Init(res)
	if res == getThisResource() then
		local infJob = EmpregosInformacao["Caminhoneiro"]["pos"]
		MarkerTrabalhar_Caminhoneiro = createPickup(infJob[1], infJob[2], infJob[3], 3, 1275, 1)
		createBlipAttachedTo(MarkerTrabalhar_Caminhoneiro, 42)
		addEventHandler("onPickupHit", MarkerTrabalhar_Caminhoneiro, CMR_Caminhoneiro_Verificar)
	end
end
addEventHandler("onResourceStart", root, CMR_Caminhoneiro_Init)

function CMR_Caminhoneiro_Verificar(source)
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not isGuestAccount(acc) then
				if (getElementData(source, "Emprego") or getAccountData(acc, "Emprego") or false) == "Caminhoneiro" then
					triggerClientEvent(source, "CMR:Caminhoneiro:PainelDX", source)
				end
			end
		end
	end
end

function CMR_Caminhoneiro_IniciarJob(source)
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
	local info_Rota = EmpregosInformacao["Caminhoneiro"][rota.."_Rota"]
	MarkerOnPlayer[source] = createMarker(info_Rota[1], info_Rota[2], info_Rota[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
	BlipsMarker[source] = createBlip(info_Rota[1], info_Rota[2], info_Rota[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
	RotaAtual[source] = rota
	Etapa[source] = 1
	Timer[source] = setTimer(function(source)
		local acc = getPlayerAccount(source)
		local veh = getPedOccupiedVehicle(source)
		if veh == Vehicle_Caminhoneiro[source] then
			if not getVehicleTowedByVehicle(Vehicle_Caminhoneiro[source]) then
				if isElement(Vehicle_Caminhoneiro2[source]) then
					exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você perdeu a carga!", "error")
					destroyElement(MarkerOnPlayer[source])
					if BlipsMarker[source] then
						destroyElement(BlipsMarker[source])
					end
					setElementData(source, "CMR:CaminhoneiroTrab", nil)
					setAccountData(acc, "CMR:CaminhoneiroTrab", nil)
					if isElement(Vehicle_Caminhoneiro[source]) then
						destroyElement(Vehicle_Caminhoneiro[source])
						Vehicle_Caminhoneiro[source] = nil
					end
					if isElement(Vehicle_Caminhoneiro2[source]) then
						destroyElement(Vehicle_Caminhoneiro2[source])
						Vehicle_Caminhoneiro2[source] = nil
					end
					if Timer[source] then
						killTimer(Timer[source])
					end
				end
			end
		else
			exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você saiu do veiculo !", "error")
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			setElementData(source, "CMR:CaminhoneiroTrab", nil)
			setAccountData(acc, "CMR:CaminhoneiroTrab", nil)
			if isElement(Vehicle_Caminhoneiro[source]) then
				destroyElement(Vehicle_Caminhoneiro[source])
				Vehicle_Caminhoneiro[source] = nil
			end
			if isElement(Vehicle_Caminhoneiro2[source]) then
				destroyElement(Vehicle_Caminhoneiro2[source])
				Vehicle_Caminhoneiro2[source] = nil
			end
			if Timer[source] then
				killTimer(Timer[source])
			end
		end
	end, 1000, 0, source) 
end

function CMR_Caminhoneiro_Marker(mark)
	if mark then
		if mark == MarkerOnPlayer[source] then
			local info_Rota = EmpregosInformacao["Caminhoneiro"][RotaAtual[source].."_Rota"]
			local info_Fim_Rota = EmpregosInformacao["Caminhoneiro"]["Fim_Rota"]
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			if Etapa[source] == 1 then
				exports.cmr_dxmessages:outputDx(source, "Entrega feita! Agora devolva o caminhão!", "info")
				MarkerOnPlayer[source] = createMarker(info_Fim_Rota[1], info_Fim_Rota[2], info_Fim_Rota[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
				BlipsMarker[source] = createBlip(info_Fim_Rota[1], info_Fim_Rota[2], info_Fim_Rota[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
				Etapa[source] = Etapa[source] + 1
				if isElement(Vehicle_Caminhoneiro2[source]) then
					destroyElement(Vehicle_Caminhoneiro2[source])
					Vehicle_Caminhoneiro2[source] = nil
				end
				return
			end
			if Etapa[source] == 2 then
				local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE NomeEmprego='Caminhoneiro'"), -1)
				for a, job in ipairs(ListItems) do
					if job["ValorMin"] and job["ValorMax"] then
						local acc = getPlayerAccount(source)
						valorPlayer = math.random(tonumber(job["ValorMin"]), tonumber(job["ValorMax"]))
						givePlayerMoney(source, valorPlayer)
						exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
						setElementData(source, "CMR:CaminhoneiroTrab", nil)
						setAccountData(acc, "CMR:CaminhoneiroTrab", nil)
						if isElement(Vehicle_Caminhoneiro[source]) then
							destroyElement(Vehicle_Caminhoneiro[source])
							Vehicle_Caminhoneiro[source] = nil
						end
						if Timer[source] then
							killTimer(Timer[source])
						end
						return
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerMarkerHit", root, CMR_Caminhoneiro_Marker)


function CMR_Caminhoneiro_Finalizar()
	local acc = getPlayerAccount(source)
	if (getElementData(source, "CMR:CaminhoneiroTrab") or getAccountData(acc, "CMR:CaminhoneiroTrab") or false) then
		exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você morreu !", "error")
		destroyElement(MarkerOnPlayer[source])
		if BlipsMarker[source] then
			destroyElement(BlipsMarker[source])
		end
		setElementData(source, "CMR:CaminhoneiroTrab", nil)
		setAccountData(acc, "CMR:CaminhoneiroTrab", nil)
		if isElement(Vehicle_Caminhoneiro[source]) then
			destroyElement(Vehicle_Caminhoneiro[source])
			Vehicle_Caminhoneiro[source] = nil
		end
		if Timer[source] then
			killTimer(Timer[source])
		end
	end
end
addEventHandler("onPlayerQuit", root, CMR_Caminhoneiro_Finalizar)
addEventHandler("onPlayerWasted", root, CMR_Caminhoneiro_Finalizar)


function CMR_Caminhoneiro_IniciarFinalizar()
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not (getElementData(source, "CMR:CaminhoneiroTrab") or getAccountData(acc, "CMR:CaminhoneiroTrab") or false) then
				local infJob = EmpregosInformacao["Caminhoneiro"]
				exports.cmr_dxmessages:outputDx(source, "Serviço iniciado com sucesso!", "success")
				setElementData(source, "CMR:CaminhoneiroTrab", "Y")
				setAccountData(acc, "CMR:CaminhoneiroTrab", "Y")
				Vehicle_Caminhoneiro[source] = createVehicle(tonumber(infJob["caminhaoID"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2], infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				Vehicle_Caminhoneiro2[source] = createVehicle(tonumber(infJob["caminhaoID2"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2]+7, infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				setTimer(function(source)
					attachTrailerToVehicle(Vehicle_Caminhoneiro[source], Vehicle_Caminhoneiro2[source])
				end, 50, 1, source)
				setElementData(Vehicle_Caminhoneiro[source], "CMR:Dono", getElementData(source, "ID"))
				warpPedIntoVehicle(source, Vehicle_Caminhoneiro[source])
				CMR_Caminhoneiro_IniciarJob(source)
			else
				exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
				setElementData(source, "CMR:CaminhoneiroTrab", nil)
				setAccountData(acc, "CMR:CaminhoneiroTrab", nil)
				if isElement(Vehicle_Caminhoneiro[source]) then
					destroyElement(Vehicle_Caminhoneiro[source])
					Vehicle_Caminhoneiro[source] = nil
				end
				if isElement(Vehicle_Caminhoneiro2[source]) then
					destroyElement(Vehicle_Caminhoneiro2[source])
					Vehicle_Caminhoneiro2[source] = nil
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
				if Timer[source] then
					killTimer(Timer[source])
				end
			end
			triggerClientEvent(source, "CMR:Caminhoneiro:PainelDX", source)
		end
	end
end
addEvent("CMR:Caminhoneiro:IniciarFinalizar", true)
addEventHandler("CMR:Caminhoneiro:IniciarFinalizar", root, CMR_Caminhoneiro_IniciarFinalizar)