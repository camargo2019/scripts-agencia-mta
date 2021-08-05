------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local MarkerTrabalhar_EntregadordeGas

local Vehicle_EntregadordeGas = {}

local MarkerOnPlayer = {}

local MarkerAtual = {}

local RotaAtual = {}

local BlipsMarker = {}

local Timer = {}

function CMR_EntregadordeGas_Init(res)
	if res == getThisResource() then
		local infJob = EmpregosInformacao["Entregador de Gás"]["pos"]
		MarkerTrabalhar_EntregadordeGas = createPickup(infJob[1], infJob[2], infJob[3], 3, 1275, 1)
		createBlipAttachedTo(MarkerTrabalhar_EntregadordeGas, 42)
		addEventHandler("onPickupHit", MarkerTrabalhar_EntregadordeGas, CMR_EntregadordeGas_Verificar)
	end
end
addEventHandler("onResourceStart", root, CMR_EntregadordeGas_Init)

function CMR_EntregadordeGas_Verificar(source)
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not isGuestAccount(acc) then
				if (getElementData(source, "Emprego") or getAccountData(acc, "Emprego") or false) == "Entregador de Gás" then
					triggerClientEvent(source, "CMR:EntregadordeGas:PainelDX", source)
				end
			end
		end
	end
end

function CMR_EntregadordeGas_IniciarJob(source)
	rota = math.random(1,3)
	local info_Rota = EmpregosInformacao["Entregador de Gás"][rota.."_Rota"]
	for i, v in ipairs(info_Rota) do
		if i == 1 then
			if isElement(MarkerOnPlayer[source]) then
				destroyElement(MarkerOnPlayer[source])
			end
			if isElement(BlipsMarker[source]) then
				destroyElement(BlipsMarker[source])
			end
			if isElement(RotaAtual[source]) then
				destroyElement(RotaAtual[source])
			end
			MarkerOnPlayer[source] = createMarker(v[1], v[2], v[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
			BlipsMarker[source] = createBlip(v[1], v[2], v[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
			MarkerAtual[source] = i
			RotaAtual[source] = rota
		end
	end
	Timer[source] = setTimer(function(source)
		local acc = getPlayerAccount(source)
		local veh = getPedOccupiedVehicle(source)
		if isElement(Vehicle_EntregadordeGas[source]) then
			if veh ~= Vehicle_EntregadordeGas[source] then
				if not getElementData(source, "CMR:Aviso") then
					exports.cmr_dxmessages:outputDx(source, "Volte para veiculo em até 30 segundos!", "error")
					setElementData(source, "CMR:Aviso", true)
					setTimer(function(source)
						local veh = getPedOccupiedVehicle(source)
						if veh ~= Vehicle_EntregadordeGas[source] then
							if (getElementData(source, "CMR:EntregadordeGasTrab") or getAccountData(acc, "CMR:EntregadordeGasTrab") or false) then
								exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você saiu do veiculo!", "error")
								destroyElement(MarkerOnPlayer[source])
								if BlipsMarker[source] then
									destroyElement(BlipsMarker[source])
								end
								setElementData(source, "CMR:EntregadordeGasTrab", nil)
								setAccountData(acc, "CMR:EntregadordeGasTrab", nil)
								if isElement(Vehicle_EntregadordeGas[source]) then
									destroyElement(Vehicle_EntregadordeGas[source])
									Vehicle_EntregadordeGas[source] = nil
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

function CMR_EntregadordeGas_Marker(mark)
	if mark then
		if mark == MarkerOnPlayer[source] then
			local info_Rota = EmpregosInformacao["Entregador de Gás"][RotaAtual[source].."_Rota"]
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			for i, v in ipairs(info_Rota) do
				if (MarkerAtual[source]) >= #info_Rota then
					local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE NomeEmprego='Entregador de Gás'"), -1)
					for a, job in ipairs(ListItems) do
						if job["ValorMin"] and job["ValorMax"] then
							local acc = getPlayerAccount(source)
							valorPlayer = math.random(tonumber(job["ValorMin"]), tonumber(job["ValorMax"]))
							givePlayerMoney(source, valorPlayer)
							exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
							setElementData(source, "CMR:EntregadordeGasTrab", nil)
							setAccountData(acc, "CMR:EntregadordeGasTrab", nil)
							if isElement(Vehicle_EntregadordeGas[source]) then
								destroyElement(Vehicle_EntregadordeGas[source])
								Vehicle_EntregadordeGas[source] = nil
							end
							if Timer[source] then
								killTimer(Timer[source])
							end
							return
						end
					end
				else
					if i == (MarkerAtual[source]+1) then
						MarkerOnPlayer[source] = createMarker(v[1], v[2], v[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
						BlipsMarker[source] = createBlip(v[1], v[2], v[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
						MarkerAtual[source] = i
						setElementFrozen(Vehicle_EntregadordeGas[source], true)
						setTimer(setElementFrozen, 2000, 1, Vehicle_EntregadordeGas[source], false)
						return
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerMarkerHit", root, CMR_EntregadordeGas_Marker)


function CMR_EntregadordeGas_Finalizar()
	local acc = getPlayerAccount(source)
	if (getElementData(source, "CMR:EntregadordeGasTrab") or getAccountData(acc, "CMR:EntregadordeGasTrab") or false) then
		exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você morreu !", "error")
		destroyElement(MarkerOnPlayer[source])
		if BlipsMarker[source] then
			destroyElement(BlipsMarker[source])
		end
		setElementData(source, "CMR:EntregadordeGasTrab", nil)
		setAccountData(acc, "CMR:EntregadordeGasTrab", nil)
		if isElement(Vehicle_EntregadordeGas[source]) then
			destroyElement(Vehicle_EntregadordeGas[source])
			Vehicle_EntregadordeGas[source] = nil
		end
		if Timer[source] then
			killTimer(Timer[source])
		end
		setElementData(source, "CMR:Aviso", nil)
	end
end
addEventHandler("onPlayerQuit", root, CMR_EntregadordeGas_Finalizar)
addEventHandler("onPlayerWasted", root, CMR_EntregadordeGas_Finalizar)


function CMR_EntregadordeGas_IniciarFinalizar()
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not (getElementData(source, "CMR:EntregadordeGasTrab") or getAccountData(acc, "CMR:EntregadordeGasTrab") or false) then
				local infJob = EmpregosInformacao["Entregador de Gás"]
				exports.cmr_dxmessages:outputDx(source, "Serviço iniciado com sucesso!", "success")
				setElementData(source, "CMR:EntregadordeGasTrab", "Y")
				setAccountData(acc, "CMR:EntregadordeGasTrab", "Y")
				Vehicle_EntregadordeGas[source] = createVehicle(tonumber(infJob["entregadorID"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2], infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				setElementData(Vehicle_EntregadordeGas[source], "CMR:Dono", getElementData(source, "ID"))
				warpPedIntoVehicle(source, Vehicle_EntregadordeGas[source])
				CMR_EntregadordeGas_IniciarJob(source)
			else
				exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
				setElementData(source, "CMR:EntregadordeGasTrab", nil)
				setAccountData(acc, "CMR:EntregadordeGasTrab", nil)
				if isElement(Vehicle_EntregadordeGas[source]) then
					destroyElement(Vehicle_EntregadordeGas[source])
					Vehicle_EntregadordeGas[source] = nil
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
			triggerClientEvent(source, "CMR:EntregadordeGas:PainelDX", source)
		end
	end
end
addEvent("CMR:EntregadordeGas:IniciarFinalizar", true)
addEventHandler("CMR:EntregadordeGas:IniciarFinalizar", root, CMR_EntregadordeGas_IniciarFinalizar)