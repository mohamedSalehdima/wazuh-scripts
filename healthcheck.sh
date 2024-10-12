#!/bin/bash
host=$(ip route get 8.8.8.8 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
ram=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }' | sed 's/[ \t]*$//')
disk=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}' | sed 's/[ \t]*$//')
cpu=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}' | sed 's/[ \t]*$//')
json='{"host":"'"$host"'", "ram":"'"$ram"'", "cpu":"'"$cpu"'", "disk":"'"$disk"'"}'
echo -e "$json" >> /tmp/health.json

#configuration in ossce conf to run the script every 30m and read the output of the file
 <localfile>
    <log_format>json</log_format>
    <location>/tmp/health.json</location>
  </localfile>
<wodle name="command">
                <disabled>no</disabled>
                <tag>healthcheck</tag>
                <command>/opt/healthcheck.sh</command>
                <interval>30m</interval>
                <ignore_output>yes</ignore_output>
                <run_on_start>yes</run_on_start>
                <timeout>0</timeout>
 </wodle>

 #rules 
 <rule id="100014" level="5">
    <decoded_as>json</decoded_as>
    <field name="cpu">\.+</field>
    <description>Metrics Health Check</description>
    <options>no_full_log</options>
  </rule>
  <rule id="100015" level="12">
    <if_sid>100014</if_sid>
    <field name="ram">^8\.+|^9\.+|^100\.+</field>
    <description>Memory Usage is High $(ram)</description>
    <options>no_full_log</options>
  </rule>
  <rule id="100016" level="12">
    <if_sid>100014</if_sid>
    <field name="cpu">^8\.+|^9\.+|^100\.+</field>
    <description>CPU Usage is High $(cpu)</description>
    <options>no_full_log</options>
  </rule>
  <rule id="100017" level="12">
    <if_sid>100014</if_sid>
    <field name="disk">^70%|^8[0-9]%|^100%</field>
    <description>Disk Space is Running Low $(disk)</description>
    <options>no_full_log</options>
  </rule>
