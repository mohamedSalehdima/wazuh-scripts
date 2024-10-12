#!/usr/bin/env python3
#
import json
import requests
import urllib3
from base64 import b64encode

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

protocol = 'https'
host = '' #put your wazuh manager ip
port = 55000
user = '' #put your wazuh api user 
password = ''#put your wazuh api  password  
login_endpoint = 'security/user/authenticate'

login_url = f"{protocol}://{host}:{port}/{login_endpoint}"
basic_auth = f"{user}:{password}".encode()
login_headers = {'Content-Type': 'application/json',
                 'Authorization': f'Basic {b64encode(basic_auth).decode()}'}

response = requests.post(login_url, headers=login_headers, verify=False)
token = json.loads(response.content.decode())['data']['token']

requests_headers = {'Content-Type': 'application/json',
                    'Authorization': f'Bearer {token}'}

print("\033[34mAgents Summary\033[0m")
agent_summary_response = requests.get(f"{protocol}://{host}:{port}/agents/summary/status?pretty=true", headers=requests_headers, verify=False)

agent_summary_data = agent_summary_response.json()

active_agents = agent_summary_data.get("data", {}).get("connection", {}).get("active")
disconnected_agents = agent_summary_data.get("data", {}).get("connection", {}).get("disconnected")
total = agent_summary_data.get("data", {}).get("connection", {}).get("total")

print(f"Active agents: {active_agents}")
print(f"Disconnected agents: {disconnected_agents}")
print(f"Total agents: {total}")

print("\033[34mFull JSON\033[0m")
print(agent_summary_data)

agent_overview_response = requests.get(f"{protocol}://{host}:{port}/overview/agents", headers=requests_headers, verify=False)
print(agent_overview_response.text)

api_info_response = requests.get(f"{protocol}://{host}:{port}/", headers=requests_headers, verify=False)
print(api_info_response.text)

agents_response = requests.get(f"{protocol}://{host}:{port}/agents", headers=requests_headers, verify=False)
print(agents_response.text)
