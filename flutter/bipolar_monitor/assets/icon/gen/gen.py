import sys, os, subprocess
out = sys.argv[1]  # icon asset dir
os.makedirs(out, exist_ok=True)
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

DEFS = '''<defs>
  <radialGradient id="bg" cx="50%" cy="42%" r="70%">
    <stop offset="0" stop-color="#252a3a"/><stop offset="1" stop-color="#0F1117"/>
  </radialGradient>
  <linearGradient id="ring" x1="30" y1="28" x2="78" y2="80" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#7EB8A4"/><stop offset="0.5" stop-color="#A9B49A"/><stop offset="1" stop-color="#E8A87C"/>
  </linearGradient>
  <linearGradient id="wave" x1="36" y1="0" x2="72" y2="0" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#9FD3C0"/><stop offset="1" stop-color="#F2C3A0"/>
  </linearGradient>
  <radialGradient id="glow" cx="54" cy="54" r="24" gradientUnits="userSpaceOnUse">
    <stop offset="0" stop-color="#7EB8A4" stop-opacity="0.16"/><stop offset="1" stop-color="#7EB8A4" stop-opacity="0"/>
  </radialGradient>
</defs>'''
WAVE = "M39 54 C44 46.2 49 46.2 54 54 S64 61.8 69 54"
def fg(mono=False):
    if mono:
        return (f'<circle cx="54" cy="54" r="25" fill="none" stroke="#fff" stroke-width="5"/>'
                f'<path d="{WAVE}" fill="none" stroke="#fff" stroke-width="4.2" stroke-linecap="round"/>')
    return ('<circle cx="54" cy="54" r="22" fill="url(#glow)"/>'
            '<circle cx="54" cy="54" r="25" fill="none" stroke="url(#ring)" stroke-width="5"/>'
            f'<path d="{WAVE}" fill="none" stroke="url(#wave)" stroke-width="4.2" stroke-linecap="round"/>')
BG = '<rect width="108" height="108" fill="url(#bg)"/>'
def svg(body, vb="0 0 108 108"):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}" width="1024" height="1024">{DEFS}{body}</svg>'

files = {
  # full square icon (iOS / legacy / web): crop the 108 canvas to 76 so the motif is larger
  "icon.svg": svg(BG + fg(), "18 18 72 72").replace('<rect width="108" height="108"', '<rect x="0" y="0" width="108" height="108"'),
  "icon_foreground.svg": svg(fg()),
  "icon_background.svg": svg(BG),
  "icon_monochrome.svg": svg(fg(True)),
}
for name, s in files.items():
    p = os.path.join(out, name); open(p, "w").write(s + "\n")
    html = os.path.join(os.path.dirname(os.path.abspath(__file__)), name + ".html")
    open(html, "w").write(f'<!doctype html><html><body style="margin:0;background:transparent">{s}</body></html>')
    png = os.path.join(out, name.replace(".svg", ".png"))
    subprocess.run([CHROME, "--headless=new", f"--screenshot={png}", "--window-size=1024,1024",
                    "--hide-scrollbars", "--default-background-color=00000000", "file://" + html],
                   check=True, capture_output=True)
    print(png)
