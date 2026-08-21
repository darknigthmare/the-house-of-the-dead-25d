# Reference Matrix

## Source hierarchy

1. Authorized Sega Model 2 arcade revision placed by the owner in `reference_build/`.
2. Sega's historical product page and operator material.
3. Contemporary arcade guides and route maps, cross-checked against complete arcade capture.
4. Later PC/Saturn documentation only to identify port differences.
5. The 2022 remake only as a secondary spatial reference.

No ROM, commercial sound, guide text or video frame is stored in this repository. Public video is observation-only; no asset was extracted.

| Ref | Purpose | Location | Status |
|---|---|---|---|
| SEGA-HISTORY | date, 1–2 players, action branches, head shots | https://www.sega.jp/history/arcade/product/9038/ | checked |
| SEGA-OPERATOR | lives/ammo HUD, off-screen reload, civilians, hidden items, boss gauge, continues | https://aurcade.com/games/manuals/00000489.pdf | checked |
| FAQ-ARCADE-556 | routes, score, life rewards, scene order | https://gamefaqs.gamespot.com/arcade/583587-the-house-of-the-dead/faqs/556 | checked; revision caveats retained |
| FAQ-END-557 | boss and ending observations | https://gamefaqs.gamespot.com/arcade/583587-the-house-of-the-dead/faqs/557 | checked |
| FAQ-PC-8334 | chapter-by-chapter comparison | https://gamefaqs.gamespot.com/pc/198966-the-house-of-the-dead/faqs/8334 | secondary |
| FAQ-SCORE-24187 | scene scoring and hidden items | https://gamefaqs.gamespot.com/pc/198966-the-house-of-the-dead/faqs/24187 | secondary/cross-check |
| AUTHORIZED-BUILD | exact camera samples, timings, spawn resistance and ending revision | `reference_build/` | absent; not claimed |

## Sequence observations

Positions are normalized technical staging values, not copied coordinates. `camera` gives the intended composition in this adaptation. Exact timestamps remain `TBD-AUTH` until the authorized build is supplied.

| Scene ID | Chapter / route | Camera and control | Gameplay observation | Branch / next | Audio/dialogue |
|---|---|---|---|---|---|
| C1-GARDEN-01 | Tragedy / garden | low arrival push, control after reveal | two walkers, flying threat, scientist under attack | save → main entrance; fail → under bridge | arrival/SOS timing approximate |
| C1-UNDER-02 | Tragedy / fail | low tunnel sweep | small fast creatures and walkers | converges at foyer | replacement ambience |
| C1-FOYER-03 | Tragedy / shared | centered hall, lateral look | opposing enemies and destructible lock/floor consequence | upper stairs vs ground hall | guide-derived condition, exact frame TBD |
| C1-SOPHIE-04 | Tragedy / converge | stop on Sophie, attack reveal | Sophie event followed by guardian approach | Chariot | licensed voice absent |
| C1-BOSS-05 | Tragedy | fixed combat composition | armor opening; armor breaks; exposed body | chapter complete | original boss music absent |
| C2-HATCH-01 | Revenge / start | forward corridor stop | chained hatch target plus wave | shot → underground; ignored → great doors | exact timeout TBD |
| C2-LIBRARY-02 | Revenge / converge | shelving occlusion, rescue focus | scientist rescue and mixed creatures | high bridge vs lower stairs | replacement SFX |
| C2-ROOF-03 | Revenge / converge | rising look to sky | bat formation | Hangedman | rooftop transition observed |
| C2-BOSS-04 | Revenge | broad aerial frame | bats first, flight, rapid charges, fall | chapter complete | phase thresholds revision TBD |
| C3-ELEVATOR-01 | Truth / start | symmetric elevators | switch and laboratory wave | left vs right elevator | exact selected side checked from guide |
| C3-RESCUE-02 | Truth / converge | rear attack reveal | scientist attacked from behind | saved opens door; fail → conduit/key | save window TBD-AUTH |
| C3-DOORS-03 | Truth / alternatives | bridge/high or conduit/low | technical-area variants | converge at Curien tunnel | port differences isolated |
| C3-BOSS-04 | Truth | narrow tunnel | head exposure, charges, destructible web | chapter complete | Hermit timings TBD-AUTH |
| C4-REMATCH-01 | Final | laboratory combat stops | Chariot then shorter Hangedman | bonus gate | health scaling provisional |
| C4-BONUS-02 | Final / conditional | supply-room detour | cache/hidden pickup | all prior scientists saved only | civilian total revision conflict |
| C4-CURIEN-03 | Final | narrative stop | Curien commands Magician; creation kills Curien | Magician | original voices absent |
| C4-BOSS-04 | Final | multi-position arena | exposed tissue, rapid movement, destructible fireballs, aerial finale | ending resolver | exact phase timing TBD-AUTH |
| C4-END-05 | Final | mansion exit | score/units-based ending selection | credits | original music absent |

## Known uncertainties

- Sega dates commercial operation to March 1997 while some material carries a 1996 copyright.
- Sources disagree on 15 versus 16 scientists; the runtime tracks entities rather than hard-coding a public claim.
- Arcade material supports 62,000 for the good ending; later PC material reports 60,000 and additional conditions. Arcade mode defaults to 62,000 and keeps the threshold configurable.
- A continue adds one score unit in contemporary observations, explaining units-digit ending reports. The resolver tests score units directly.
- The two-player source consulted does not prove whether the ending uses combined score, leading-player score or player-one score for every revision. This remains a reference-build checkpoint.
