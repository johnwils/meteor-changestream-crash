import { Meteor } from 'meteor/meteor';
import { Mongo } from 'meteor/mongo';

const Items = new Mongo.Collection('items');

Meteor.startup(async () => {
  await Items.upsertAsync('a', { $set: { n: 1 } });
  console.log('[repro] ready');
  setInterval(() => console.log('[repro] alive'), 5000);

  // A new observer every 250 ms, as clients do when they subscribe again after a reconnect.
  // The app handles the promise that observeChanges returns.
  setInterval(() => {
    Items.find({ n: { $gte: Math.random() } })
      .observeChanges({ added() {} })
      .then((handle) => setTimeout(() => handle.stop(), 2000))
      .catch((error) => console.error('[repro] observeChanges rejected:', error.name));
  }, 250);
});
