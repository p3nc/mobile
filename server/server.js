const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const low = require('lowdb');
const FileSync = require('lowdb/adapters/FileSync');
const { WebSocketServer } = require('ws');

const app = express();
app.use(cors());
app.use(express.json());

const adapter = new FileSync('db.json');
const db = low(adapter);
db.defaults({ users: [], playlists: [], favorites: [], activity: [] }).write();

function getUserId(req) {
  const auth = req.headers.authorization;
  if (!auth) return null;
  return auth.replace('Bearer ', '').replace('bio-token-', '');
}

// ══ AUTH ══

app.post('/api/register', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).json({ error: 'Missing fields' });
  if (db.get('users').find({ username }).value()) return res.status(400).json({ error: 'User exists' });
  const hashedPassword = await bcrypt.hash(password, 10);
  const newUser = { id: Date.now().toString(), username, password: hashedPassword };
  db.get('users').push(newUser).write();
  db.get('activity').push({ userId: newUser.id, type: 'auth', description: 'Реєстрація акаунту', createdAt: new Date().toISOString() }).write();
  res.status(201).json({ token: 'bio-token-' + newUser.id, username });
});

app.post('/api/login', async (req, res) => {
  const { username, password } = req.body;
  const user = db.get('users').find({ username }).value();
  if (user && await bcrypt.compare(password, user.password)) {
    db.get('activity').push({ userId: user.id, type: 'auth', description: 'Вхід в акаунт', createdAt: new Date().toISOString() }).write();
    res.json({ token: 'bio-token-' + user.id, username });
  } else {
    res.status(401).json({ error: 'Auth failed' });
  }
});

// ══ PLAYLISTS ══

app.get('/api/playlists', (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.sendStatus(401);
  res.json(db.get('playlists').filter({ userId }).value());
});

app.post('/api/playlists', (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.sendStatus(401);
  const playlist = req.body;
  const exists = db.get('playlists').find({ id: playlist.id, userId }).value();
  if (exists) {
    db.get('playlists').find({ id: playlist.id, userId }).assign({ ...playlist, userId }).write();
  } else {
    db.get('playlists').push({ ...playlist, userId }).write();
    db.get('activity').push({ userId, type: 'playlist', description: `Створено плейлист "${playlist.title}"`, createdAt: new Date().toISOString() }).write();
  }
  res.status(201).json({ status: 'saved' });
});

app.post('/api/playlists/sync', (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.sendStatus(401);
  const playlist = req.body;
  const exists = db.get('playlists').find({ id: playlist.id, userId }).value();
  if (exists) {
    db.get('playlists').find({ id: playlist.id, userId }).assign({ ...playlist, userId }).write();
  } else {
    db.get('playlists').push({ ...playlist, userId }).write();
  }
  db.get('activity').push({ userId, type: 'playlist', description: `Оновлено плейлист "${playlist.title}"`, createdAt: new Date().toISOString() }).write();
  res.json({ status: 'synced' });
});

app.delete('/api/playlists/:id', (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.sendStatus(401);
  const playlist = db.get('playlists').find({ id: req.params.id, userId }).value();
  db.get('playlists').remove({ id: req.params.id, userId }).write();
  if (playlist) {
    db.get('activity').push({ userId, type: 'playlist', description: `Видалено плейлист "${playlist.title}"`, createdAt: new Date().toISOString() }).write();
  }
  res.json({ status: 'deleted' });
});

// ══ FAVORITES ══

app.get('/api/favorites', (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.sendStatus(401);
  res.json(db.get('favorites').filter({ userId }).value().map(f => f.songId));
});

app.post('/api/favorites/toggle', (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.sendStatus(401);
  const { songId } = req.body;
  const exists = db.get('favorites').find({ userId, songId }).value();
  if (exists) {
    db.get('favorites').remove({ userId, songId }).write();
    db.get('activity').push({ userId, type: 'favorite', description: `Видалено з улюблених: ${songId}`, createdAt: new Date().toISOString() }).write();
    res.json({ status: 'removed' });
  } else {
    db.get('favorites').push({ userId, songId, addedAt: new Date().toISOString() }).write();
    db.get('activity').push({ userId, type: 'favorite', description: `Додано до улюблених: ${songId}`, createdAt: new Date().toISOString() }).write();
    res.json({ status: 'added' });
  }
});

// ══ ACTIVITY ══

app.get('/api/activity', (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.sendStatus(401);
  const activity = db.get('activity').filter({ userId }).value().reverse().slice(0, 50);
  res.json(activity);
});

app.delete('/api/activity', (req, res) => {
  const userId = getUserId(req);
  if (!userId) return res.sendStatus(401);
  db.get('activity').remove({ userId }).write();
  res.json({ status: 'cleared' });
});

// ══ WEBSOCKET ══

const server = app.listen(3000, () => console.log('Server running on port 3000'));

const wss = new WebSocketServer({ server });
wss.on('connection', (ws) => {
  const interval = setInterval(() => {
    if (ws.readyState === ws.OPEN) {
      ws.send(JSON.stringify({
        type: 'friend_activity',
        friend: 'User_' + Math.floor(Math.random() * 100),
        songTitle: 'Song_' + Math.floor(Math.random() * 50),
      }));
    }
  }, 5000);
  ws.on('close', () => clearInterval(interval));
});