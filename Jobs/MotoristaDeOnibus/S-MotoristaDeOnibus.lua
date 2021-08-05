------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local MarkerTrabalhar_MotoristaDeOnibus

local Vehicle_MotoristaDeOnibus = {}

local MarkerOnPlayer = {}

local RotaAtual = {}

local BlipsMarker = {}

local Etapa = {}

local Timer = {}

function CMR_MotoristaDeOnibus_Init(res)
	if res == getThisResource() then
		local infJob = EmpregosInformacao["Motorista de Ônibus"]["pos"]
		MarkerTrabalhar_MotoristaDeOnibus = createPickup(infJob[1], infJob[2], infJob[3], 3, 1275, 1)
		createBlipAttachedTo(MarkerTrabalhar_MotoristaDeOnibus, 42)
		addEventHandler("onPickupHit", MarkerTrabalhar_MotoristaDeOnibus, CMR_MotoristaDeOnibus_Verificar)
	end
end
addEventHandler("onResourceStart", root, CMR_MotoristaDeOnibus_Init)

function CMR_MotoristaDeOnibus_Verificar(source)
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not isGuestAccount(acc) then
				if (getElementData(source, "Emprego") or getAccountData(acc, "Emprego") or false) == "Motorista de Ônibus" then
					triggerClientEvent(source, "CMR:MotoristaDeOnibus:PainelDX", source)
				end
			end
		end
	end
end

