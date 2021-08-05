------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local MarkerTrabalhar_Fazendeiro

local Vehicle_Fazendeiro = {}

local MarkerOnPlayer = {}

local BlipsMarker = {}

local Etapa = {}

local Timer = {}

local PlantasColher = {}

local MarkerAtual = {}

function CMR_Fazendeiro_Init(res)
	if res == getThisResource() then
		local infJob = EmpregosInformacao["Fazendeiro"]["pos"]
		MarkerTrabalhar_Fazendeiro = createPickup(infJob[1], infJob[2], infJob[3], 3, 1275, 1)
		createBlipAttachedTo(MarkerTrabalhar_Fazendeiro, 42)
		addEventHandler("onPickupHit", MarkerTrabalhar_Fazendeiro, CMR_Fazendeiro_Verificar)
	end
end
addEventHandler("onResourceStart", root, CMR_Fazendeiro_Init)

function CMR_Fazendeiro_Verificar(source)
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not isGuestAccount(acc) then
				if (getElementData(source, "Emprego") or getAccountData(acc, "Emprego") or false) == "Fazendeiro" then
					triggerClientEvent(source, "CMR:Fazendeiro:PainelDX", source)
				end
			end
		end
	end
end

function CMR_Fazendeiro_IniciarJob(source)
	local Plantas = EmpregosInformacao["Fazendeiro"]["Plantas"]
	local ItemID = tonumber(EmpregosInformacao["Fazendeiro"]["ItemID"])
	PlantasColher[source] = {}
	for i, b in ipairs(Plantas) do
		PlantasColher[source][i] = createObject(ItemID, b[1], b[2], b[3]-0.5)
	end
	for i, v in ipairs(Plantas) do
		if i == 1 then
			if isElement(MarkerOnPlayer[source]) then
				destroyElement(MarkerOnPlayer[source])
			end
			if isElement(BlipsMarker[source]) then
				destroyElement(BlipsMarker[source])
			end
			MarkerOnPlayer[source] = createMarker(v[1], v[2], v[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
			BlipsMarker[source] = createBlip(v[1], v[2], v[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
			MarkerAtual[source] = i
		end
	end
	Timer[source] = setTimer(function(source)
		local acc = getPlayerAccount(source)
		local veh = getPedOccupiedVehicle(source)
		if isElement(Vehicle_Fazendeiro[source]) then
			if veh ~= Vehicle_Fazendeiro[source] then
				if not getElementData(source, "CMR:Aviso") then
					exports.cmr_dxmessages:outputDx(source, "Volte pra caminhão em até 30 segundos!", "error")
					setElementData(source, "CMR:Aviso", true)
					setTimer(function(source)
						local veh = getPedOccupiedVehicle(source)
						if veh ~= Vehicle_Fazendeiro[source] then
							if (getElementData(source, "CMR:FazendeiroTrab") or getAccountData(acc, "CMR:FazendeiroTrab") or false) then
								exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você saiu do caminhão!", "error")
								destroyElement(MarkerOnPlayer[source])
								for a, b in ipairs(PlantasColher[source]) do
									if isElement(b) then
										destroyElement(b)
										b = nil
									end
								end
								if BlipsMarker[source] then
									destroyElement(BlipsMarker[source])
								end
								setElementData(source, "CMR:FazendeiroTrab", nil)
								setAccountData(acc, "CMR:FazendeiroTrab", nil)
								if isElement(Vehicle_Fazendeiro[source]) then
									destroyElement(Vehicle_Fazendeiro[source])
									Vehicle_Fazendeiro[source] = nil
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

function CMR_Fazendeiro_Marker(mark)
	if mark then
		if mark == MarkerOnPlayer[source] then
			local info_Rota = EmpregosInformacao["Fazendeiro"]["Plantas"]
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			for i, v in ipairs(info_Rota) do
				if isElement(PlantasColher[source][i]) then
					destroyElement(PlantasColher[source][i])
					PlantasColher[source][i] = nil
				end
				if (MarkerAtual[source]) >= #info_Rota then
					local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE NomeEmprego='Fazendeiro'"), -1)
					for a, job in ipairs(ListItems) do
						if job["ValorMin"] and job["ValorMax"] then
							local acc = getPlayerAccount(source)
							valorPlayer = math.random(tonumber(job["ValorMin"]), tonumber(job["ValorMax"]))
							givePlayerMoney(source, valorPlayer)
							exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
							for a, b in ipairs(PlantasColher[source]) do
								if isElement(b) then
									destroyElement(b)
									b = nil
								end
							end
							setElementData(source, "CMR:FazendeiroTrab", nil)
							setAccountData(acc, "CMR:FazendeiroTrab", nil)
							if isElement(Vehicle_Fazendeiro[source]) then
								destroyElement(Vehicle_Fazendeiro[source])
								Vehicle_Fazendeiro[source] = nil
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
						setElementFrozen(Vehicle_Fazendeiro[source], true)
						setTimer(setElementFrozen, 2000, 1, Vehicle_Fazendeiro[source], false)
						return
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerMarkerHit", root, CMR_Fazendeiro_Marker)


function CMR_Fazendeiro_Finalizar()
	local acc = getPlayerAccount(source)
	if (getElementData(source, "CMR:FazendeiroTrab") or getAccountData(acc, "CMR:FazendeiroTrab") or false) then
		exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você morreu !", "error")
		destroyElement(MarkerOnPlayer[source])
		if BlipsMarker[source] then
			destroyElement(BlipsMarker[source])
		end
		for a, b in ipairs(PlantasColher[source]) do
			if isElement(b) then
				destroyElement(b)
				b = nil
			end
		end
		setElementData(source, "CMR:FazendeiroTrab", nil)
		setAccountData(acc, "CMR:FazendeiroTrab", nil)
		if isElement(Vehicle_Fazendeiro[source]) then
			destroyElement(Vehicle_Fazendeiro[source])
			Vehicle_Fazendeiro[source] = nil
		end
		if Timer[source] then
			killTimer(Timer[source])
		end
		setElementData(source, "CMR:Aviso", nil)
	end
end
addEventHandler("onPlayerQuit", root, CMR_Fazendeiro_Finalizar)
addEventHandler("onPlayerWasted", root, CMR_Fazendeiro_Finalizar)


function CMR_Fazendeiro_IniciarFinalizar()
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not (getElementData(source, "CMR:FazendeiroTrab") or getAccountData(acc, "CMR:FazendeiroTrab") or false) then
				local infJob = EmpregosInformacao["Fazendeiro"]
				exports.cmr_dxmessages:outputDx(source, "Serviço iniciado com sucesso!", "success")
				setElementData(source, "CMR:FazendeiroTrab", "Y")
				setAccountData(acc, "CMR:FazendeiroTrab", "Y")
				Vehicle_Fazendeiro[source] = createVehicle(tonumber(infJob["fazendeiroID"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2], infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				setElementData(Vehicle_Fazendeiro[source], "CMR:Dono", getElementData(source, "ID"))
				warpPedIntoVehicle(source, Vehicle_Fazendeiro[source])
				CMR_Fazendeiro_IniciarJob(source)
			else
				local infJob = EmpregosInformacao["Fazendeiro"]
				exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
				setElementData(source, "CMR:FazendeiroTrab", nil)
				setAccountData(acc, "CMR:FazendeiroTrab", nil)
				for a, b in ipairs(PlantasColher[source]) do
					if isElement(PlantasColher[source][a]) then
						destroyElement(PlantasColher[source][a])
						PlantasColher[source][a] = nil
					end
				end
				if isElement(Vehicle_Fazendeiro[source]) then
					destroyElement(Vehicle_Fazendeiro[source])
					Vehicle_Fazendeiro[source] = nil
				end
				if isElement(MarkerOnPlayer[source]) then
					destroyElement(MarkerOnPlayer[source])
				end
				if isElement(BlipsMarker[source]) then
					destroyElement(BlipsMarker[source])
				end
				if Timer[source] then
					killTimer(Timer[source])
				end
			end
			triggerClientEvent(source, "CMR:Fazendeiro:PainelDX", source)
		end
	end
end
addEvent("CMR:Fazendeiro:IniciarFinalizar", true)
addEventHandler("CMR:Fazendeiro:IniciarFinalizar", root, CMR_Fazendeiro_IniciarFinalizar)