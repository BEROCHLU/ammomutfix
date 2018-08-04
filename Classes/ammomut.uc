class AmmoMut extends KFMutator
	config(AmmoMut);
	
var config float AmmoMultiplier, RefillTime;
var config bool bConfigsInit;
var array<KFWeapon> RefillWeapons;
var array<KFWeapon> InitWeapons;
var int cnt;

function PreBeginPlay()
{
	super.PreBeginPlay();
	
	if( !bConfigsInit )
	{
		RefillTime = 32.f;
		AmmoMultiplier = 2.f;
		bConfigsInit = true;
		SaveConfig();
	}
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if( WorldInfo.Game.BaseMutator==None ) WorldInfo.Game.BaseMutator = Self;
	else WorldInfo.Game.BaseMutator.AddMutator(Self);

	if( bDeleteMe ) return;// This was a duplicate instance of the mutator.

	SetTimer(RefillTime, true, 'FillWeapons');
}

function FillWeapons()
{
	local int i;

	for(i=0; i<RefillWeapons.Length; i++)
	{
		if(RefillWeapons[i]==None)
		{
			RefillWeapons.Remove(i--,1);
		}
		else
		{
			RefillWeapons[i].SpareAmmoCount[0] = RefillWeapons[i].SpareAmmoCapacity[0] - RefillWeapons[i].AmmoCount[0];//MaxSpareAmmo
			RefillWeapons[i].SpareAmmoCount[1] = RefillWeapons[i].SpareAmmoCapacity[1] - RefillWeapons[i].AmmoCount[1];//MaxSpareAmmo
		}
	}
	
	FillNade();
	//DebugMessage("FillWeapons:", ++cnt);
}

function AddMutator(Mutator M)
{
	if( M!=Self ) // Make sure we don't get added twice.
	{
		if( M.Class==Class ) M.Destroy();
		else super.AddMutator(M);
	}
}

function bool CheckReplacement(Actor Other)
{
	local KFWeapon KFW;
	
	KFW = KFWeapon(Other);
	
	if(KFW != None)
	{
		InitWeapons[InitWeapons.Length] = KFW;
		SetTimer(0.10,false,'SetupWeapon');
	}
	
	return true;
}

function SetupWeapon()
{
	While(InitWeapons.Length>0)
	{
		RefillWeapons[RefillWeapons.Length] = InitWeapons[0];
	
		InitWeapons[0].SpareAmmoCapacity[0] *= AmmoMultiplier;//MaxSpareAmmo
		InitWeapons[0].SpareAmmoCount[0] *= AmmoMultiplier;
		InitWeapons[0].InitialSpareMags[0] *= AmmoMultiplier;
		InitWeapons[0].AmmoPickupScale[0] *= AmmoMultiplier;
	
		InitWeapons[0].SpareAmmoCapacity[1] *= AmmoMultiplier;//MaxSpareAmmo
		InitWeapons[0].SpareAmmoCount[1] *= AmmoMultiplier;
		InitWeapons[0].InitialSpareMags[1] *= AmmoMultiplier;
		InitWeapons[0].AmmoPickupScale[1] *= AmmoMultiplier;
		
		InitWeapons.Remove(0,1);
	}
	
	FillNade();
}

function FillNade()
{
	local KFPawn KFP;
		
	foreach DynamicActors(class'KFPawn', KFP)
	{
		if( KFInventoryManager(KFP.InvManager) != none )
			KFInventoryManager(KFP.InvManager).GrenadeCount = 255;
	}
}

function DebugMessage(string strMsg, float fMsg)
{
	local PlayerController	PC;
	
	foreach WorldInfo.AllControllers(class'PlayerController', PC) PC.ClientMessage(strMsg$fMsg);
}

defaultproperties
{
	cnt=0
}
