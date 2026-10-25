local AC = {}

local ACRegistry = {}
local TrackCache = setmetatable({}, { __mode = "k" })

local ContentProvider = game:GetService("ContentProvider")

local function NormalizeId(Id)
	if typeof(Id) == "number" then
		return "rbxassetid://" .. Id
	end
	return Id
end

local function GetHumanoid(Player: Player)
	local Character = Player.Character or Player.CharacterAdded:Wait()
	return Character:WaitForChild("Humanoid") :: Humanoid
end

local function GetAnimator(Player: Player)
	local Humanoid = GetHumanoid(Player)
	local Animator = Humanoid:FindFirstChildOfClass("Animator")
	if not Animator then
		Animator = Instance.new("Animator")
		Animator.Parent = Humanoid
	end
	return Animator :: Animator
end

local function GetEntry(Name: string)
	local Entry = ACRegistry[Name]
	if not Entry then
		warn(
			"[AnimationController] No animation registered with the name '"
				.. tostring(Name)
				.. "'. Did you forget to call AC:Register?"
		)
	end
	return Entry
end

local function GetTrack(Player: Player, Name: string)
	local Entry = GetEntry(Name)
	if not Entry then
		return nil
	end

	local Animator = GetAnimator(Player)
	local Tracks = TrackCache[Animator]
	if not Tracks then
		Tracks = {}
		TrackCache[Animator] = Tracks
	end

	local Track = Tracks[Name]
	if not Track then
		local Animation = Instance.new("Animation")
		Animation.AnimationId = Entry.AnimationId
		Track = Animator:LoadAnimation(Animation)
		Tracks[Name] = Track
	end
	return Track
end

function AC:Register(Name: string, AnimationId)
	ACRegistry[Name] = { AnimationId = NormalizeId(AnimationId) }
end

function AC:RegisterM(tbl)
	for Name, Data in pairs(tbl) do
		if type(Data) == "table" then
			local Entry = table.clone(Data)
			Entry.AnimationId = NormalizeId(Data.AnimationId)
			ACRegistry[Name] = Entry
		else
			ACRegistry[Name] = { AnimationId = NormalizeId(Data) }
		end
	end
end

function AC:PreloadAnims()
	local Items = {}
	for _, Entry in pairs(ACRegistry) do
		local Animation = Instance.new("Animation")
		Animation.AnimationId = Entry.AnimationId
		table.insert(Items, Animation)
	end
	ContentProvider:PreloadAsync(Items)
	for _, Animation in ipairs(Items) do
		Animation:Destroy()
	end
end

function AC:Play(Player: Player, Name: string)
	local Track = GetTrack(Player, Name)
	if Track then
		Track:Play()
	end
	return Track
end

function AC:Stop(Player: Player, Name: string)
	local Track = GetTrack(Player, Name)
	if Track then
		Track:Stop(0)
	end
end

function AC:StopAll(Player: Player)
	local Animator = GetAnimator(Player)
	for _, Track in ipairs(Animator:GetPlayingAnimationTracks()) do
		Track:Stop(0)
	end
end

function AC:IsPlaying(Player: Player, Name: string)
	local Track = GetTrack(Player, Name)
	return Track ~= nil and Track.IsPlaying
end

function AC:SetSpeed(Player: Player, Name: string, Speed: number)
	local Track = GetTrack(Player, Name)
	if Track then
		Track:AdjustSpeed(Speed)
	end
end

return AC
