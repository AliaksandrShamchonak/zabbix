import requests, json, socket
from requests.auth import HTTPBasicAuth
from subprocess import check_output

zabbix_server = "192.168.219.90"
url = "http://" + zabbix_server + "/api_jsonrpc.php"
uname = "Admin"
upassword = "zabbix"

newgroup = 'CloudHosts'
newtemplate = 'CloudTemplate'


def post(data):
    headers = {'Content-Type': 'application/json'}
    rdata = json.dumps(data)
    auth = HTTPBasicAuth(uname, upassword)
    r = requests.post(url, data=rdata, headers=headers, auth=auth)
    return r


auth_token = post({
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
         "user": uname,
         "password": upassword
     },
    "auth": None,
    "id": 0}
).json()["result"]


def gethost():
    return post({
        "jsonrpc": "2.0",
        "method": "host.get",
        "params": {
            "output": [
                "hostid",
                "host"
            ]
        },
        "id": 1,
        "auth": auth_token
    }).json()["result"]
server_hostname = gethost()[0]['host']
server_hostid = gethost()[0]['hostid']


def gettemplate():
    return post({
        "jsonrpc": "2.0",
        "method": "template.get",
        "params": {
            "output": "extend",
            "filter": {
                "name": newtemplate
            }
        },
        "id": 2,
        "auth": auth_token
    }).json()["result"]


def gethostgroup():
    return post({
        "jsonrpc": "2.0",
        "method": "hostgroup.get",
        "params": {
            "output": "extend",
            "filter": {
                "name": newgroup
            }
        },
        "id": 3,
        "auth": auth_token
    }).json()["result"]


def createhostgroup(newgroup):
    return post({
        "jsonrpc": "2.0",
        "method": "hostgroup.create",
        "params": {
            "name": newgroup
        },
        "id": 4,
        "auth": auth_token
    }).json()["result"]


def createtemplate(groupid):
    return post({
        "jsonrpc": "2.0",
        "method": "template.create",
        "params": {
            "host": newtemplate,
            "groups": {
                "groupid": groupid
            }
        },
        "id": 5,
        "auth": auth_token
    }).json()["result"]


def createhost(hostname, ipaddress, groupid, templateid):
    return post({
        "jsonrpc": "2.0",
        "method": "host.create",
        "params": {
            "host": hostname,
            "templates": [{
                "templateid": templateid
            }],
            "interfaces": [{
                "type": 1,
                "main": 1,
                "useip": 1,
                "ip": ipaddress,
                "dns": "",
                "port": "10050"
            }],
            "groups": [
                {"groupid": groupid}
            ]
        },
        "auth": auth_token,
        "id": 6
    })


if len(gethostgroup()) == 0:
    groupid = createhostgroup(newgroup)['groupids'][0]
    templateid = createtemplate(groupid)['templateids'][0]
elif len(gettemplate()) == 0:
    groupid = gethostgroup()[0]['groupid']
    templateid = createtemplate(groupid)['templateids'][0]
else:
    groupid = gethostgroup()[0]['groupid']
    templateid = gettemplate()[0]['templateid']

hostname = socket.gethostname()
ipaddress = check_output(['hostname', '--all-ip-addresses']).split()[1]

createhost(hostname, ipaddress, groupid, templateid)
print("New host %s (%s) was sucessfully registered." % (hostname, ipaddress))
