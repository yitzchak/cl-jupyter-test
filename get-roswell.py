import urllib.request
from github import Github

g = Github()

for a in g.get_repo("roswell/roswell").get_latest_release().get_assets():
    if a.name.endswith("_amd64.deb"):
        urllib.request.urlretrieve(a.browser_download_url, a.name)
