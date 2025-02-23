"""
  pi-hole check DNS blocking status
""" 
import requests

print("Authenticating...")
url = "http://pi.hole/api/auth"
payload = {"password": "jVYwzEtQsACOLWaMtb276f5gmKjw8jNQcPVdBU9MZBk="}

response = requests.request("POST", url, json=payload, verify=False)
data = response.json()['session'] # grab the session data
sid = data['sid']
csrf = data['csrf']

# session key if headers are used
headers = {
  "X-FTL-SID": f"{sid}",
  "X-FTL-CSRF": f"{csrf}"
}

url = "http://pi.hole/api/auth/sessions"
payload = {"sid":f"{sid}"}
headers = {}
response = requests.request("GET", url, headers=headers, data=payload, verify=False)
data = response.json()['sessions'] # grab the session data
print(f"Active sessions: {len(data)}")

print("DNS blocking")
url = "http://pi.hole/api/dns/blocking"
payload = {"sid":f"{sid}"}
headers = {}
response = requests.request("GET", url, headers=headers, data=payload, verify=False)
data = response.json() # grab the session data
print(f"Blocked status: {data['blocking']}")

print("Closing session...")
url = "http://pi.hole/api/auth"
payload = {"sid":f"{sid}"}
headers = {}
response = requests.request("DELETE", url, headers=headers, data=payload, verify=False)
if response.status_code == 204:
  print("Session closed.")
else:
  print("Unable to close session")  