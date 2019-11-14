
import requests, json

u = requests.get(
    url="https://api.github.com/repos/tudelft3d/terrainbook/contributors",
)
u.raise_for_status()
data = u.json()

allofthem = []
for each in data:
    s = 'https://api.github.com/users/' + each['login']
    u2 = requests.get(
        url=s,
    )   
    u2.raise_for_status()
    n = u2.json()['name']
    if (n != 'Hugo Ledoux') and (n != 'Ravi Peters') and (n != 'Ken Arroyo Ohori'):
        allofthem.append(n)

for each in allofthem:
    print(each)