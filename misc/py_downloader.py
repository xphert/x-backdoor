# Bypass download limit with simple spython script
# by Exphert

import urllib.request, shutil

url = "" #rawfile url
out = "" #outfile

req = urllib.request.Request(url, headers={"User-Agent": "python"})
with urllib.request.urlopen(req, timeout=60) as r, open(out, "wb") as f:
    shutil.copyfileobj(r, f, length=64 * 1024)

print("saved", out)
