
function ApplyFairPillage(iPlayer,refunit,pPlot,eImprovement,eBuilding,eDistrict)
	local pillageAwards;
	local pillageAmount;
	local pPlayer = Players[iPlayer]
	local iPlayerScore = pPlayer:GetScore()
	local iVictim = pPlot:GetOwner()
	local pVictim = Players[iVictim]
	local iVictimScore = pVictim:GetScore()
	
	if (iPlayerScore < iVictimScore) then
		-- fair game if player has less score than victim, city states always have 0 score
		return
	end

	if (pPlayer == nil) then
		return
	end
	
	if eImprovement ~= nil and eImprovement > -1 then
		pillageAwards = GameInfo.Improvements[eImprovement].PlunderType
		pillageAmount = GameInfo.Improvements[eImprovement].PlunderAmount
	end
	if eBuilding ~= nil and eBuilding > -1 then
		pillageAwards = GameInfo.Buildings[eBuilding].PlunderType
		pillageAmount = GameInfo.Buildings[eBuilding].PlunderAmount
	end
	if eDistrict ~= nil and eDistrict > -1 then
		pillageAwards = GameInfo.Districts[eDistrict].PlunderType
		pillageAmount = GameInfo.Districts[eDistrict].PlunderAmount
	end

	if (pillageAwards == "PLUNDER_HEAL") then
		-- no shame in plundering health
		return
	end
	
	local playerEra = pPlayer:GetEras();
	
	if playerEra == nil then 
		return; 
	end
	local eraNum = 0
	for era in GameInfo.Eras() do
		if(playerEra:GetEra() == era.Index) then
			eraNum = era.ChronologyIndex
		end
	end
	eraNum = eraNum - 1
	local eraBonus = math.floor(pillageAmount / 3) * tonumber(eraNum)	
	local playerTechs = pPlayer:GetTechs();		
	if playerTechs == nil then 
		return; 
	end
	local techNum = 0
	for tech in GameInfo.Technologies() do
		if(playerTechs:HasTech(tech.Index)) then
			techNum = techNum + 1
		end
	end
	
	local playerCulture = pPlayer:GetCulture();
	if playerCulture == nil then 
		return; 
	end
	local civicNum = 0
	for civic in GameInfo.Civics() do
		if(playerCulture:HasCivic(civic.Index)) then
			civicNum = civicNum + 1
		end
	end
	local researchBonus = math.max(techNum,civicNum,0)
	researchBonus = researchBonus * (math.floor(pillageAmount/10))
	
	local iSpeedCostMultiplier = GameInfo.GameSpeeds[GameConfiguration.GetGameSpeedType()].CostMultiplier
	if iSpeedCostMultiplier ~= nil and iSpeedCostMultiplier > -1 then
		pillageAmount = math.floor( (pillageAmount + researchBonus + eraBonus) * iSpeedCostMultiplier /100)
	else
		return
	end
	pillageAmount = -1 * pillageAmount

	local message:string  = "Shame "..tostring(pillageAmount)
	if pillageAwards == "PLUNDER_CULTURE" then
		pPlayer:GetCulture():ChangeCurrentCulturalProgress(pillageAmount)
		message = message.."[ICON_Culture]"
	elseif pillageAwards == "PLUNDER_SCIENCE" then
		pPlayer:GetTechs():ChangeCurrentResearchProgress(pillageAmount)
		message = message.."[ICON_Science]"
	elseif pillageAwards == "PLUNDER_FAITH" then
		pPlayer:GetReligion():ChangeFaithBalance(pillageAmount)		
		message = message.."[ICON_Faith]"
	elseif pillageAwards == "PLUNDER_GOLD" then
		pPlayer:GetTreasury():ChangeGoldBalance(pillageAmount)		
		message = message.."[ICON_Gold]"	
	end

	Game.AddWorldViewText(0, message, pPlot:GetX(), pPlot:GetY())
end

function OnPillageCompensation(iUnitPlayerID :number, iUnitID :number, eImprovement :number, eBuilding :number, eDistrict :number, iPlotIndex :number)
	if(iUnitPlayerID == NO_PLAYER) then
 		return;
	end

	local pUnitPlayer :object = Players[iUnitPlayerID];
	if(pUnitPlayer == nil) then
		return;
	end

	local pUnit :object = UnitManager.GetUnit(iUnitPlayerID, iUnitID);
	if (pUnit == nil) then
		return;
	end
    	local pPlot = Map.GetPlotByIndex(iPlotIndex)
    	ApplyFairPillage(iUnitPlayerID,iUnitID,pPlot,eImprovement,eBuilding,eDistrict)
end

GameEvents.OnPillage.Add(OnPillageCompensation)