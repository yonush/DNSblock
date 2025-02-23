import std/httpclient
import std/json
import std/strformat
import std/os
 
echo("Authenticating...")
var pwd: string = ""
var blockstate:bool = true

# check command parameters
if os.paramcount() == 2:
  pwd = os.paramstr(1)
  var state = os.paramstr(2) # 0/1 = disable/enable
  if state == "0":
    blockstate = false  
  else:
    blockstate = true
else:
  echo """
      DNSblock [pihole password] [state]
      state
        0 disable DNS blocking
        1 enable dns blocking
  """
  quit(QuitSuccess)

#[
url = "http://pi.hole/api/auth"
payload = {"password": "jVYwzEtQsACOLWaMtb276f5gmKjw8jNQcPVdBU9MZBk="}

response = requests.request("POST", url, json=payload, verify=False)
data = response.json()['session'] # grab the session data
sid = data['sid']
csrf = data['csrf']

#]#
let req = httpclient.newHttpClient()
req.headers = newHttpHeaders({"Content-Type": "application/json"})
#       "X-FTL-SID": fmt"{sid}",
#       "X-FTL-CSRF": fmt"{csrf}" })

var payload = fmt"""{{"password": "{pwd}" }}"""
var url =  "http://pi.hole/api/auth/"
var res = req.request(url, httpMethod = HttpPost, body = $payload)

if res.code == Http401:
    echo("Unauthorised access, provide a correct password")
    quit(QuitFailure)

#echo res.status
#echo res.body
var data = json.parseJson(res.body)
let sid = data["session"]["sid"].getStr()
#let csrf = data["session"]["csrf"].getStr()

#[ -----------------------------------------------------------------------
url = "http://pi.hole/api/auth/sessions"
payload = {"sid":f"{sid}"}
headers = {}
response = requests.request("GET", url, headers=headers, data=payload, verify=False)
data = response.json()['sessions'] # grab the session data
print(f"Active sessions: {len(data)}")
]#

echo("Authenticated Sessions")
url = "http://pi.hole/api/auth/sessions"
payload = fmt"""{{"sid": "{sid}" }}"""

res = req.request(url, httpMethod = HttpGet, body = $payload)
if res.code == Http401:
    echo("Unauthorised access, provide a correct password")
    quit(QuitFailure)

data = json.parseJson(res.body)
echo(fmt"- Active sessions: {len(data)}")


#[-----------------------------------------------------------------------
print("DNS blocking")
url = "http://pi.hole/api/dns/blocking"
payload = {"sid":f"{sid}"}
headers = {}
response = requests.request("GET", url, headers=headers, data=payload, verify=False)
data = response.json() # grab the session data
print(f"Blocked status: {data['blocking']}")
]#
echo("Enabling/Disabling DNS blocking")
url = "http://pi.hole/api/dns/blocking"
payload = fmt"""{{"sid": "{sid}", "blocking":{blockstate}, "timer":300 }}""" # disable for 5min

res = req.request(url, httpMethod = HttpPost, body = $payload)
if res.code == Http400:
    echo("Bad request")
    quit(QuitFailure)

if res.code == Http401:
    echo("Unauthorised access, provide a correct password")
    quit(QuitFailure)
data = json.parseJson(res.body)

payload = fmt"""{{"sid": "{sid}" }}"""

res = req.request(url, httpMethod = HttpGet, body = $payload)
if res.code == Http400:
    echo("Bad request")
    quit(QuitFailure)

if res.code == Http401:
    echo("Unauthorised access, provide a correct password")
    quit(QuitFailure)

data = json.parseJson(res.body)
let status = data["blocking"].getStr()

echo(fmt"- Blocked status: {status}")

#[
print("Closing session...")
url = "http://pi.hole/api/auth"
payload = {"sid":f"{sid}"}
headers = {}
response = requests.request("DELETE", url, headers=headers, data=payload, verify=False)
if response.status_code == 204:
  print("Session closed.")
else:
  print("Unable to close session")  
]#

echo("Closing session...")
url = fmt"http://pi.hole/api/auth/session/1" # assuming session 1 to be the NIM session
payload = fmt"""{{"sid": "{sid}" }}"""

res = req.request(url, httpMethod = HttpDelete, body = $payload)
if res.code == Http400:
    echo("Bad request")
    quit(QuitFailure)

if res.code == Http401:
    echo("Unauthorised access, provide a correct password")
    quit(QuitFailure)

if res.code == Http404:
    echo("Session not found")
    quit(QuitFailure)

if res.code == Http204:
  echo("- Session closed.")
else:
  echo("- Unable to close session")  

sleep(5000)