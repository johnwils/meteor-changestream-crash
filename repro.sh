#!/bin/bash
# Starts a single-node replica set, runs the app, makes Mongo unreachable for 100 s, and reports
# whether the server process survived.
set -u
docker rm -f cs-crash-mongo >/dev/null 2>&1
docker run -d --name cs-crash-mongo -p 127.0.0.1:3911:27017 mongo:8.0 --replSet rs0 --bind_ip_all >/dev/null
sleep 4
docker exec cs-crash-mongo mongosh --quiet --eval 'rs.initiate({_id:"rs0",members:[{_id:0,host:"127.0.0.1:27017"}]}).ok' >/dev/null
sleep 3
export MONGO_URL='mongodb://127.0.0.1:3911/repro?directConnection=true'
meteor run --once --port 3999 --settings settings.json > run.log 2>&1 &
PID=$!
until grep -q '\[repro\] ready' run.log; do kill -0 $PID 2>/dev/null || { tail -20 run.log; exit 2; }; sleep 1; done
sleep 3
echo "pausing Mongo for 100 s"
docker pause cs-crash-mongo >/dev/null
for i in $(seq 1 100); do kill -0 $PID 2>/dev/null || break; sleep 1; done
docker unpause cs-crash-mongo >/dev/null
sleep 15
if kill -0 $PID 2>/dev/null; then echo "RESULT: server alive"; pkill -P $PID; kill $PID; else echo "RESULT: server exited"; fi
grep -n -m1 -A1 'Failed to start ChangeStream' run.log
grep -n 'triggerUncaughtException\|^Node.js v' run.log
docker rm -f cs-crash-mongo >/dev/null
