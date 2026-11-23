# PSP Track Asset Inventory (from supplied CSO)

This inventory is based on direct inspection of the user-supplied PSP CSO image. It is not a reconstructed or playable map yet.

## Extraction verified
- Source: `Need for Speed - Most Wanted (RUS).cso`
- Decompressed ISO9660 image size: 884,588,544 bytes.
- Game directory: `PSP_GAME/USRDIR/tracks`
- Found 12 track archives: `l3ra_3001.viv` through `l3rl_3401.viv`.
- All 12 outer track files begin with the `BIGF` signature.
- The archive data contains additional embedded `BIGF` markers and readable resource-name strings.
- The resource strings include `X0.msh`, `textureusage_*`, road, bridge, tunnel, building and prop identifiers.
- The archive header visibly names a nested `X0.viv` resource package; within its data, a mesh resource name `X0.msh` is present.

## Verified archive observations

The following embedded BIGF marker offsets were found by byte scan (offsets are relative to the start of each outer VIV file). These are marker locations, not yet validated file-entry offsets.

| Archive | Size (bytes) | Embedded BIGF offsets |
|---|---:|---|
| `l3ra_3001.viv` | 2,732,740 | 0, 134, 193030 |
| `l3rb_3002.viv` | 2,842,263 | 0, 134, 382342 |
| `l3rc_3003.viv` | 3,092,981 | 0, 134, 417030 |
| `l3rd_3004.viv` | 3,125,879 | 0, 134, 224006 |
| `l3re_3005.viv` | 3,114,067 | 0, 134, 238342 |
| `l3rf_3006.viv` | 2,109,477 | 0, 134, 146694 |
| `l3rg_3007.viv` | 3,119,701 | 0, 134, 331142 |
| `l3rh_3008.viv` | 3,266,991 | 0, 134, 350982 |
| `l3ri_3009.viv` | 3,625,961 | 0, 134, 328838 |
| `l3rj_3010.viv` | 3,130,214 | 0, 134, 420998 |
| `l3rk_3011.viv` | 140,529 | 0, 134, 9734 |
| `l3rl_3401.viv` | 1,562,135 | 0, 134, 15622 |

## Examples of readable asset-name strings

The strings below are names/references found in the binary data, not proof that each asset is a complete independently extractable mesh.

- `l3ra_3001.viv`: `RoadBloc`, `X0.msh`, `ARC_D_Building_M`, `OBJ_police_barri`, `ARC_FactoryWindows06`
- `l3rb_3002.viv`: `Factory_`, `GNWTunnelEnt`, `SHD_Bridge`, `RoadBlockTwo`, `Bigfactory_Windo`
- `l3rc_3003.viv`: `ARC_Police_HQ_`, `WALL_ROADBarrier_Rai`, `RDS_Road`, `Bridgetype01`, `Police_S`
- `l3rd_3004.viv`: `Police_HQ_NoTowe`, `pBridgeShadowMa`, `RoadBlockTwo`, `Bridgetype01`, `PSP_bridge_g`
- `l3re_3005.viv`: `ARC_Factory_A_00.ord`, `RE_RoadA`, `G_Building_Q`, `mtn_road_exi`, `Tunnel2e`
- `l3rf_3006.viv`: `Bridgeend_4T`, `RoadBlockTwo`, `TRN_BridgeShadow`, `G_Bridgewall`
- `l3rg_3007.viv`: `BridgeGuard_CH`, `ARC_Bridgetype01`, `OverPBridge_B_PS`, `RoadnTerrain_CHO`
- `l3rh_3008.viv`: `Tunnel_rim`, `RoadBlockTwo`, `TwoLaneRoad`, `BridgewallA1`
- `l3ri_3009.viv`: `OPT_PoliceHQ`, `BLTunnelFans`, `RDP_Road`, `buildingstairs01`
- `l3rj_3010.viv`: `BLTunnel`, `RJ_TUNNELTOP`, `mtn_road_exi`, `factoryWindowCor`
- `l3rk_3011.viv`: `RK_Road01_CHOP`
- `l3rl_3401.viv`: `PoliceStat`, `PoliceStatio`, `FactoryWindows01`

## Reproducible extraction/inventory tool

`tools/inspect_psp_tracks.py` reads an ISO9660 image, extracts the 12 track VIV files, and writes a JSON inventory of embedded BIGF markers and readable asset-name strings:

```bash
python tools/inspect_psp_tracks.py "nfs_mw_psp_unpacked.iso" --out psp_track_extract
```

The script inventories resources only; it does not decrypt proprietary payloads or decode the mesh format.

## Limits and next technical step
- The embedded resource index and payload layout are not yet decoded. A byte scan for `BIGF` is only a lead, not a valid parser.
- No original mesh, texture, collision, or route-coordinate data has been imported into Godot.
- This is the PSP release (Most Wanted 5-1-0), not the full PC/PS2 Rockport open world. Its route content must not be presented as the entire Rockport map.
- Next: reverse-engineer the resource table and `X0.msh` layout using validated offsets, then export a small mesh sample to glTF and test it in Godot before attempting full route reconstruction.
