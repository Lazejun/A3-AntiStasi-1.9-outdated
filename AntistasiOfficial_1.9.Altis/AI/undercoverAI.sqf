private ["_unit","_behaviour","_primaryWeapon","_secondaryWeapon","_handGunWeapon","_helmet","_hmd","_list","_primaryWeaponItems","_secondaryWeaponItems","_handgunItems"];

_unit = _this select 0;
_unit setCaptive true;

_unit disableAI "TARGET";
_unit disableAI "AUTOTARGET";
_unit setUnitPos "UP";
_behaviour = behaviour _unit;
_unit setBehaviour "CARELESS";
_primaryWeapon = primaryWeapon _unit call BIS_fnc_baseWeapon;
_primaryWeaponItems = primaryWeaponItems _unit;
_unit removeWeaponGlobal _primaryWeapon;
_secondaryWeapon = secondaryWeapon _unit;
_secondaryWeaponItems = secondaryWeaponItems _unit;
_unit removeWeaponGlobal _secondaryWeapon;
_handGunWeapon = handGunWeapon _unit call BIS_fnc_baseWeapon;
_handgunItems = handgunItems _unit;
_unit removeWeaponGlobal _handGunWeapon;
_helmet = headgear _unit;
removeHeadGear _unit;
_hmd = hmd _unit;
_unit unlinkItem _hmd;

_unit addEventHandler ["FIRED",
	{
	_unit = _this select 0;
	if (captive _unit) then
		{
		if ({((side _x== side_red) or (side _x== side_green)) and ((_x knowsAbout _unit > 1.4) || (_x distance _unit < 200))} count allUnits > 0) then
			{
			_unit setCaptive false;
			if (vehicle _unit != _unit) then {
				{if (isPlayer _x) then {[_x,false] remoteExec ["setCaptive",_x]}} forEach ((assignedCargo (vehicle _unit)) + (crew (vehicle _unit)));
			};
			}
		else
			{
			_cityX = [citiesX,_unit] call BIS_fnc_nearestPosition;
			_size = [_cityX] call sizeMarker;
			_dataX = server getVariable _cityX;
			if (random 100 < _dataX select 2) then
				{
				if (_unit distance getMarkerPos _cityX < _size * 1.5) then
					{
					_unit setCaptive false;
					};
				};
			};
		}
	}
	];

_bases = bases + outposts + controlsX;
while {(captive player) and (captive _unit)} do
	{
	sleep 1;
	if ((vehicle _unit != _unit) and (not((typeOf vehicle _unit) in CIV_vehicles) || vehicle _unit in reportedVehs)) exitWith {};
	_base = [_bases,player] call BIS_fnc_nearestPosition;
	_size = [_base] call sizeMarker;
	if ((_unit distance getMarkerPos _base < _size*2) and (_base in mrkAAF)) exitWith {_unit setCaptive false};
	if ((primaryWeapon _unit != "") or (secondaryWeapon _unit != "") or (handgunWeapon _unit != "")) exitWith {};
	};

_unit removeAllEventHandlers "FIRED";
if (!captive _unit) then {_unit groupChat "Shit, they have spotted me!"} else {_unit setCaptive false};
if (captive player) then {sleep 5};


_unit enableAI "TARGET";
_unit enableAI "AUTOTARGET";
_unit setUnitPos "AUTO";
_unit setBehaviour (behaviour leader _unit);
_withoutBackpck = false;
if ((backpack _unit == "") and (_secondaryWeapon == "")) then
	{
	_withoutBackpck = true;
	_unit addbackpack "B_AssaultPack_blk";
	};
{if (_x != "") then {[_unit, _x, 1, 0] call BIS_fnc_addWeapon};} forEach [_primaryWeapon,_secondaryWeapon,_handGunWeapon];
{_unit addPrimaryWeaponItem _x} forEach _primaryWeaponItems;
{_unit addSecondaryWeaponItem _x} forEach _secondaryWeaponItems;
{_unit addHandgunItem _x} forEach _handgunItems;
if (_withoutBackpck) then {removeBackpack _unit};
_unit addHeadgear _helmet;
_unit linkItem _hmd;
_unit setBehaviour "AWARE";