function CMR_MotoristaDeOnibus_IniciarJob(source)
	rota = math.random(1,2)
	if isElement(MarkerOnPlayer[source]) then
		destroyElement(MarkerOnPlayer[source])
	end
	if isElement(BlipsMarker[source]) then
		destroyElement(BlipsMarker[source])
	end
	if isElement(RotaAtual[source]) then
		destroyElement(RotaAtual[source])
	end
	local info_Rota = EmpregosInformacao["Motorista de Ônibus"][rota.."_Rota"]
	MarkerOnPlayer[source] = createMarker(info_Rota[1], info_Rota[2], info_Rota[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
	BlipsMarker[source] = createBlip(info_Rota[1], info_Rota[2], info_Rota[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
	RotaAtual[source] = rota
	Etapa[source] = 1
	Timer[source] = setTimer(function(source)
		local acc = getPlayerAccount(source)
		local veh = getPedOccupiedVehicle(source)
		if isElement(Vehicle_MotoristaDeOnibus[source]) then
			if veh ~= Vehicle_MotoristaDeOnibus[source] then
				if not getElementData(source, "CMR:Aviso") then
					exports.cmr_dxmessages:outputDx(source, "Volte para o veículo em até 30 segundos!", "error")
					setElementData(source, "CMR:Aviso", true)
					setTimer(function(source)
						local veh = getPedOccupiedVehicle(source)
						if veh ~= Vehicle_MotoristaDeOnibus[source] then
							if (getElementData(source, "CMR:MotoristaDeOnibusTrab") or getAccountData(acc, "CMR:MotoristaDeOnibusTrab") or false) then
								exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você saiu do veículo!", "error")
								destroyElement(MarkerOnPlayer[source])
								if BlipsMarker[source] then
									destroyElement(BlipsMarker[source])
								end
								setElementData(source, "CMR:MotoristaDeOnibusTrab", nil)
								setAccountData(acc, "CMR:MotoristaDeOnibusTrab", nil)
								if isElement(Vehicle_MotoristaDeOnibus[source]) then
									destroyElement(Vehicle_MotoristaDeOnibus[source])
									Vehicle_MotoristaDeOnibus[source] = nil
								end
								if Timer[source] then
									killTimer(Timer[source])
								end
								setElementData(source, "CMR:Aviso", nil)
							end
						else
							setElementData(source, "CMR:Aviso", nil)
						end
					end, 30000, 1, source)
				end
			end
		end
	end, 1000, 0, source)
end

function CMR_MotoristaDeOnibus_Marker(mark)
	if mark then
		if mark == MarkerOnPlayer[source] then
			local info_Rota = EmpregosInformacao["Motorista de Ônibus"][RotaAtual[source].."_Rota"]
			local info_Fim_Rota = EmpregosInformacao["Motorista de Ônibus"]["Fim_Rota"]
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			if Etapa[source] == 1 then
				exports.cmr_dxmessages:outputDx(source, "Aguarde até os passageiros descer!", "info")
				MarkerOnPlayer[source] = createMarker(info_Fim_Rota[1], info_Fim_Rota[2], info_Fim_Rota[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
				BlipsMarker[source] = createBlip(info_Fim_Rota[1], info_Fim_Rota[2], info_Fim_Rota[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
				setElementFrozen(Vehicle_MotoristaDeOnibus[source], true)
				setTimer(function(source)
					exports.cmr_dxmessages:outputDx(source, "Pronto! Agora devolva o ônibus!", "info")
					setElementFrozen(Vehicle_MotoristaDeOnibus[source], false)
				end, 10000, 1, source)
				Etapa[source] = Etapa[source] + 1
				return
			end
			if Etapa[source] == 2 then
				local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE NomeEmprego='Motorista de Ônibus'"), -1)
				for a, job in ipairs(ListItems) do
					if job["ValorMin"] and job["ValorMax"] then
						local acc = getPlayerAccount(source)
						valorPlayer = math.random(tonumber(job["ValorMin"]), tonumber(job["ValorMax"]))
						givePlayerMoney(source, valorPlayer)
						exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
						setElementData(source, "CMR:MotoristaDeOnibusTrab", nil)
						setAccountData(acc, "CMR:MotoristaDeOnibusTrab", nil)
						if isElement(Vehicle_MotoristaDeOnibus[source]) then
							destroyElement(Vehicle_MotoristaDeOnibus[source])
							Vehicle_MotoristaDeOnibus[source] = nil
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
addEventHandler("onPlayerMarkerHit", root, CMR_MotoristaDeOnibus_Marker)


function CMR_MotoristaDeOnibus_Finalizar()
	local acc = getPlayerAccount(source)
	if (getElementData(source, "CMR:MotoristaDeOnibusTrab") or getAccountData(acc, "CMR:MotoristaDeOnibusTrab") or false) then
		exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você morreu !", "error")
		destroyElement(MarkerOnPlayer[source])
		if BlipsMarker[source] then
			destroyElement(BlipsMarker[source])
		end
		setElementData(source, "CMR:MotoristaDeOnibusTrab", nil)
		setAccountData(acc, "CMR:MotoristaDeOnibusTrab", nil)
		if isElement(Vehicle_MotoristaDeOnibus[source]) then
			destroyElement(Vehicle_MotoristaDeOnibus[source])
			Vehicle_MotoristaDeOnibus[source] = nil
		end
		if Timer[source] then
			killTimer(Timer[source])
		end
		setElementData(source, "CMR:Aviso", nil)
	end
end
addEventHandler("onPlayerQuit", root, CMR_MotoristaDeOnibus_Finalizar)
addEventHandler("onPlayerWasted", root, CMR_MotoristaDeOnibus_Finalizar)


function CMR_MotoristaDeOnibus_IniciarFinalizar()
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not (getElementData(source, "CMR:MotoristaDeOnibusTrab") or getAccountData(acc, "CMR:MotoristaDeOnibusTrab") or false) then
				local infJob = EmpregosInformacao["Motorista de Ônibus"]
				exports.cmr_dxmessages:outputDx(source, "Serviço iniciado com sucesso!", "success")
				setElementData(source, "CMR:MotoristaDeOnibusTrab", "Y")
				setAccountData(acc, "CMR:MotoristaDeOnibusTrab", "Y")
				Vehicle_MotoristaDeOnibus[source] = createVehicle(tonumber(infJob["busaoID"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2], infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				setElementData(Vehicle_MotoristaDeOnibus[source], "CMR:Dono", getElementData(source, "ID"))
				warpPedIntoVehicle(source, Vehicle_MotoristaDeOnibus[source])
				CMR_MotoristaDeOnibus_IniciarJob(source)
			else
				exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
				setElementData(source, "CMR:MotoristaDeOnibusTrab", nil)
				setAccountData(acc, "CMR:MotoristaDeOnibusTrab", nil)
				if isElement(Vehicle_MotoristaDeOnibus[source]) then
					destroyElement(Vehicle_MotoristaDeOnibus[source])
					Vehicle_MotoristaDeOnibus[source] = nil
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
			triggerClientEvent(source, "CMR:MotoristaDeOnibus:PainelDX", source)
		end
	end
end
addEvent("CMR:MotoristaDeOnibus:IniciarFinalizar", true)
addEventHandler("CMR:MotoristaDeOnibus:IniciarFinalizar", root, CMR_MotoristaDeOnibus_IniciarFinalizar)