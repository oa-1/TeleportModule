local module = {}
module.Places = {
	["OverTheHorizon"] = 5969164844,
	["GrownUpStorage"] = 5985386405,
	["UnresolvedNightsTrauma"] = 6007173861,
	["FaithInTheFuture"] = 6006565858,
	["UnavoidableConfusion"] = 6002063554,
	["FamousAttraction"] = 5999216607,
	["VisitToAFriend"] = 5998030569,
	["Unauthorized"] = 5921279634,
	["Farfromhome"] = 5901266978,
	["Whiteplain"] = 5894665612,
	["StormDrain"] = 5882451602,
	["Maze"] = 5880348316,
	["Party"] = 6196119811,
	["Main"] = 5350077243,
	["Root"] = 6155279398,
	["BlissfulSky"] = 5880130168,
	["Bliss"] = 6283790744,
	["Club"] = 6228936732,
	["SinnerHalls"] = 6207052017,
	["Lot"] = 6351702245,
	["BackArea"] = 6395192535,
	["Supermarket"] = 6153436818 
} 
module.Images =  {
	["Happy"] = 6052869616,
	["Trauma"] = 6052870356,
	["EyesWatching"] = 6258447084,
	["Fear"] = 6187635087
}
module.Doors = script.Doors

local StoredKeys = {}

local DataStore = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")

function module.UpdateKeys(Player)
	local _Success,_Error
	local Attempt = 0
	repeat
		_Success,_Error = pcall(function()
			local Scope = "_"..Player.UserId
			local KeyStore = DataStore:GetDataStore("Keys",Scope)
			StoredKeys[Player] = KeyStore:GetAsync("Keys")
		end)
		Attempt = Attempt+1
		print(Attempt)
	until _Success or Attempt > 4
	if not _Success then warn("Could not load data for user "..Player.Name.."!\nReason: ".._Error) end
	if not StoredKeys[Player] then
		StoredKeys[Player] = {}
	end
end

function module.TeleportPlayer(Player, Place, TeleportPad, Image, Keys)
	--LOADSA SPAGHETTi
	if Keys then
		local Keystore = StoredKeys[Player]
		for i,v in pairs(Keys) do
			local function TryKey()
				local Attempt = Keystore[v]
				print("Tried key "..v.." with result ")
				print(Attempt)
				if not Attempt then
					error("Do not have key "..v)
				end
			end
			local Success,Arguments = pcall(TryKey)
			if not Success then
				print(Arguments)
				return
			end
		end
	end
	PlaceId = Place

	if Place == game.PlaceId then 
		error("Can not teleport to the same place!")
	else

		local TeleportGui = script.TeleportGui:Clone()
		-- Gui Base
		TeleportGui.Frame.ImageLabel.Image = Image and ("rbxassetid://" .. tostring(Image)) or "rbxassetid://6052869616"
		TeleportGui.Frame.Header.Text = ""
		TeleportGui.Frame.Footer.Text = ""
		-- TeleportGui
		TeleportGui.Parent = Player.PlayerGui
		wait(1)
		TeleportGui.Client.Teleporting.Value = true
		local TeleportService =  game:GetService("TeleportService")
		-- Actual Teleport
		local TeleportTries = 0
		local MaxAttempts = 10
		local function AttemptTeleport()
			if TeleportTries > MaxAttempts then
				TeleportGui:Destroy()
				return
			else
				if RunService:IsStudio() then
					warn("In studio, cannot teleport! Teleport would have succeeded to place id ",PlaceId)
					TeleportGui:Destroy()
					return
				else
					TeleportService:Teleport(PlaceId,Player,{TeleportPad = TeleportPad})
				end
			end
		end

		while TeleportTries <= MaxAttempts do
			TeleportTries += 1
			wait(TeleportTries)
			local Success, Arguments = pcall(AttemptTeleport)
			if Success then
				break
			end
		end
	end
	print("Success")
end

function module.CreateDoor(Door, Place, TelepadName, Image, Keys)
	local debounce = false
	Door.Touched:Connect(function(TouchedPart)
		if debounce then return end --Preventing spam requests
		debounce = true
		delay(1,function() debounce = false end) --In 1 second a new teleport request can be made

		local Humanoid = TouchedPart.Parent:FindFirstChild("Humanoid")
		if Humanoid then --Is a Character (NPC or Player)
			local Player = game.Players:GetPlayerFromCharacter(TouchedPart.Parent)
			if Player then --It is an actual player that touched the part
				module.TeleportPlayer(Player, Place, TelepadName, Image, Keys)
			end
		end
	end)
end



--module.CreateDoor(Doors.Door, Places.Unauthorized, "RootSpawn", Images.Trauma,{"TestKey1","TestKey2"})

--game:GetService("TeleportService"):Teleport(6599584893,game.Players.Teapot_Eater)
--game:GetService("DataStoreService"):GetDataStore("Keys","_9986970"):SetAsync("Keys",{["TestKey1"] = true,["TestKey2"] = true})

game.Players.PlayerAdded:Connect(module.UpdateKeys)

game.Players.PlayerRemoving:Connect(function(Player)
	StoredKeys[Player] = nil
end)

return module

