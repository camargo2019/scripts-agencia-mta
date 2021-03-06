------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local MarkerTrabalhar_Leiteiro

local Vehicle_Leiteiro = {}

local MarkerOnPlayer = {}

local RotaAtual = {}

local BlipsMarker = {}

local Etapa = {}

local Timer = {}

function CMR_Leiteiro_Init(res)
	if res == getThisResource() then
		local infJob = EmpregosInformacao["Leiteiro"]["pos"]
		MarkerTrabalhar_Leiteiro = createPickup(infJob[1], infJob[2], infJob[3], 3, 1275, 1)
		createBlipAttachedTo(MarkerTrabalhar_Leiteiro, 42)
		addEventHandler("onPickupHit", MarkerTrabalhar_Leiteiro, CMR_Leiteiro_Verificar)
	end
end
addEventHandler("onResourceStart", root, CMR_Leiteiro_Init)

function CMR_Leiteiro_Verificar(source)
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not isGuestAccount(acc) then
				if (getElementData(source, "Emprego") or getAccountData(acc, "Emprego") or false) == "Leiteiro" then
					triggerClientEvent(source, "CMR:Leiteiro:PainelDX", source)
				end
			end
		end
	end
end

function CMR_Leiteiro_IniciarJob(source)
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
	local info_Rota = EmpregosInformacao["Leiteiro"][rota.."_Rota"]
	MarkerOnPlayer[source] = createMarker(info_Rota[1], info_Rota[2], info_Rota[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
	BlipsMarker[source] = createBlip(info_Rota[1], info_Rota[2], info_Rota[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
	RotaAtual[source] = rota
	Etapa[source] = 1
	Timer[source] = setTimer(function(source)
		local acc = getPlayerAccount(source)
		local veh = getPedOccupiedVehicle(source)
		if isElement(Vehicle_Leiteiro[source]) then
			if veh ~= Vehicle_Leiteiro[source] then
				if not getElementData(source, "CMR:Aviso") then
					exports.cmr_dxmessages:outputDx(source, "Volte para o ve??culo em at?? 30 segundos!", "error")
					setElementData(source, "CMR:Aviso", true)
					setTimer(function(source)
						local veh = getPedOccupiedVehicle(source)
						if veh ~= Vehicle_Leiteiro[source] then
							if (getElementData(source, "CMR:LeiteiroTrab") or getAccountData(acc, "CMR:LeiteiroTrab") or false) then
								exports.cmr_dxmessages:outputDx(source, "Servi??o finalizado por que voc?? saiu do ve??culo!", "error")
								destroyElement(MarkerOnPlayer[source])
								if BlipsMarker[source] then
									destroyElement(BlipsMarker[source])
								end
								setElementData(source, "CMR:LeiteiroTrab", nil)
								setAccountData(acc, "CMR:LeiteiroTrab", nil)
								if isElement(Vehicle_Leiteiro[source]) then
									destroyElement(Vehicle_Leiteiro[source])
									Vehicle_Leiteiro[source] = nil
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

function CMR_Leiteiro_Marker(mark)
	if mark then
		if mark == MarkerOnPlayer[source] then
			local info_Rota = EmpregosInformacao["Leiteiro"][RotaAtual[source].."_Rota"]
			local info_Fim_Rota = EmpregosInformacao["Leiteiro"]["Fim_Rota"]
			destroyElement(MarkerOnPlayer[source])
			if BlipsMarker[source] then
				destroyElement(BlipsMarker[source])
			end
			if Etapa[source] == 1 then
				exports.cmr_dxmessages:outputDx(source, "Aguarde at?? descarregar!", "info")
				MarkerOnPlayer[source] = createMarker(info_Fim_Rota[1], info_Fim_Rota[2], info_Fim_Rota[3]-1, "checkpoint", 3, 0, 0, 255, 170, source)
				BlipsMarker[source] = createBlip(info_Fim_Rota[1], info_Fim_Rota[2], info_Fim_Rota[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
				setElementFrozen(Vehicle_Leiteiro[source], true)
				setTimer(function(source)
					exports.cmr_dxmessages:outputDx(source, "Entrega feita! Agora devolva o ve??culo!", "info")
					setElementFrozen(Vehicle_Leiteiro[source], false)
				end, 10000, 1, source)
				Etapa[source] = Etapa[source] + 1
				return
			end
			if Etapa[source] == 2 then
				local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE NomeEmprego='Leiteiro'"), -1)
				for a, job in ipairs(ListItems) do
					if job["ValorMin"] and job["ValorMax"] then
						local acc = getPlayerAccount(source)
						valorPlayer = math.random(tonumber(job["ValorMin"]), tonumber(job["ValorMax"]))
						givePlayerMoney(source, valorPlayer)
						exports.cmr_dxmessages:outputDx(source, "Servi??o finalizado com sucesso!", "success")
						setElementData(source, "CMR:LeiteiroTrab", nil)
						setAccountData(acc, "CMR:LeiteiroTrab", nil)
						if isElement(Vehicle_Leiteiro[source]) then
							destroyElement(Vehicle_Leiteiro[source])
							Vehicle_Leiteiro[source] = nil
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
addEventHandler("onPlayerMarkerHit", root, CMR_Leiteiro_Marker)


function CMR_Leiteiro_Finalizar()
	local acc = getPlayerAccount(source)
	if (getElementData(source, "CMR:LeiteiroTrab") or getAccountData(acc, "CMR:LeiteiroTrab") or false) then
		exports.cmr_dxmessages:outputDx(source, "Servi??o finalizado por que voc?? morreu !", "error")
		destroyElement(MarkerOnPlayer[source])
		if BlipsMarker[source] then
			destroyElement(BlipsMarker[source])
		end
		setElementData(source, "CMR:LeiteiroTrab", nil)
		setAccountData(acc, "CMR:LeiteiroTrab", nil)
		if isElement(Vehicle_Leiteiro[source]) then
			destroyElement(Vehicle_Leiteiro[source])
			Vehicle_Leiteiro[source] = nil
		end
		if Timer[source] then
			killTimer(Timer[source])
		end
		setElementData(source, "CMR:Aviso", nil)
	end
end
addEventHandler("onPlayerQuit", root, CMR_Leiteiro_Finalizar)
addEventHandler("onPlayerWasted", root, CMR_Leiteiro_Finalizar)


function CMR_Leiteiro_IniciarFinalizar()
	if isElement(source) then
		if getElementType(source) == "player" then
			local acc = getPlayerAccount(source)
			if not (getElementData(source, "CMR:LeiteiroTrab") or getAccountData(acc, "CMR:LeiteiroTrab") or false) then
				local infJob = EmpregosInformacao["Leiteiro"]
				exports.cmr_dxmessages:outputDx(source, "Servi??o iniciado com sucesso!", "success")
				setElementData(source, "CMR:LeiteiroTrab", "Y")
				setAccountData(acc, "CMR:LeiteiroTrab", "Y")
				Vehicle_Leiteiro[source] = createVehicle(tonumber(infJob["leiteiroID"]), infJob["SpawnLoc"][1], infJob["SpawnLoc"][2], infJob["SpawnLoc"][3], 0, 0, infJob["SpawnLoc"][4])
				setElementData(Vehicle_Leiteiro[source], "CMR:Dono", getElementData(source, "ID"))
				warpPedIntoVehicle(source, Vehicle_Leiteiro[source])
				CMR_Leiteiro_IniciarJob(source)
			else
				exports.cmr_dxmessages:outputDx(source, "Servi??o finalizado com sucesso!", "success")
				setElementData(source, "CMR:LeiteiroTrab", nil)
				setAccountData(acc, "CMR:LeiteiroTrab", nil)
				if isElement(Vehicle_Leiteiro[source]) then
					destroyElement(Vehicle_Leiteiro[source])
					Vehicle_Leiteiro[source] = nil
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
			triggerClientEvent(source, "CMR:Leiteiro:PainelDX", source)
		end
	end
end
addEvent("CMR:Leiteiro:IniciarFinalizar", true)
addEventHandler("CMR:Leiteiro:IniciarFinalizar", root, CMR_Leiteiro_IniciarFinalizar)