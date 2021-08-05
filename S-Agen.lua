------------------------------------------
--- 		CAMARGO SCRIPTS  		   ---
	 -----	 AGENCIA BRP		-----
------------------------------------------

local markerCreateAgencia = {}


function CMR_AgenciaConnect(res)
	if res == getThisResource() then
		DbConnect = dbConnect('sqlite', 'sqlite.db')
		if (not DbConnect) then
			outputDebugString("ERROR: Não foi possivel conectar ao banco de dados da Agência!")
		else
			outputDebugString("SUCCESS: Banco de Dados da Agência conectado com sucesso!")
		end
	end
end
addEventHandler("onResourceStart", root, CMR_AgenciaConnect)

function CMR_AgenciaCarregarMarkers(res)
	if res == getThisResource() then
		for i, marker in ipairs(MarkerAgencia) do
			markerCreateAgencia[i] = createMarker(marker[1], marker[2], marker[3]-1, "cylinder", 1.5, 0, 0, 255, 180)
			createBlipAttachedTo(markerCreateAgencia[i], marker[4])
		end
	end
end
addEventHandler("onResourceStart", root, CMR_AgenciaCarregarMarkers)

function CMR_AgenciaMarkerHit(marker)
	if marker then
		for i, markerV in ipairs(markerCreateAgencia) do
			if marker == markerCreateAgencia[i] then
				if source then
					local account = getPlayerAccount(source)
					if not isGuestAccount(account) then
						triggerClientEvent(source, "CMR:AgenciaAbrirPainel", source)
					else
						exports.cmr_dxmessages:outputDx(source, "Você precisa estar logado para usar a âgencia!", "error")
					end
				end
			end
		end
	end
end
addEventHandler("onPlayerMarkerHit", root, CMR_AgenciaMarkerHit)

function CMR_AgenciaCarregarEmpregos()
	ReturnList = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE Ativo='Sim'"), -1)
	triggerClientEvent(source, "CMR:AgenciaListCarregarEmpregos", source, ReturnList)
end
addEvent("CMR:AgenciaCarregarEmpregos", true)
addEventHandler("CMR:AgenciaCarregarEmpregos", root, CMR_AgenciaCarregarEmpregos)

function CMR_AgenciaSeDemitir()
	if source then
		local account = getPlayerAccount(source) 
		if getElementData(source, "Emprego") or getAccountData(account, "Emprego") then
			setElementData(source, "Emprego", nil)
			setAccountData(account, "Emprego", nil)
			exports.cmr_dxmessages:outputDx(source, "Você se demitiu com sucesso!", "success")
		else
			exports.cmr_dxmessages:outputDx(source, "Você não está trabalhando para se demitir!", "error")
		end
	end
end
addEvent("CMR:AgenciaSeDemitir", true)
addEventHandler("CMR:AgenciaSeDemitir", root, CMR_AgenciaSeDemitir)


function CMR_AgenciaTrabalhar(idItem)
	if idItem then
		local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE Ativo='Sim'"), -1)
		for i, job in ipairs(ListItems) do
			if i == idItem then
				local LevelPlayer = getElementData(source, "Level") or 0
				if not tonumber(LevelPlayer) then
					LevelPlayer = 0
				end
				if tonumber(LevelPlayer) >= tonumber(job["Level"]) then
					local account = getPlayerAccount(source) 
					if getElementData(source, "Emprego") or getAccountData(account, "Emprego") then
						exports.cmr_dxmessages:outputDx(source, "Você precisa de demitir do antigo emprego!", "error")
					else
						setElementData(source, "Emprego", job["NomeEmprego"])
						setAccountData(account, "Emprego", job["NomeEmprego"])
						exports.cmr_dxmessages:outputDx(source, "Você se inscrevel no trabalho com sucesso! Para mais informações mentalize /infos", "success")
					end
				else
					exports.cmr_dxmessages:outputDx(source, "Você não tem level o suficiente para esse emprego!", "error")
				end
			end
		end
	end
end
addEvent("CMR:AgenciaTrabalhar", true)
addEventHandler("CMR:AgenciaTrabalhar", root, CMR_AgenciaTrabalhar)

function CMR_AgenciaInfos(source)
	if source then
		local account = getPlayerAccount(source)
		local Blip
		if not isGuestAccount(account) then
			if getElementData(source, "Emprego") or getAccountData(account, "Emprego") then
				local ListItems = dbPoll(dbQuery(DbConnect, "SELECT * FROM cmr_trabalhos WHERE Ativo='Sim'"), -1)
				local Emprego = getElementData(source, "Emprego") or getAccountData(account, "Emprego") or nil
				for i, job in ipairs(ListItems) do
					if job["NomeEmprego"] == Emprego then
						infBlip = EmpregosInformacao[Emprego]["posBlip"]
						Blip = createBlip(infBlip[1], infBlip[2], infBlip[3], 41, 2, 255, 0, 0, 255, 0, 16383.0, source)
						setTimer(destroyElement, 60000, 1, Blip)
						exports.cmr_dxmessages:outputDx(source, "O local do seu trabalho foi marcado no mapa!", "success")
					end
				end
			else
				exports.cmr_dxmessages:outputDx(source, "Você não está trabalhando para usar esse comando!", "error")
			end
		else
			exports.cmr_dxmessages:outputDx(source, "Você precisa está logado para usar esse comando!", "error")
		end
	end
end
addCommandHandler("infos", CMR_AgenciaInfos)
