# PSP Track Asset Inventory (from supplied CSO)

This is a preliminary, source-derived inventory of the PSP release's track packages. It is not a reconstructed or playable map yet.

## Extraction
- Source: user-supplied `Need for Speed - Most Wanted (RUS).cso`
- Disc image: CSO v1, decompressed ISO size 884,588,544 bytes.
- Game directory: `PSP_GAME/USRDIR/tracks`
- Track packages found: 12 VIV archives.
- Each major package contains a route-specific VIV plus an `X0.viv` resource package.
- The X0 packages contain readable asset-name strings such as `X0.msh`, `textureusage_*`, road, bridge, tunnel, building, and prop names. The inner package header is not yet decoded, so mesh and texture payloads have not been converted.

## Packages and visible environment identifiers

| Package | Identifiers observed in its resource strings |
|---|---|
| `l3ra_3001.viv` | city power, grocery, fast food, oil tanks, nuclear plant, forest, high-rise, warehouse, parking, residences, power lines |
| `l3rb_3002.viv` | factory, city limits, tunnel entrance, oil tanks, bridge, road blocks, warehouse, industrial assets |
| `l3rc_3003.viv` | police HQ, stadium, nuclear crates, road barriers, bridge, high-rise, parking, strip mall, garage |
| `l3rd_3004.viv` | police HQ, dockside, warehouse, ship, bridge, parking, factory, mall, city limits |
| `l3re_3005.viv` | factory, grocery, warehouse, mall, parking, residence, mountain-road exit, stadium, tunnel |
| `l3rf_3006.viv` | bridge end, rail, mall, high-rise, residence, warehouse, road barriers, bridge wall |
| `l3rg_3007.viv` | bridge guard, parking, high-rise, city hall, stadium, warehouse, residence, road terrain |
| `l3rh_3008.viv` | rail, power plant, tunnel, nuclear crates, road barriers, warehouse, residence, bridge |
| `l3ri_3009.viv` | factory, police HQ, grocery, tunnel fans, oil tanks, warehouse, parking, road barriers |
| `l3rj_3010.viv` | factory, grocery, parking, tunnel, warehouse, power lines, residence, cityscape |
| `l3rk_3011.viv` | road chunk and cityscape identifiers |
| `l3rl_3401.viv` | electric plant, garage, oil barrels, police station, city hall, ship warehouse, nuclear plant |

## Important limits
- The identifiers above are extracted strings, not proof that every named object is present as a complete mesh in a given route.
- The route packages' inner resource index uses a game-specific obfuscated/encrypted header. The visible `BIGF` marker and strings alone are insufficient to safely parse mesh offsets.
- No original mesh, texture, collision, or route-coordinate data has been imported into Godot yet.
- This is the PSP release (Most Wanted 5-1-0), not the full PC/PS2 Rockport game. Its route content should not be represented as the entire Rockport open world.

## Next technical step
Decode the inner VIV resource index and the `X0.msh` format, then export one small route section to a neutral interchange format (e.g. glTF) for validation in Godot before attempting all packages.
