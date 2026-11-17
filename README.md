# ChangeStreamObserveDriver: a failed start exits the server

Minimal reproduction for a Meteor 3.6.1 issue. It needs Docker and Meteor 3.6.1.

```sh
meteor npm install
./repro.sh
```

The script starts `mongo:8.0` as a single-node replica set on port 3911, runs this app with change-stream reactivity (`settings.json`), and pauses Mongo for 100 s while the app keeps creating observers. Expected output: `RESULT: server alive`. Actual output: `RESULT: server exited`, after `Failed to start ChangeStream: MongoServerSelectionError` and `triggerUncaughtException(err, true /* fromPromise */)` in `run.log`.
