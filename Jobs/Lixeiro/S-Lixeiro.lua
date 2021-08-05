------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local MarkerTrabalhar_Lixeiro

local Vehicle_Lixeiro = {}

local MarkerOnPlayer = {}

local MarkerAtual = {}

local RotaAtual = {}

local BlipsMarker = {}

local Timer = {}

function CMR_Lixeiro_Init(res)
	if res == getThisResource() then
		local infJob = EmpregosInformacao["Lixeiro"]["pos"]
		MarkerTrabalhar_Lixeiro = createPickup(infJob[1], infJob[2], infJob[3], 3, 1275, 1)
		createBlipAttachedTo(MarkerTrabalhar_Lixeiro, 42)
		addEventHandler("onPickupHit", MarkerTrabalhar_Lixeiro, CMR_Lixeiro_Verificar)
	end
end
addEventHandler("onResourceStart", root, CMR_Lixeiro_Init)

function CMR_Lixeiro_Verificar(source)
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not isGuestAccount(acc) then
				if (getElementData(source, "Emprego") or getAccountData(acc, "Emprego") or false) == "Lixeiro" then
					triggerClientEvent(source, "CMR:Lixeiro:PainelDX", source)
				end
			end
		end
	end
end

function CMR_Lixeiro_IniciarJob(source)
	rota = math.random(1,3)
	local info_Rota = EmpregosInformacao["Lixeiro"][rota.."_Rota"]
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
		if isElement(Vehicle_Lixeiro[source]) then
			if veh ~= Vehicle_Lixeiro[source] then
				if not getElementData(source, "CMR:Aviso") then
					exports.cmr_dxmessages:outputDx(source, "Volte para o caminhão em até 30 segundos!", "error")
					setElementData(source, "CMR:Aviso", true)
					setTimer(function(source)
						triggerClientEvent(source, "CMR:Lixeiro:AntiColisao", source, Vehicle_Lixeiro[source])
						local veh = getPedOccupiedVehicle(source)
						if veh ~= Vehicle_Lixeiro[source] then
							if (getElementData(source, "CMR:LixeiroTrab") or getAccountData(acc, "CMR:LixeiroTrab") or false) then
								exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você saiu do caminhão!", "error")
								destroyElement(MarkerOnPlayer[source])
								if BlipsMarker[source] then
									destroyElement(BlipsMarker[source])
								end
								setElementData(source, "CMR:LixeiroTrab", nil)
								setAccountData(acc, "CMR:LixeiroTrab", nil)
								if isElement(Vehicle_Lixeiro[source]) then
									destroyElement(Vehicle_Lixeiro[source])
									Vehicle_Lixeiro[source] = nil
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

function CMR_Lixeiro_Marker(mark)
	if mark then
		if mark == MarkerOnPlayer[source] then
			local info_Rota = EmpregosInformacao["Lixeiro"][RotaAtual[source].."_Rota"]
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			for i, v in ipairs(info_Rota) do
				if (MarkerAtual[source]) >= #info_Rota then
					local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE NomeEmprego='Lixeiro'"), -1)
					for a, job in ipairs(ListItems) do
						if job["ValorMin"] and job["ValorMax"] then
							local acc = getPlayerAccount(source)
							valorPlayer = math.random(tonumber(job["ValorMin"]), tonumber(job["ValorMax"]))
							givePlayerMoney(source, valorPlayer)
							exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
							setElementData(source, "CMR:LixeiroTrab", nil)
							setAccountData(acc, "CMR:LixeiroTrab", nil)
							if isElement(Vehicle_Lixeiro[source]) then
								destroyElement(Vehicle_Lixeiro[source])
								Vehicle_Lixeiro[source] = nil
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
						setElementFrozen(Vehicle_Lixeiro[source], true)
						setTimer(setElementFrozen, 10000, 1, Vehicle_Lixeiro[source], false)
						triggerClientEvent(source, "CMR:Lixeiro:Sound", source)
						return
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerMarkerHit", root, CMR_Lixeiro_Marker)


function CMR_Lixeiro_Finalizar()
	local acc = getPlayerAccount(source)
	if (getElementData(source, "CMR:LixeiroTrab") or getAccountData(acc, "CMR:LixeiroTrab") or false) then
		destroyElement(MarkerOnPlayer[source])
		if BlipsMarker[source] then
			destroyElement(BlipsMarker[source])
		end
		exports.cmr_dxmessages:outputDx(source, "Serviço finalizado por que você morreu !", "error")
		setElementData(source, "CMR:LixeiroTrab", nil)
		setAccountData(acc, "CMR:LixeiroTrab", nil)
		if isElement(Vehicle_Lixeiro[source]) then
			destroyElement(Vehicle_Lixeiro[source])
			Vehicle_Lixeiro[source] = nil
		end
		if Timer[source] then
			killTimer(Timer[source])
		end
		setElementData(source, "CMR:Aviso", nil)
	end
end
addEventHandler("onPlayerQuit", root, CMR_Lixeiro_Finalizar)
addEventHandler("onPlayerWasted", root, CMR_Lixeiro_Finalizar)


function CMR_Lixeiro_IniciarFinalizar()
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not (getElementData(source, "CMR:LixeiroTrab") or getAccountData(acc, "CMR:LixeiroTrab") or false) then
				local infJob = EmpregosInformacao["Lixeiro"]
				exports.cmr_dxmessages:outputDx(source, "Serviço iniciado com sucesso!", "success")
				setElementData(source, "CMR:LixeiroTrab", "Y")
				setAccountData(acc, "CMR:LixeiroTrab", "Y")
				Vehicle_Lixeiro[source] = createVehicle(tonumber(infJob["CaminhaoID"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2], infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				setElementData(Vehicle_Lixeiro[source], "CMR:Dono", getElementData(source, "ID"))
				setElementAlpha(Vehicle_Lixeiro[source], 200)
				warpPedIntoVehicle(source, Vehicle_Lixeiro[source])
				triggerClientEvent(source, "CMR:Lixeiro:AntiColisao", source, Vehicle_Lixeiro[source])
				CMR_Lixeiro_IniciarJob(source)
			else
				exports.cmr_dxmessages:outputDx(source, "Serviço finalizado com sucesso!", "success")
				setElementData(source, "CMR:LixeiroTrab", nil)
				setAccountData(acc, "CMR:LixeiroTrab", nil)
				if isElement(Vehicle_Lixeiro[source]) then
					destroyElement(Vehicle_Lixeiro[source])
					Vehicle_Lixeiro[source] = nil
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
			triggerClientEvent(source, "CMR:Lixeiro:PainelDX", source)
		end
	end
end
addEvent("CMR:Lixeiro:IniciarFinalizar", true)
addEventHandler("CMR:Lixeiro:IniciarFinalizar", root, CMR_Lixeiro_IniciarFinalizar)