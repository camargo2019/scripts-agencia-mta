------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local MarkerTrabalhar_EntregadordeJornal

local Vehicle_EntregadordeJornal = {}

local MarkerOnPlayer = {}

local MarkerAtual = {}

local RotaAtual = {}

local BlipsMarker = {}

local Timer = {}

function CMR_EntregadordeJornal_Init(res)
	if res == getThisResource() then
		local infJob = EmpregosInformacao["Entregador de Jornal"]["pos"]
		MarkerTrabalhar_EntregadordeJornal = createPickup(infJob[1], infJob[2], infJob[3], 3, 1275, 1)
		createBlipAttachedTo(MarkerTrabalhar_EntregadordeJornal, 42)
		addEventHandler("onPickupHit", MarkerTrabalhar_EntregadordeJornal, CMR_EntregadordeJornal_Verificar)
	end
end
addEventHandler("onResourceStart", root, CMR_EntregadordeJornal_Init)

function CMR_EntregadordeJornal_Verificar(source)
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not isGuestAccount(acc) then
				if (getElementData(source, "Emprego") or getAccountData(acc, "Emprego") or false) == "Entregador de Jornal" then
					triggerClientEvent(source, "CMR:EntregadordeJornal:PainelDX", source)
				end
			end
		end
	end
end

function CMR_EntregadordeJornal_IniciarJob(source)
	rota = math.random(1,3)
	local info_Rota = EmpregosInformacao["Entregador de Jornal"][rota.."_Rota"]
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
		if isElement(Vehicle_EntregadordeJornal[source]) then
			if veh ~= Vehicle_EntregadordeJornal[source] then
				if not getElementData(source, "CMR:Aviso") then
					exports.cmr_dxmessages:outputDx(source, "Volte pra bike em at?? 30 segundos!", "error")
					setElementData(source, "CMR:Aviso", true)
					setTimer(function(source)
						local veh = getPedOccupiedVehicle(source)
						if veh ~= Vehicle_EntregadordeJornal[source] then
							if (getElementData(source, "CMR:EntregadordeJornalTrab") or getAccountData(acc, "CMR:EntregadordeJornalTrab") or false) then
								exports.cmr_dxmessages:outputDx(source, "Servi??o finalizado por que voc?? saiu da bike!", "error")
								destroyElement(MarkerOnPlayer[source])
								if BlipsMarker[source] then
									destroyElement(BlipsMarker[source])
								end
								setElementData(source, "CMR:EntregadordeJornalTrab", nil)
								setAccountData(acc, "CMR:EntregadordeJornalTrab", nil)
								if isElement(Vehicle_EntregadordeJornal[source]) then
									destroyElement(Vehicle_EntregadordeJornal[source])
									Vehicle_EntregadordeJornal[source] = nil
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

function CMR_EntregadordeJornal_Marker(mark)
	if mark then
		if mark == MarkerOnPlayer[source] then
			local info_Rota = EmpregosInformacao["Entregador de Jornal"][RotaAtual[source].."_Rota"]
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			for i, v in ipairs(info_Rota) do
				if (MarkerAtual[source]) >= #info_Rota then
					local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE NomeEmprego='Entregador de Jornal'"), -1)
					for a, job in ipairs(ListItems) do
						if job["ValorMin"] and job["ValorMax"] then
							local acc = getPlayerAccount(source)
							valorPlayer = math.random(tonumber(job["ValorMin"]), tonumber(job["ValorMax"]))
							givePlayerMoney(source, valorPlayer)
							exports.cmr_dxmessages:outputDx(source, "Servi??o finalizado com sucesso!", "success")
							setElementData(source, "CMR:EntregadordeJornalTrab", nil)
							setAccountData(acc, "CMR:EntregadordeJornalTrab", nil)
							if isElement(Vehicle_EntregadordeJornal[source]) then
								destroyElement(Vehicle_EntregadordeJornal[source])
								Vehicle_EntregadordeJornal[source] = nil
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
						setElementFrozen(Vehicle_EntregadordeJornal[source], true)
						setTimer(setElementFrozen, 2000, 1, Vehicle_EntregadordeJornal[source], false)
						return
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerMarkerHit", root, CMR_EntregadordeJornal_Marker)


function CMR_EntregadordeJornal_Finalizar()
	local acc = getPlayerAccount(source)
	if (getElementData(source, "CMR:EntregadordeJornalTrab") or getAccountData(acc, "CMR:EntregadordeJornalTrab") or false) then
		exports.cmr_dxmessages:outputDx(source, "Servi??o finalizado por que voc?? morreu !", "error")
		destroyElement(MarkerOnPlayer[source])
		if BlipsMarker[source] then
			destroyElement(BlipsMarker[source])
		end
		setElementData(source, "CMR:EntregadordeJornalTrab", nil)
		setAccountData(acc, "CMR:EntregadordeJornalTrab", nil)
		if isElement(Vehicle_EntregadordeJornal[source]) then
			destroyElement(Vehicle_EntregadordeJornal[source])
			Vehicle_EntregadordeJornal[source] = nil
		end
		if Timer[source] then
			killTimer(Timer[source])
		end
		setElementData(source, "CMR:Aviso", nil)
	end
end
addEventHandler("onPlayerQuit", root, CMR_EntregadordeJornal_Finalizar)
addEventHandler("onPlayerWasted", root, CMR_EntregadordeJornal_Finalizar)


function CMR_EntregadordeJornal_IniciarFinalizar()
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not (getElementData(source, "CMR:EntregadordeJornalTrab") or getAccountData(acc, "CMR:EntregadordeJornalTrab") or false) then
				local infJob = EmpregosInformacao["Entregador de Jornal"]
				exports.cmr_dxmessages:outputDx(source, "Servi??o iniciado com sucesso!", "success")
				setElementData(source, "CMR:EntregadordeJornalTrab", "Y")
				setAccountData(acc, "CMR:EntregadordeJornalTrab", "Y")
				Vehicle_EntregadordeJornal[source] = createVehicle(tonumber(infJob["bikeID"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2], infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				setElementData(Vehicle_EntregadordeJornal[source], "CMR:Dono", getElementData(source, "ID"))
				warpPedIntoVehicle(source, Vehicle_EntregadordeJornal[source])
				CMR_EntregadordeJornal_IniciarJob(source)
			else
				exports.cmr_dxmessages:outputDx(source, "Servi??o finalizado com sucesso!", "success")
				setElementData(source, "CMR:EntregadordeJornalTrab", nil)
				setAccountData(acc, "CMR:EntregadordeJornalTrab", nil)
				if isElement(Vehicle_EntregadordeJornal[source]) then
					destroyElement(Vehicle_EntregadordeJornal[source])
					Vehicle_EntregadordeJornal[source] = nil
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
			triggerClientEvent(source, "CMR:EntregadordeJornal:PainelDX", source)
		end
	end
end
addEvent("CMR:EntregadordeJornal:IniciarFinalizar", true)
addEventHandler("CMR:EntregadordeJornal:IniciarFinalizar", root, CMR_EntregadordeJornal_IniciarFinalizar)