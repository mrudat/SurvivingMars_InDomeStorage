return PlaceObj('ModDef', {
	'title', "In dome storage",
	'description', 'Creates "Inside" variants of storage buildings, that can be placed inside a dome.\n\nCopies any buildings that store Air, Water or Power, as well as Depots and Mechanized Depots.\n\nCan be built from prefabs of the original buildings.\n\nPermission is granted to update this mod to support the latest version of the game if I\'m not around to do it myself.',
	'image', "Water Tanks.jpg",
	'last_changes', "reduced log spam",
	'dependencies', {
		PlaceObj('ModDependency', {
			'id', "ChoGGi_Library",
			'title', "ChoGGi's Library",
			'version_major', 7,
			'version_minor', 1,
		}),
	},
	'id', "t58JMG4",
	'steam_id', "1807829185",
	'pops_desktop_uuid', "c0e2d5f4-a1d1-488c-a894-a225361a75cf",
	'pops_any_uuid', "8aa03957-433c-4a2d-8c5c-c4f3369aa35c",
	'author', "mrudat",
	'version_minor', 1,
	'version', 26,
	'lua_revision', 233360,
	'saved_with_revision', 245618,
	'code', {
		"Code/Script.lua",
	},
	'saved', 1565003645,
})