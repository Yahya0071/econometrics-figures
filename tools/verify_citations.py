import json
import urllib.request

dois = [
    ("Cattaneo et al. 2024", "10.1257/aer.20221576"),
    ("Abadie et al. 2010", "10.1198/jasa.2009.ap08740"),
    ("Anselin 1988", "10.1007/978-94-015-7799-1"),
    ("Calonico et al. 2014", "10.3982/ECTA11757"),
    ("Calonico et al. 2015", "10.1080/01621459.2015.1017578"),
    ("Goodman-Bacon 2021", "10.1016/j.jeconom.2021.03.014"),
    ("Callaway and Sant'Anna 2021", "10.1016/j.jeconom.2020.12.001"),
    ("Sun and Abraham 2021", "10.1016/j.jeconom.2020.09.006"),
    ("Jorda 2005", "10.1257/0002828053828518")
]

for label, doi in dois:
    url = f"https://api.crossref.org/works/{doi}"
    req = urllib.request.Request(url, headers={"User-Agent": "ResearchAudit/1.0 (mailto:audit@example.com)"})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8"))["message"]
            title = data.get("title", [""])[0]
            container = data.get("container-title", [""])[0]
            vol = data.get("volume", "")
            issue = data.get("issue", "")
            page = data.get("page", "")
            issued = data.get("issued", {}).get("date-parts", [[None]])[0][0]
            author_list = [f"{a.get('family', '')}, {a.get('given', '')}" for a in data.get("author", [])]
            authors = "; ".join(author_list)
            resource_url = data.get("resource", {}).get("primary", {}).get("URL", f"https://doi.org/{doi}")
            print(f"[{label}]")
            print(f"  DOI: {doi}")
            print(f"  Title: {title}")
            print(f"  Journal/Container: {container}")
            print(f"  Year: {issued} | Vol: {vol} | Issue: {issue} | Pages: {page}")
            print(f"  Authors: {authors}")
            print(f"  Primary URL: {resource_url}")
            print()
    except Exception as e:
        print(f"Error for {doi}: {e}")
