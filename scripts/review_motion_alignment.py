#!/usr/bin/env python3
"""Diagnostic projections of native PNGs using runtime pivots; not engine captures."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/"docs/dossier_curien/saga/production/motion_2026-11-19/qa_projection"
OUT.mkdir(parents=True,exist_ok=True)
manifest=json.loads((ROOT/"data/assets/dossier_curien_motion.json").read_text())
assets={entry["id"]:entry for entry in manifest["assets"]}
heights={"linda":261,"rogan":280,"zobio":300,"zobiko":252,"stick":282,"rikiya":284}
font=ImageFont.truetype("DejaVuSans.ttf",17)
titlefont=ImageFont.truetype("DejaVuSans.ttf",20)

def original(fighter):
    path=(f"assets/dossier_curien/expansion/zombie_revenge_characters/linda_rotta_base.png" if fighter=="linda"
          else f"assets/dossier_curien/rogan_guard.png" if fighter=="rogan"
          else f"assets/dossier_curien/saga/{fighter}_guard.png")
    im=Image.open(ROOT/path).convert("RGBA")
    bounds=im.getchannel("A").point(lambda a:255 if a>=128 else 0).getbbox()
    return {"id":fighter+"_guard","fighter_id":fighter,"path":path,
            "pivot_px":[(bounds[0]+bounds[2])/2,bounds[3]],"standing_height_px":bounds[3]-bounds[1]}

groups={
"linda":[original("linda")]+[assets["linda_"+p] for p in ["block","jump_rise","jump_fall","reload","throw","taunt","victory","finish"]],
"rogan":[original("rogan"),assets["rogan_crouch"],assets["rogan_jump_rise"]],
"zobio":[assets["zobio_"+p] for p in ["guard","walk1","walk2","windup","contact","recovery","recoil"]],
"zobiko":[assets["zobiko_"+p] for p in ["guard","walk1","walk2","windup","contact","recovery","recoil"]],
"zombie_revenge":[]
}
groups.pop("zombie_revenge",None)
groups["zombie_revenge"]=[]
for f in ["stick","rikiya"]:
    groups["zombie_revenge"].extend([original(f)]+[assets[f+"_"+p] for p in ["walk1","walk2","recovery"]])
for name,entries in groups.items():
    cols=3 if name in ["linda","rogan"] else 4
    cw,ch=380,430
    canvas=Image.new("RGB",(cols*cw,70+((len(entries)+cols-1)//cols)*ch),(225,231,235))
    draw=ImageDraw.Draw(canvas)
    draw.text((15,12),"Projection des PNG et pivots — hors moteur",font=titlefont,fill=(20,30,40))
    draw.text((15,42),"Pixels sources inchangés · taille du profil · sans mouvement, éclairage ni VFX du jeu",font=font,fill=(60,70,80))
    for index,entry in enumerate(entries):
        x=(index%cols)*cw;y=70+(index//cols)*ch
        origin=(x+145,y+365)
        h=heights[entry["fighter_id"]]
        draw.line((x+6,origin[1],x+cw-6,origin[1]),fill=(100,125,150),width=2)
        draw.line((origin[0],y+40,origin[0],origin[1]+8),fill=(170,185,195),width=1)
        source=Image.open(ROOT/entry["path"]).convert("RGBA")
        scale=h/entry["standing_height_px"]
        rendered=source.resize((round(source.width*scale),round(source.height*scale)),Image.Resampling.LANCZOS)
        pivot=entry["pivot_px"]
        left=round(origin[0]-pivot[0]*scale);top=round(origin[1]-pivot[1]*scale)
        canvas.paste(rendered,(left,top),rendered)
        draw.ellipse((origin[0]-3,origin[1]-3,origin[0]+3,origin[1]+3),fill=(25,80,150))
        if entry.get("emitter_px"):
            p=entry["emitter_px"];ex=origin[0]+(p[0]-pivot[0])*scale;ey=origin[1]+(p[1]-pivot[1])*scale
            draw.ellipse((ex-4,ey-4,ex+4,ey+4),outline=(200,40,20),width=2)
        draw.text((x+12,y+388),entry["id"],font=font,fill=(25,35,45))
    canvas.save(OUT/(name+".jpg"),quality=92)
print("Created diagnostic projections for "+", ".join(groups))
